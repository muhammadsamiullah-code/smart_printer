
import 'dart:io';
import 'package:flutter/foundation.dart'; // needed for compute
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../../../widgets/success_dialoge.dart';

/// The data we pass to the isolate
class PdfIsolateData {
  final List<File> images;
  final String outputPath;

  PdfIsolateData({required this.images, required this.outputPath});
}

/// Function that runs in the isolate
Future<void> _generatePdfInIsolate(PdfIsolateData data) async {
  final pdf = pw.Document();

  for (var file in data.images) {
    final bytes = await file.readAsBytes();

    // Decode image to get width & height
    final decodedImage = await decodeImageFromList(bytes);

    final image = pw.MemoryImage(bytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          decodedImage.width.toDouble(),
          decodedImage.height.toDouble(),
        ),
        build: (context) => pw.Image(image),
      ),
    );
  }

  final pdfBytes = await pdf.save();
  final outFile = File(data.outputPath);
  await outFile.writeAsBytes(pdfBytes);
}

/// Main function to call from UI
Future<void> convertPdf(List<File> images, BuildContext context) async {
  if (images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select images")),
    );
    return;
  }

  // Show loader
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final dir = await getApplicationDocumentsDirectory();
    final outputFile =
        "${dir.path}/image_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf";

    // Run heavy PDF creation in isolate
    await compute(
      _generatePdfInIsolate,
      PdfIsolateData(images: images, outputPath: outputFile),
    );

    Navigator.pop(context); // remove loader

    // Show success dialog
    SuccessDialog.show(context, File(outputFile));
  } catch (e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}