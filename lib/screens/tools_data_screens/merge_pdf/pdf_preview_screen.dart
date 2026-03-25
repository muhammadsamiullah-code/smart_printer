
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:pdfx/pdfx.dart';
import 'package:smart_scanner/widgets/custom_appbar.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../widgets/custom_button.dart';

class PdfPreviewPrintScreen extends StatefulWidget {
  final File file;

  const PdfPreviewPrintScreen({super.key, required this.file});

  @override
  State<PdfPreviewPrintScreen> createState() =>
      _PdfPreviewPrintScreenState();
}

class _PdfPreviewPrintScreenState extends State<PdfPreviewPrintScreen> {
  bool _isPrinting = false;

  PdfDocument? _document;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      _document = await PdfDocument.openFile(widget.file.path);
    } catch (e) {
      debugPrint("PDF load error: $e");
    }
  }

  /// 🔹 Build printable PDF (ALL pages)
  Future<Uint8List> buildPrintablePdf() async {
    final pdf = pw.Document();

    if (_document == null) return pdf.save();

    for (int i = 1; i <= _document!.pagesCount; i++) {
      final page = await _document!.getPage(i);

      final img = await page.render(
        width: page.width,
        height: page.height,
      );

      final image = pw.MemoryImage(img!.bytes);

      pdf.addPage(
        pw.Page(
          build: (_) => pw.Center(child: pw.Image(image)),
        ),
      );

      await page.close();
    }

    return pdf.save();
  }

  /// 🔹 Print Function
  Future<void> printAllPages() async {
    setState(() => _isPrinting = true);

    try {
      final pdfBytes = await buildPrintablePdf();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Printing failed")),
      );
    } finally {
      setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(
            title: widget.file.path.split('/').last,
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.print),
            //     onPressed: printAllPages,
            //     color: Colors.black,
            //     iconSize: 36,
            //   ),
            // ],
          ),

          /// 🔹 Smooth scroll enabled
          body: SfPdfViewer.file(
            widget.file,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            pageSpacing: 4,
          ),
          bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 80,
        child: CustomButton(
          onPressed: printAllPages,
          text: "print",
        ),
      ),
        ),

        /// 🔹 Loader Overlay
        if (_isPrinting)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _document = null;
    super.dispose();
  }
}