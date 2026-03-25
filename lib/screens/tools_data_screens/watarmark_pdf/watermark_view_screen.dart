import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pdfx;

class WatermarkViewScreen extends StatefulWidget {
  final File file;

  const WatermarkViewScreen({super.key, required this.file});

  @override
  State<WatermarkViewScreen> createState() =>
      _WatermarkViewScreenState();
}

class _WatermarkViewScreenState extends State<WatermarkViewScreen> {
  pdfx.PdfControllerPinch? pdfController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    pdfController = pdfx.PdfControllerPinch(
      document: pdfx.PdfDocument.openFile(widget.file.path),
    );
  }

  @override
  void dispose() {
    pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Watermark PDF"),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: pdfx.PdfViewPinch(
              controller: pdfController!,
              onDocumentLoaded: (_) {
                setState(() => isLoading = false);
              },
              builders:
                  pdfx.PdfViewPinchBuilders<pdfx.DefaultBuilderOptions>(
                options: const pdfx.DefaultBuilderOptions(),
                documentLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, error) =>
                    Center(child: Text(error.toString())),
              ),
            ),
          ),

          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}