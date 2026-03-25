import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/widgets/custom_appbar.dart';
import '../../../widgets/build_commeon_fab.dart';
import '../../../widgets/center_widget_for_pdf.dart';
import '../../../widgets/file_option_menu.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/tr_text.dart';
import 'merge_pdf_screen.dart';
import 'pdf_preview_screen.dart';

class MergedPDFFilesScreen extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  const MergedPDFFilesScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<MergedPDFFilesScreen> createState() => _MergedPDFFilesScreenState();
}

class _MergedPDFFilesScreenState extends State<MergedPDFFilesScreen> {
  List<File> mergedFiles = [];
  List<File> selectedFiles = [];
  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  Future<void> loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().where((file) {
      return file.path.contains("merged_") && file.path.endsWith(".pdf");
    }).toList();

    setState(() {
      mergedFiles = files.map((e) => File(e.path)).toList();
    });
  }

  String getFileSize(File file) {
    int bytes = file.lengthSync();
    double kb = bytes / 1024;
    double mb = kb / 1024;

    return mb >= 1
        ? "${mb.toStringAsFixed(2)} MB"
        : "${kb.toStringAsFixed(2)} KB";
  }

  void deleteFile(File file) async {
    await file.delete();

    loadFiles(); // refresh list

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
      builder: (_) {
        return AlertDialog(
          title: const TrText("rename_file"),
          content: TextField(
            controller: controller,
            // decoration: const InputDecoration(hintText: "Enter new file name"),
          ),
          actions: [
            TextButton(
              child: const TrText("cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const TrText("rename"),
              onPressed: () async {
                final dir = file.parent.path;
                final newName = controller.text;

                final newFile = File("$dir/$newName.pdf");

                await file.rename(newFile.path);

                Navigator.pop(context);

                loadFiles(); // refresh
              },
            ),
          ],
        );
      },
    );
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

      body: mergedFiles.isEmpty
          ? CenterWidgetForPDF(
              title: widget.title,
              icon: widget.icon,
              color: widget.color,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: mergedFiles.length,
              itemBuilder: (context, index) {
                final file = mergedFiles[index];
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
        label: "select_file",
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            allowMultiple: true,
          );

          Navigator.pop(context);

          if (result != null) {
            final files = result.paths.map((path) => File(path!)).toList();

            final uniqueFiles = removeDuplicates(files);

            final response = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MergePdfScreen(
                  initialFiles: uniqueFiles,
                  title: widget.title,
                ),
              ),
            );

            if (response == true) {
              loadFiles();
            }
          }
        },
      ),
    );
  }
}
