import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:printing/printing.dart';

class PdfViewScanScreen extends StatefulWidget {
  final String pdfPath;

  const PdfViewScanScreen({
    super.key,
    required this.pdfPath,
  });

  @override
  State<PdfViewScanScreen> createState() => _PdfViewScanScreenState();
}

class _PdfViewScanScreenState extends State<PdfViewScanScreen> {
  bool _isPrinting = false;

  Future<void> printPdf() async {
    setState(() => _isPrinting = true);

    try {
      final file = File(widget.pdfPath);
      final bytes = await file.readAsBytes();

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Printer not available")),
      );
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanned Document"),
        backgroundColor: const Color(0xff0D5DB8),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, size: 28),
            onPressed: _isPrinting ? null : printPdf,
          ),
        ],
      ),
      body: SfPdfViewer.file(File(widget.pdfPath)),
    );
  }
}