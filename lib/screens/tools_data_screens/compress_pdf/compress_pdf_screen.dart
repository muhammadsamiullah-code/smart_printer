import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import '../merge_pdf/pdf_results_screen.dart';
import 'package:pdfx/pdfx.dart';

class CompressPdfScreen extends StatefulWidget {
  const CompressPdfScreen({super.key});

  @override
  State<CompressPdfScreen> createState() => _CompressPdfScreenState();
}

class _CompressPdfScreenState extends State<CompressPdfScreen> {
  File? selectedFile;

  Future<void> pickPdf() async {

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> compressPdf() async {

    if (selectedFile == null) return;

    final pdf = await PdfDocument.openFile(selectedFile!.path);

    final sfpdf.PdfDocument newPdf = sfpdf.PdfDocument();

    for (int i = 1; i <= pdf.pagesCount; i++) {

      final page = await pdf.getPage(i);

      final pageImage = await page.render(
        width: page.width,
        height: page.height,
        format: PdfPageImageFormat.jpeg,
      );

      Uint8List imageBytes = pageImage!.bytes;

      final compressed = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: 40,
      );

      final bitmap = sfpdf.PdfBitmap(compressed);

      final newPage = newPdf.pages.add();

      newPage.graphics.drawImage(
        bitmap,
        Rect.fromLTWH(
          0,
          0,
          newPage.getClientSize().width,
          newPage.getClientSize().height,
        ),
      );

      await page.close();
    }

    final dir = await getApplicationDocumentsDirectory();

    final outputFile = File(
      "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await outputFile.writeAsBytes(await newPdf.save());

    newPdf.dispose();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ResultScreen(),
      ),
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
      appBar: AppBar(title: const Text("Compress PDF")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(onPressed: pickPdf, child: const Text("Select PDF")),

            const SizedBox(height: 20),

            if (selectedFile != null) ...[
              Text(
                "File: ${selectedFile!.path.split('/').last}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 5),

              Text("Size: ${getFileSize(selectedFile!)}"),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: compressPdf,
                  child: const Text("Compress PDF"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
