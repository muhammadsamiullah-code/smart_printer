import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/widgets/tr_text.dart';
import '../../../widgets/build_commeon_fab.dart';
import '../../../widgets/center_widget_for_pdf.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/file_option_menu.dart';
import '../../../widgets/pdf_list_card.dart';
import '../merge_pdf/pdf_preview_screen.dart';
import 'add_water_mark_screen.dart';


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
        title: const TrText("rename_file"),
        content: TextField(controller: renameController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const TrText("cancel"),
          ),
          TextButton(
            onPressed: () async {
              final dir = await getApplicationDocumentsDirectory();
              final newFile = File("${dir.path}/${renameController.text}.pdf");
              await file.rename(newFile.path);
              Navigator.pop(context);
              loadSavedFiles();
            },
            child: const TrText("rename"),
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
        title: const TrText("delete_file"),
        content: const TrText("delete_file_confirmation"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const TrText("cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const TrText("delete"),
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
          final reversedList = savedFiles.reversed.toList();

    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: reversedList.isEmpty
          ? CenterWidgetForPDF(
              title: widget.title,
              icon: widget.icon,
              color: widget.color,
            )
          : ListView.builder(
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
        onPressed: () => pickPdf(context),
        label: 'select_file',
      ),
    );
  }
}
