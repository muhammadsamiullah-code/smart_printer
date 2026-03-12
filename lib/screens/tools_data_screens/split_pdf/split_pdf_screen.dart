
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../merge_pdf/pdf_results_screen.dart';

class SplitPdfScreen extends StatefulWidget {
  const SplitPdfScreen({super.key});

  @override
  State<SplitPdfScreen> createState() => _SplitPdfScreenState();
}

class _SplitPdfScreenState extends State<SplitPdfScreen> {

  File? selectedFile;
  int totalPages = 0;

  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  /// Pick PDF
  Future<void> pickFile() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {

      final file = File(result.files.single.path!);

      final bytes = await file.readAsBytes();

      final document = PdfDocument(inputBytes: bytes);

      setState(() {
        selectedFile = file;
        totalPages = document.pages.count;
      });

      document.dispose();
    }
  }

  /// Split PDF
  Future<void> splitPdf() async {

    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a PDF")),
      );
      return;
    }

    int start = int.tryParse(startController.text) ?? 0;
    int end = int.tryParse(endController.text) ?? 0;

    if (start < 1 || end > totalPages || start > end) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid page range")),
      );
      return;
    }

    final bytes = await selectedFile!.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    final newDoc = PdfDocument();

    for (int i = start - 1; i < end; i++) {

      newDoc.pages.add().graphics.drawPdfTemplate(
        document.pages[i].createTemplate(),
        const Offset(0, 0),
      );
    }

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/split_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await newDoc.save());

    document.dispose();
    newDoc.dispose();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ResultScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Split PDF")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Select file
            ElevatedButton(
              onPressed: pickFile,
              child: const Text("Select PDF"),
            ),

            const SizedBox(height: 20),

            if (selectedFile != null) ...[

              Text(
                "File: ${selectedFile!.path.split('/').last}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text("Total Pages: $totalPages"),

              const SizedBox(height: 20),

              /// Page Range
              Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: startController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Start Page",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                      controller: endController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "End Page",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Split Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: splitPdf,
                  child: const Text("Split PDF"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}