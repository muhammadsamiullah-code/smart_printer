
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../merge_pdf/pdf_results_screen.dart';

class ImageToPdfScreen extends StatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {

  final ImagePicker picker = ImagePicker();

  List<File> images = [];

  /// Pick Images
  Future<void> pickImages() async {

    final List<XFile>? pickedImages = await picker.pickMultiImage();

    if (pickedImages != null) {

      setState(() {
        images.addAll(
          pickedImages.map((e) => File(e.path)),
        );
      });
    }
  }

  /// Remove image
  void removeImage(int index) {

    setState(() {
      images.removeAt(index);
    });
  }

  /// Convert Image to PDF
  Future<void> convertPdf() async {

    if (images.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select images")),
      );

      return;
    }

    final PdfDocument document = PdfDocument();

    for (var img in images) {

      final bytes = await img.readAsBytes();

      final PdfBitmap bitmap = PdfBitmap(bytes);

      final page = document.pages.add();

      page.graphics.drawImage(
        bitmap,
        Rect.fromLTWH(
          0,
          0,
          page.getClientSize().width,
          page.getClientSize().height,
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/image_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await document.save());

    document.dispose();

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
      appBar: AppBar(title: const Text("Image to PDF")),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [

            /// Add Images
            ElevatedButton(
              onPressed: pickImages,
              child: const Text("Select Images"),
            ),

            const SizedBox(height: 10),

            /// Image Preview Grid
            Expanded(
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),

                itemBuilder: (context, index) {

                  return Stack(
                    children: [

                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      /// Remove Button
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => removeImage(index),

                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            /// Add More Images
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: pickImages,
                child: const Text("Add More Images"),
              ),
            ),

            const SizedBox(height: 10),

            /// Convert PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: convertPdf,
                child: const Text("Convert to PDF"),
              ),
            )
          ],
        ),
      ),
    );
  }
}