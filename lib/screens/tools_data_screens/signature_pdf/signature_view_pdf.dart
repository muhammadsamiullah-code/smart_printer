
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

// class SignatureViewPdf extends StatefulWidget {
//   final File file;
//   const SignatureViewPdf({super.key, required this.file});

//   @override
//   State<SignatureViewPdf> createState() => _SignatureViewPdfState();
// }

// class _SignatureViewPdfState extends State<SignatureViewPdf> {

//   bool isLoading = true;

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("View Signed PDF"),
//       ),

//       body: Stack(
//         children: [

//           PDFView(
//             filePath: widget.file.path,

//             onRender: (_) {
//               setState(() {
//                 isLoading = false;
//               });
//             },
//           ),

//           if (isLoading)
//             const Center(
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }
// }