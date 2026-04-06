import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../widgets/build_commeon_fab.dart';
import '../../../widgets/center_widget_for_pdf.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/file_option_menu.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/tr_text.dart';
import '../merge_pdf/pdf_preview_screen.dart';
import 'create_pdf_screen.dart';

class CreatePdfFileScreen extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  const CreatePdfFileScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<CreatePdfFileScreen> createState() => _CreatePdfFileScreenState();
}

class _CreatePdfFileScreenState extends State<CreatePdfFileScreen> {
  List<File> createdFiles = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  /// Load created PDFs
  Future<void> loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().where((file) {
      return file.path.contains("create_pdf_") && file.path.endsWith(".pdf");
    }).toList();

    setState(() {
      createdFiles = files.map((e) => File(e.path)).toList();
    });
  }

  /// Navigate with loader
  Future<void> openCreateScreen() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(milliseconds: 300));

    // Navigator.pop(context); // remove loader
           if (mounted) Navigator.pop(context);

  final adsProvider = context.read<AdsProvider>();

  /// 🔥 Step 3: Show Ad
  await adsProvider.showAdInterstitial();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreatePdfScreen(title: widget.title)),
    );

    if (result == true) {
      loadFiles();
    }
  }

  Future<int> getPageCount(File file) async {
    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    int count = document.pages.count;
    document.dispose();
    return count;
  }

  void deleteFile(File file) async {
    await file.delete();
    loadFiles();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: TrText("file_deleted")));
  }

  void renameFile(File file) {
    final controller = TextEditingController(
      text: file.path.split('/').last.replaceAll(".pdf", ""),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
         backgroundColor: Colors.white,
        title: const TrText("rename_file"),
        content: TextField(
          controller: controller,
        ),
        actions: [
          TextButton(
            child: const  TrText("cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const TrText("rename"),
            onPressed: () async {
                final dir = file.parent.path;
                final newName = controller.text;

                final newFile = File("$dir/create_pdf_$newName.pdf");

                await file.rename(newFile.path);
              // final dir = file.parent.path;
              // final newFile = File("$dir/${controller.text}.pdf");

              // await file.rename(newFile.path);

              Navigator.pop(context);
              loadFiles();
            },
          ),
        ],
      ),
    );
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
     final reversedList = createdFiles.reversed.toList();
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: createdFiles.isEmpty
          ? CenterWidgetForPDF(
            borderColor: Color.fromRGBO(19, 180, 113, 1),
              title: widget.title,
              icon: widget.icon,
              color: widget.color,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: reversedList.length,
              itemBuilder: (context, index) {
                final file = reversedList[index];
                final fileName = file.path.split('/').last;
                final fileSize = formatFileSize(file.lengthSync());
                final lastModified = file.lastModifiedSync();
                final formattedDate = formatDateTime(lastModified);
                return PdfListCard(
                  title: fileName,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileSize, style: TextStyle(fontSize: 12)),
                      Text(formattedDate, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: FileOptionsMenu(
                    onRename: () => renameFile(file),
                    onDelete: () => deleteFile(file),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PdfPreviewPrintScreen(file: file),
                      ),
                    );
                  },
                );
              },
            ),

      floatingActionButton: buildCommonFAB(
        onPressed: openCreateScreen,
        label: 'create_pdf',
      ),
    );
  }
}
