
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfPageThumbnail extends StatefulWidget {
  final PdfDocument document;
  final int pageNumber;

  const PdfPageThumbnail({
    super.key,
    required this.document,
    required this.pageNumber,
  });

  @override
  State<PdfPageThumbnail> createState() => _PdfPageThumbnailState();
}

class _PdfPageThumbnailState extends State<PdfPageThumbnail> {
  Uint8List? bytes;

  @override
  void initState() {
    super.initState();
    _render();
  }

  Future<void> _render() async {
    final page = await widget.document.getPage(widget.pageNumber);

    final img = await page.render(
      width: page.width,
      height: page.height,
      format: PdfPageImageFormat.png,
    );

    setState(() => bytes = img!.bytes);

    await page.close();
  }

  @override
  Widget build(BuildContext context) {
    return bytes == null
        ? const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          )
        : Image.memory(bytes!);
  }
}
