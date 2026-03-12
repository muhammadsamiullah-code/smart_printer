import 'dart:io';
import 'package:flutter/material.dart';

import 'pdf_merge_preview.dart';

import 'package:path_provider/path_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<FileSystemEntity> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  /// Load merged pdf files
  Future<void> loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().where((file) {
      return file.path.endsWith(".pdf");
    }).toList();

    setState(() {
      pdfFiles = files;
    });
  }

  /// Delete file
  void deleteFile(File file) async {
    await file.delete();
    loadFiles();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("File deleted")));
  }

  /// Rename file
  void renameFile(File file) {
    final controller = TextEditingController(text: file.path.split('/').last);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Rename File"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter new file name"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Rename"),
              onPressed: () async {
                final dir = file.parent.path;
                final newName = controller.text;

                final newFile = File("$dir/$newName.pdf");

                await file.rename(newFile.path);

                Navigator.pop(context);

                loadFiles();
              },
            ),
          ],
        );
      },
    );
  }

  String getFileSize(File file) {
    int bytes = file.lengthSync();

    double kb = bytes / 1024;
    double mb = kb / 1024;

    if (mb >= 1) {
      return "${mb.toStringAsFixed(2)} MB";
    } else {
      return "${kb.toStringAsFixed(2)} KB";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Merged PDF Results")),

      body: pdfFiles.isEmpty
          ? const Center(child: Text("No merged PDFs found"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: pdfFiles.length,
              itemBuilder: (context, index) {
                final file = File(pdfFiles[index].path);
                final fileName = file.path.split('/').last;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                    ),

                    title: Text(fileName),

                    subtitle: Text(
                      "Size: ${getFileSize(file)} • Tap to preview",
                    ),

                    /// Preview
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfMergePreviewScreen(file: file),
                        ),
                      );
                    },

                    /// Options
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "rename",
                          child: Text("Rename"),
                        ),

                        const PopupMenuItem(
                          value: "delete",
                          child: Text("Delete"),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == "rename") {
                          renameFile(file);
                        }

                        if (value == "delete") {
                          deleteFile(file);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
