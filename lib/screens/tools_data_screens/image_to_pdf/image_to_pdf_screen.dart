
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../const/color.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/success_dialoge.dart';
import 'package:image/image.dart' as img;


class ImageToPdfScreen extends StatefulWidget {
    final List<File> images;
    final String title;

  const ImageToPdfScreen({super.key,  required this.images, required this.title});

  @override
  State<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends State<ImageToPdfScreen> {

  final ImagePicker picker = ImagePicker();

late List<File> images;

@override
void initState() {
  super.initState();
  images = [...widget.images];
}
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
//   Future<void> convertPdf() async {
//   if (images.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please select images")),
//     );
//     return;
//   }

//   /// 🔥 SHOW LOADER
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (_) =>
//         const Center(child: CircularProgressIndicator()),
//   );

//   final PdfDocument document = PdfDocument();

//   for (var img in images) {
//     final bytes = await img.readAsBytes();
//     final PdfBitmap bitmap = PdfBitmap(bytes);

//     final page = document.pages.add();

//     page.graphics.drawImage(
//       bitmap,
//       Rect.fromLTWH(
//         0,
//         0,
//         page.getClientSize().width,
//         page.getClientSize().height,
//       ),
//     );
//   }

//   final dir = await getApplicationDocumentsDirectory();

//   final file = File(
//     "${dir.path}/image_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf",
//   );

//   await file.writeAsBytes(await document.save());

//   document.dispose();

//   Navigator.pop(context); // ❌ remove loader

//   /// ✅ SUCCESS DIALOG
//   SuccessDialog.show(context, file);
// }

Future<void> convertPdf() async {
  if (images.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select images")),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    final PdfDocument document = PdfDocument();

    for (var file in images) {
      final bytes = await file.readAsBytes();

      /// 🔥 DECODE IMAGE (fix unsupported issue)
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) continue;

      /// 🔥 CONVERT TO JPG
      final jpgBytes = img.encodeJpg(decodedImage);

      final PdfBitmap bitmap = PdfBitmap(jpgBytes);

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

    Navigator.pop(context); // remove loader

    SuccessDialog.show(context, file);
  } catch (e) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          children: [


            const SizedBox(height: 10),

            /// Image Preview Grid
            Expanded(
              child: GridView.builder(
                itemCount: images.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
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

          ],
        ),
      ),
       bottomNavigationBar: Container(
              padding: const EdgeInsets.all(12),
              height: 80,
              child: Row(
                children: [
                  Expanded(
                    child: CustomButtonWithBorder(
                      borderWidth: 1.5,
                      borderColor: AppColors.primaryColor,
                      onPressed: pickImages,
                      text: 'add_more',

                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: CustomButton(

                      onPressed: convertPdf,
                      text: "generate_pdf",
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}