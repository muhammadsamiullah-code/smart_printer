import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

import 'pdf_merge_preview.dart';
import 'pdf_results_screen.dart';

class MergePdfScreen extends StatefulWidget {
  const MergePdfScreen({super.key});

  @override
  State<MergePdfScreen> createState() => _MergePdfScreenState();
}

class _MergePdfScreenState extends State<MergePdfScreen> {
  List<File> selectedFiles = [];

  /// Select PDF files
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        selectedFiles.addAll(
          result.paths.map((path) => File(path!)),
        );
      });
    }
  }

  /// Remove file
  void removeFile(int index) {
    setState(() {
      selectedFiles.removeAt(index);
    });
  }

  /// Merge PDFs
  Future<void> mergePdf() async {
    if (selectedFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select at least 2 PDF files for merging"),
        ),
      );
      return;
    }

    final PdfDocument newDocument = PdfDocument();

    for (File file in selectedFiles) {
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      for (int i = 0; i < document.pages.count; i++) {
        newDocument.pages.add().graphics.drawPdfTemplate(
          document.pages[i].createTemplate(),
          const Offset(0, 0),
        );
      }

      document.dispose();
    }

    final directory = await getApplicationDocumentsDirectory();

    final mergedFile = File(
        "${directory.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await mergedFile.writeAsBytes(await newDocument.save());

    newDocument.dispose();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Merge PDF")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFiles,
              child: const Text("Select PDF Files"),
            ),

            const SizedBox(height: 20),

            /// FILE LIST
            Expanded(
              child: ListView.builder(
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = selectedFiles[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf,
                          color: Colors.red),

                      title: Text(file.path.split('/').last),

                      /// Preview
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PdfMergePreviewScreen(file: file),
                          ),
                        );
                      },

                      /// Remove button
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeFile(index),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: mergePdf,
              child: const Text("Merge PDFs"),
            ),
          ],
        ),
      ),
    );
  }
}