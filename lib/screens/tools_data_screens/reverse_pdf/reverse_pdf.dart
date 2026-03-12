
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../merge_pdf/pdf_results_screen.dart';

class ReversePdfScreen extends StatefulWidget {
  const ReversePdfScreen({super.key});

  @override
  State<ReversePdfScreen> createState() => _ReversePdfScreenState();
}

class _ReversePdfScreenState extends State<ReversePdfScreen> {

  File? selectedFile;
  int totalPages = 0;

  /// PICK PDF
  Future<void> pickPdf() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {

      selectedFile = File(result.files.single.path!);

      final bytes = await selectedFile!.readAsBytes();

      final PdfDocument document = PdfDocument(inputBytes: bytes);

      setState(() {
        totalPages = document.pages.count;
      });

      document.dispose();
    }
  }

  /// REVERSE PDF
  Future<void> reversePdf() async {

    if (selectedFile == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a PDF")),
      );

      return;
    }

    final bytes = await selectedFile!.readAsBytes();

    final PdfDocument oldPdf = PdfDocument(inputBytes: bytes);

    final PdfDocument newPdf = PdfDocument();

    /// Reverse pages
    for (int i = oldPdf.pages.count - 1; i >= 0; i--) {

      newPdf.pages.add().graphics.drawPdfTemplate(
        oldPdf.pages[i].createTemplate(),
        const Offset(0, 0),
      );
    }

    final dir = await getApplicationDocumentsDirectory();

    final outputFile = File(
      "${dir.path}/reversed_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await outputFile.writeAsBytes(await newPdf.save());

    oldPdf.dispose();
    newPdf.dispose();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ResultScreen(),
      ),
    );
  }

  /// FILE SIZE
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
      appBar: AppBar(
        title: const Text("Reverse PDF"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ElevatedButton(
              onPressed: pickPdf,
              child: const Text("Select PDF"),
            ),

            const SizedBox(height: 20),

            if (selectedFile != null) ...[

              Text(
                "File: ${selectedFile!.path.split('/').last}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              Text(
                "Size: ${getFileSize(selectedFile!)}",
              ),

              const SizedBox(height: 5),

              Text(
                "Total Pages: $totalPages",
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: reversePdf,
                  child: const Text("Reverse PDF"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}