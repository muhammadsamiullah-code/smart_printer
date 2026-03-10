import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/models/labels_shape.dart';
import 'package:smart_scanner/providers/labels_provider.dart';
import 'package:smart_scanner/screens/pdf_label_preview_screen.dart';

class LabelImagePickerScreen extends StatefulWidget {
  const LabelImagePickerScreen({super.key});

  @override
  State<LabelImagePickerScreen> createState() => _LabelImagePickerScreenState();
}

class _LabelImagePickerScreenState extends State<LabelImagePickerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      _cropImage(File(picked.path));
    }
  }
  Future<void> _cropImage(File imageFile) async {
  final provider = Provider.of<LabelProvider>(context, listen: false);
  final shape = provider.selectedShape;

  CropAspectRatio? ratio;

  switch (shape) {
    case LabelShape.square:
      ratio = const CropAspectRatio(ratioX: 1, ratioY: 1);
      break;

    case LabelShape.round:
      ratio = const CropAspectRatio(ratioX: 1, ratioY: 1);
      break;

    case LabelShape.rectangle:
      ratio = const CropAspectRatio(ratioX: 4, ratioY: 2); 
      break;

    case LabelShape.oval:
      ratio = const CropAspectRatio(ratioX: 1, ratioY: 1);
      break;
    case null:
      // TODO: Handle this case.
      throw UnimplementedError();
  }

  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    aspectRatio: ratio,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.blue,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: true,
      ),
      IOSUiSettings(
        title: 'Crop Image',
      ),
    ],
  );

  if (croppedFile != null) {
    setState(() {
      _image = File(croppedFile.path);
    });

    provider.setImage(_image!);
  }
}
  // Future<void> _cropImage(File imageFile) async {
  //   final provider = Provider.of<LabelProvider>(context, listen: false);

  //   final croppedFile = await ImageCropper().cropImage(
  //     sourcePath: imageFile.path,
  //     aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  //     uiSettings: [
  //       AndroidUiSettings(
  //         toolbarTitle: 'Crop Image',
  //         toolbarColor: Colors.blue,
  //         toolbarWidgetColor: Colors.white,
  //       ),
  //       IOSUiSettings(title: 'Crop Image'),
  //     ],
  //   );

  //   if (croppedFile != null) {
  //     setState(() {
  //       _image = File(croppedFile.path);
  //     });

  //     provider.setImage(_image!);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LabelProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Select Image")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: _image == null
                  ? GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text("Tap to Select Image"),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_image!, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // ElevatedButton(
                        //   onPressed: _pickImage,
                        //   child: const Text("Change Image"),
                        // ),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.selectedImage == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PdfLabelPreviewScreen(),
                          ),
                        );
                      },
                child: const Text("Generate PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// class LabelImagePickerScreen extends StatefulWidget {
//   const LabelImagePickerScreen({super.key});

//   @override
//   State<LabelImagePickerScreen> createState() => _LabelImagePickerScreenState();
// }

// class _LabelImagePickerScreenState extends State<LabelImagePickerScreen> {
//   final ImagePicker _picker = ImagePicker();
//   File? _image;

//   Future<void> _pickImage() async {
//     final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

//     if (picked != null) {
//       _cropImage(File(picked.path));
//     }
//   }

//   Future<void> _cropImage(File imageFile) async {
//     final provider = Provider.of<LabelProvider>(context, listen: false);

//     final croppedFile = await ImageCropper().cropImage(
//       sourcePath: imageFile.path,

//       // NEW API
//       aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),

//       uiSettings: [
//         AndroidUiSettings(
//           toolbarTitle: 'Crop Image',
//           toolbarColor: Colors.blue,
//           toolbarWidgetColor: Colors.white,
//           initAspectRatio: CropAspectRatioPreset.original,
//           lockAspectRatio: false,
//         ),
//         IOSUiSettings(title: 'Crop Image'),
//       ],
//     );

//     if (croppedFile != null) {
//       setState(() {
//         _image = File(croppedFile.path);
//       });

//       provider.setImage(_image!);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<LabelProvider>(context);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Select Image")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Expanded(
//               child: _image == null
//                   ? GestureDetector(
//                       onTap: _pickImage,
//                       child: Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             "Tap to Select Image",
//                             style: TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ),
//                     )
//                   : Column(
//                       children: [
//                         Expanded(
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Image.file(_image!, fit: BoxFit.contain),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: _pickImage,
//                           child: const Text("Change Image"),
//                         ),
//                       ],
//                     ),
//             ),

//             const SizedBox(height: 20),

//             /// Margin Slider
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Page Margin",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Slider(
//                   value: provider.pageMargin,
//                   min: 10,
//                   max: 50,
//                   divisions: 8,
//                   label: provider.pageMargin.toStringAsFixed(0),
//                   onChanged: (value) {
//                     provider.setMargin(value);
//                   },
//                 ),
//               ],
//             ),

//             const SizedBox(height: 10),

//             /// Next Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: provider.selectedImage == null
//                     ? null
//                     : () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const PdfLabelPreviewScreen(),
//                           ),
//                         );
//                       },
//                 child: const Text("Generate PDF"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
