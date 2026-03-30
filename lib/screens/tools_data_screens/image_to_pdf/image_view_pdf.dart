
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ImageViewPdf extends StatefulWidget {
  final File file;
  const ImageViewPdf({super.key, required this.file});

  @override
  State<ImageViewPdf> createState() => _ImageViewPdfState();
}

class _ImageViewPdfState extends State<ImageViewPdf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: SfPdfViewer.file(widget.file),
    );
  }
}