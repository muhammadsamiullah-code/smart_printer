import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';
import 'package:smart_scanner/widgets/custom_appbar.dart';

import '../../../widgets/build_commeon_fab.dart';
import '../../../widgets/center_widget_for_pdf.dart';
import '../../../widgets/file_option_menu.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/tr_text.dart';
import '../merge_pdf/pdf_preview_screen.dart';
import 'deleted_pdf_page_screen.dart';

class DeletePdfHome extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  const DeletePdfHome({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<DeletePdfHome> createState() => _DeletePdfHomeState();
}

class _DeletePdfHomeState extends State<DeletePdfHome> {
  List<File> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  /// Load saved PDF files
  Future<void> loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().where((file) {
      return file.path.contains("deleted_pages_") && file.path.endsWith(".pdf");
    }).toList();

    setState(() {
      pdfFiles = files.map((e) => File(e.path)).toList();
    });
  }

  /// Pick PDF and navigate to DeletePdfPagesScreen
  Future<void> pickPdf() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    if (mounted) Navigator.pop(context);

    final adsProvider = context.read<AdsProvider>();

    /// 🔥 Step 3: Show Ad
    await adsProvider.showAdInterstitial();

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf"],
    );

    if (result != null) {
      final file = File(result.files.single.path!);

      // Show loader while navigating
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeletePdfPagesScreen(file: file, title: widget.title),
        ),
      );

      // if (mounted) Navigator.pop(context); // Close loader

      if (updated == true) {
        loadFiles(); // Refresh home screen with new files
      }
    }
  }

  /// Delete file
  void deleteFile(File file) async {
    await file.delete();
    loadFiles();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: TrText("file_deleted")));
  }

  /// Rename file
  void renameFile(File file) {
    final controller = TextEditingController(
      text: file.path.split('/').last.replaceAll(".pdf", ""),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const TrText("rename_file"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const TrText("cancel"),
          ),
          TextButton(
            onPressed: () async {
              final dir = file.parent.path;
              final newName = controller.text;

              final newFile = File("$dir/deleted_pages_$newName.pdf");

              await file.rename(newFile.path);
              // final dir = file.parent.path;
              // final newFile = File("$dir/${controller.text}.pdf");
              // await file.rename(newFile.path);
              Navigator.pop(context);
              loadFiles();
            },
            child: const TrText("rename"),
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
    final reversedList = pdfFiles.reversed.toList();
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: pdfFiles.isEmpty
          ? CenterWidgetForPDF(
              borderColor: Color.fromRGBO(48, 108, 132, 1),
              title: widget.title,
              icon: widget.icon,
              color: widget.color,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: reversedList.length,
              itemBuilder: (_, index) {
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
        onPressed: pickPdf,
        label: 'select_file',
      ),
    );
  }
}
