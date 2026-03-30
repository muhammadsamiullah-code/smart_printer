import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../widgets/build_commeon_fab.dart';
import '../../../widgets/center_widget_for_pdf.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/file_option_menu.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/tr_text.dart';
import '../merge_pdf/pdf_preview_screen.dart';
import 'rotation_pdf_screen.dart';

class RotatePdfFileScreen extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  const RotatePdfFileScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<RotatePdfFileScreen> createState() => _RotatePdfFileScreenState();
}

class _RotatePdfFileScreenState extends State<RotatePdfFileScreen> {
  List<File> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  /// LOAD FILES
  Future<void> loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().where((file) {
      return file.path.contains("rotated_") && file.path.endsWith(".pdf");
    }).toList();

    setState(() {
      pdfFiles = files.map((e) => File(e.path)).toList();
    });
  }

  /// PICK FILES + NAVIGATE
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      final files = result.paths.map((p) => File(p!)).toList();

      if (files.isNotEmpty) {
        final updated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RotatePdfScreen(selectedFiles: files, title: widget.title),
          ),
        );

        if (updated == true) {
          loadFiles();
        }
      }
    }
  }

  /// DELETE
  void deleteFile(File file) async {
    await file.delete();
    loadFiles();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: TrText("file_deleted")));
  }

  /// RENAME
  void renameFile(File file) {
    final controller = TextEditingController(
      text: file.path.split('/').last.replaceAll(".pdf", ""),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              final newFile = File("$dir/${controller.text}.pdf");

              await file.rename(newFile.path);

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

      /// FAB WITH LOADER
      floatingActionButton: buildCommonFAB(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          await pickFiles();

          if (mounted) Navigator.pop(context);
        },
        label: 'select_file',
      ),
    );
  }
}
