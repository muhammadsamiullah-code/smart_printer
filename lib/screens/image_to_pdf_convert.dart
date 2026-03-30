
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_to_pdf_converter/image_to_pdf_converter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'tools_data_screens/merge_pdf/pdf_preview_screen.dart';

/// ---------------- HOME SCREEN ----------------
class ImageToPDFConvert extends StatefulWidget {
  const ImageToPDFConvert({super.key});

  @override
  State<ImageToPDFConvert> createState() => _ImageToPDFConvertState();
}

class _ImageToPDFConvertState extends State<ImageToPDFConvert> {
    List<File> pdfFiles = [];

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      final images = picked.map((e) => File(e.path)).toList();

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewScreen(images: images),
        ),
      );

      if (result != null && result is File) {
        setState(() {
          pdfFiles.add(result);
        });
      }
    }
  }

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image to PDF")),
      body: pdfFiles.isEmpty
          ? const Center(child: Text("No files selected"))
          : ListView.builder(
              itemCount: pdfFiles.length,
              itemBuilder: (context, index) {
                final file = pdfFiles[index];
                final name = file.path.split('/').last;

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(name),
                    leading: const Icon(Icons.picture_as_pdf),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfPreviewPrintScreen(file: file),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImages,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// ---------------- PREVIEW SCREEN ----------------


class PreviewScreen extends StatefulWidget {
  final List<File> images;

  const PreviewScreen({super.key, required this.images});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool isLoading = false;

  Future<void> convertToPdf() async {
    setState(() => isLoading = true);

    final pdf = pw.Document();

    for (var file in widget.images) {
      final bytes = await file.readAsBytes();
      final image = pw.MemoryImage(bytes);

      final decoded = await decodeImageFromList(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            decoded.width.toDouble(),
            decoded.height.toDouble(),
          ),
          build: (context) => pw.Image(image),
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        "${dir.path}/pdf_${DateTime.now().millisecondsSinceEpoch}.pdf");

    await file.writeAsBytes(await pdf.save());

    setState(() => isLoading = false);

    Navigator.pop(context, file); // send back to HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Images")),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: widget.images.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return Image.file(widget.images[index], fit: BoxFit.cover);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: isLoading ? null : convertToPdf,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Convert to PDF"),
            ),
          )
        ],
      ),
    );
  }
}

