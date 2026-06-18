import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../const/color.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/success_dialoge.dart';
import '../../../widgets/tr_text.dart';
import '../merge_pdf/pdf_preview_screen.dart';

class SplitPdfScreen extends StatefulWidget {
  final List<File> selectedFiles;
  final String title;

  const SplitPdfScreen({
    super.key,
    required this.selectedFiles,
    required this.title,
  });

  @override
  State<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends State<SplitPdfScreen> {
  late List<File> selectedFiles;
  bool isSplitting = false;
  Map<String, int> filePageCounts = {};

  @override
  void initState() {
    super.initState();
    selectedFiles = [...widget.selectedFiles];
    loadPageCounts();
  }

  Future<void> loadPageCounts() async {
    for (var file in selectedFiles) {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      filePageCounts[file.path] = document.pages.count;

      document.dispose();
    }
    setState(() {});
  }

  File? selectedFile;
  int totalPages = 0;

  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  /// Pick PDF
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      final files = result.paths.map((p) => File(p!)).toList();

      for (var file in files) {
        final bytes = await file.readAsBytes();
        final document = PdfDocument(inputBytes: bytes);

        filePageCounts[file.path] = document.pages.count;

        document.dispose();
      }

      setState(() {
        selectedFiles.addAll(
          files.where((f) => !selectedFiles.any((e) => e.path == f.path)),
        );
      });
    }
  }
  // Future<void> pickFile() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf'],
  //     allowMultiple: true,
  //   );

  //   if (result != null) {
  //     final files = result.paths.map((p) => File(p!)).toList();

  //     // Replace old files (CHANGE FILE behavior)
  //     setState(() {
  //       selectedFiles.addAll(
  //         files.where((f) => !selectedFiles.any((e) => e.path == f.path)),
  //       );
  //     });

  //     // Update page count for first file (optional)
  //     if (selectedFile != null) {
  //       final bytes = await selectedFile!.readAsBytes();
  //       final document = PdfDocument(inputBytes: bytes);

  //       setState(() {
  //         totalPages = document.pages.count;
  //       });

  //       document.dispose();
  //     }
  //   }
  // }

  Future<void> splitPdf(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
    );
    int start = int.tryParse(startController.text) ?? 1;
    int end = int.tryParse(endController.text) ?? 0;

    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    end = end == 0 ? document.pages.count : end;

    if (start < 1 || end > document.pages.count || start > end) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid page range")));
      document.dispose();
      return;
    }

    setState(() => isSplitting = true);

    // final newDoc = PdfDocument();
    // for (int i = start - 1; i < end; i++) {
    //   newDoc.pages.add().graphics.drawPdfTemplate(
    //     document.pages[i].createTemplate(),
    //     const Offset(0, 0),
    //   );
    // }
    final newDoc = PdfDocument();

for (int i = start - 1; i < end; i++) {
  final oldPage = document.pages[i];

  final section = newDoc.sections!.add();
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

    final dir = await getApplicationDocumentsDirectory();
    final outFile = File(
      "${dir.path}/split_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );
    await outFile.writeAsBytes(await newDoc.save());

    document.dispose();
    newDoc.dispose();

    setState(() => isSplitting = false);
    Navigator.pop(context);
    SuccessDialog.show(context, file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,

              itemCount: selectedFiles.length,
              itemBuilder: (_, index) {
                final file = selectedFiles[index];
                final fileName = file.path.split('/').last;
                return PdfListCard(
                  title: fileName,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PdfPreviewPrintScreen(file: file),
                    ),
                  ),
                  subtitle: Text(
                    filePageCounts.containsKey(file.path)
                        ? "${filePageCounts[file.path]} pages"
                        : "Loading...",
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// Page Inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Start Page",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10), // 🔥 radius
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ), // 🔥 grey border
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ), // same color on focus
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: endController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "End Page",
                      labelStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      /// Bottom Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 80,
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                onPressed: isSplitting
                    ? null
                    : () async {
                        final startText = startController.text.trim();
                        final endText = endController.text.trim();

                        // 🔴 Empty check
                        if (startText.isEmpty || endText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: TrText("please_enter_pages")),
                          );
                          return;
                        }

                        // 🔴 Number check
                        final start = int.tryParse(startText);
                        final end = int.tryParse(endText);

                        if (start == null || end == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: TrText("Enter valid numbers"),
                            ),
                          );
                          return;
                        }

                        for (final file in selectedFiles) {
                          await splitPdf(file);
                        }
                      },
                text: widget.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
