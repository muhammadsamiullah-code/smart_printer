import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import '../../../const/color.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/success_dialoge.dart';
import '../../../widgets/tr_text.dart';
import 'pdf_preview_screen.dart';
import 'package:intl/intl.dart';

class MergePdfScreen extends StatefulWidget {
  final List<File>? initialFiles;
  final String title;

  const MergePdfScreen({super.key, this.initialFiles, required this.title});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen> {
  @override
  void initState() {
    super.initState();

    /// 👇 receive files from previous screen
    if (widget.initialFiles != null) {
      selectedFiles = List.from(widget.initialFiles!);
    }
  }

  List<File> selectedFiles = [];

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      final newFiles = result.paths.map((path) => File(path!)).toList();

      /// 🔥 REMOVE DUPLICATES (MERGE WITH EXISTING)
      final allFiles = [...selectedFiles, ...newFiles];

      final uniqueFiles = removeDuplicates(allFiles);

      setState(() {
        selectedFiles = uniqueFiles;
      });
    }
  }

  List<File> removeDuplicates(List<File> files) {
    final paths = <String>{};

    return files.where((file) {
      if (paths.contains(file.path)) {
        return false;
      } else {
        paths.add(file.path);
        return true;
      }
    }).toList();
  }

  void removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  Future<void> mergePdf() async {
    if (selectedFiles.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText("select_at_least_2_pdf")));
      return;
    }

    /// 🔄 SHOW LOADER
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
    );

    try {
      final PdfDocument newDocument = PdfDocument();
      for (File file in selectedFiles) {
        final bytes = await file.readAsBytes();
        final PdfDocument document = PdfDocument(inputBytes: bytes);

        for (int i = 0; i < document.pages.count; i++) {
          final oldPage = document.pages[i];

          final section = newDocument.sections!.add();
          section.pageSettings.size = oldPage.size;

          final newPage = section.pages.add();

          final template = oldPage.createTemplate();
          final width = newPage.getClientSize().width;
          final height = newPage.getClientSize().height;

          newPage.graphics.drawPdfTemplate(
            template,
            Offset.zero,
            Size(width, height),
          );
        }

        document.dispose();
      }

            final directory = await getApplicationDocumentsDirectory();

      final mergedFile = File(
        "${directory.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await mergedFile.writeAsBytes(await newDocument.save());
      newDocument.dispose();

      Navigator.pop(context);

      SuccessDialog.show(context, mergedFile);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    }
  }

  String formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else if (bytes >= 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else {
      return "$bytes B";
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat("dd MMM yyyy 'at' hh:mm a").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = selectedFiles.isEmpty;
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: selectedFiles.length,
        itemBuilder: (context, index) {
          final file = selectedFiles[index];
          final fileName = file.path.split('/').last;
          return PdfListCard(
            title: fileName,

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfPreviewPrintScreen(file: file),
                ),
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.delete, color: AppColors.primaryColor),
              onPressed: () => removeFile(index),
            ),
          );
        },
      ),

      /// Bottom Buttons (ONLY WHEN FILES EXIST)
      bottomNavigationBar: isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(12),
              height: 80,
              child: Row(
                children: [
                  Expanded(
                    child: CustomButtonWithBorder(
                      borderWidth: 1.5,
                      borderColor: AppColors.primaryColor,
                      onPressed: pickFiles,
                      text: 'add_more',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: CustomButton(onPressed: mergePdf, text: "merge_pdf"),
                  ),
                ],
              ),
            ),
    );
  }
}
