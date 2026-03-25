import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/success_dialoge.dart';

class RotatePdfScreen extends StatefulWidget {
  final List<File> selectedFiles;
  final String title;

  const RotatePdfScreen({
    super.key,
    required this.selectedFiles,
    required this.title,
  });

  @override
  State<RotatePdfScreen> createState() => _RotatePdfScreenState();
}

class _RotatePdfScreenState extends State<RotatePdfScreen> {
  late List<File> files;

  int currentIndex = 0;

  pdfx.PdfControllerPinch? controller;

  int rotationAngle = 0;
  int selectedRotation = -1; // default Reset selected
  File? get selectedFile => files.isNotEmpty ? files[currentIndex] : null;

  @override
  void initState() {
    super.initState();
    files = widget.selectedFiles;

    if (files.isNotEmpty) {
      loadPdf(files[0]);
    }
  }

  /// LOAD PDF
  void loadPdf(File file) {
    controller = pdfx.PdfControllerPinch(
      document: pdfx.PdfDocument.openFile(file.path),
    );
    rotationAngle = 0;
    setState(() {});
  }

  /// CHANGE ROTATION
  void setRotation(int angle) {
    setState(() {
      rotationAngle = angle;
      selectedRotation = angle;
    });
  }

  /// APPLY ROTATION (CURRENT FILE)
  Future<void> applyRotation() async {
    if (selectedFile == null) return;

    /// LOADER
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final bytes = await selectedFile!.readAsBytes();

    final sfpdf.PdfDocument pdf = sfpdf.PdfDocument(inputBytes: bytes);

    for (int i = 0; i < pdf.pages.count; i++) {
      final page = pdf.pages[i];

      if (rotationAngle == 90) {
        page.rotation = sfpdf.PdfPageRotateAngle.rotateAngle90;
      } else if (rotationAngle == 180) {
        page.rotation = sfpdf.PdfPageRotateAngle.rotateAngle180;
      } else if (rotationAngle == 270) {
        page.rotation = sfpdf.PdfPageRotateAngle.rotateAngle270;
      }
    }

    final dir = await getApplicationDocumentsDirectory();

    final newFile = File(
      "${dir.path}/rotated_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await newFile.writeAsBytes(await pdf.save());

    pdf.dispose();

    /// CLOSE LOADER
    if (mounted) Navigator.pop(context);

    /// SUCCESS
    SuccessDialog.show(context, newFile);
  }

  Widget buildRotateButton(String text, int angle) {
    final isSelected = selectedRotation == angle;

    return GestureDetector(
      onTap: () => setRotation(angle),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey,
            width: 1.5,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: Column(
        children: [
          /// 🔹 LIVE PREVIEW
          if (selectedFile != null && controller != null)
            Expanded(
              child: Transform.rotate(
                angle: rotationAngle * pi / 180,
                child: pdfx.PdfViewPinch(controller: controller!),
              ),
            ),

          if (selectedFile != null) ...[
            const SizedBox(height: 10),

            /// 🔹 ROTATION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildRotateButton("90°", 90),
                buildRotateButton("180°", 180),
                buildRotateButton("270°", 270),
                buildRotateButton("Reset", 0),
              ],
            ),

            const SizedBox(height: 10),

            /// 🔹 CONFIRM BUTTON
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(onPressed: applyRotation, text: "rotate_pdf"),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
