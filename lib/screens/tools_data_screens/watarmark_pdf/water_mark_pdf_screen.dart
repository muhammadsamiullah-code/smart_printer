import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../widgets/build_commeon_fab.dart';
import '../../../widgets/center_widget_for_pdf.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/file_option_menu.dart';
import '../../../widgets/pdf_list_card.dart';
import '../merge_pdf/pdf_preview_screen.dart';
import 'add_water_mark_screen.dart';
import 'watermark_view_screen.dart';

class WatermarkPdfScreen extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  const WatermarkPdfScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<WatermarkPdfScreen> createState() => _WatermarkPdfScreenState();
}

class _WatermarkPdfScreenState extends State<WatermarkPdfScreen> {
  List<File> savedFiles = [];

  @override
  void initState() {
    super.initState();
    loadSavedFiles();
  }

  /// Load all saved watermarked PDFs from app documents directory
  Future<void> loadSavedFiles() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith(".pdf") && f.path.contains("watermark_"))
        .toList();
    setState(() => savedFiles = files);
  }

  /// Pick PDF and navigate to AddWatermarkScreen
  Future<void> pickPdf(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (mounted) Navigator.pop(context); // close loader

    if (result != null) {
      File file = File(result.files.single.path!);

      final resultFromWatermark = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddWatermarkScreen(file: file, title: widget.title),
        ),
      );

      // Reload saved files if watermark was applied
      if (resultFromWatermark == true) {
        loadSavedFiles();
      }
    }
  }

  /// Rename a PDF file
  Future<void> renameFile(File file) async {
    TextEditingController renameController = TextEditingController(
      text: file.path.split('/').last.replaceAll(".pdf", ""),
    );

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename File"),
        content: TextField(controller: renameController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final dir = await getApplicationDocumentsDirectory();
              final newFile = File("${dir.path}/${renameController.text}.pdf");
              await file.rename(newFile.path);
              Navigator.pop(context);
              loadSavedFiles();
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  /// Delete a PDF file
  Future<void> deleteFile(File file) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete File"),
        content: const Text("Are you sure you want to delete this file?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await file.delete();
      loadSavedFiles();
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
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: savedFiles.isEmpty
          ? CenterWidgetForPDF(
              title: widget.title,
              icon: widget.icon,
              color: widget.color,
            )
          : ListView.builder(
              itemCount: savedFiles.length,
              itemBuilder: (_, index) {
                final file = savedFiles[index];
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
        onPressed: () => pickPdf(context),
        label: 'Select File',
      ),
    );
  }
}
