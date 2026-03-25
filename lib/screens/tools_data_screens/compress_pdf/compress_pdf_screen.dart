import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import 'package:pdfx/pdfx.dart';

import '../../../widgets/custom_appbar.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/success_dialoge.dart';
import '../merge_pdf/pdf_preview_screen.dart';

class CompressPdfScreen extends StatefulWidget {
  final String title;
  final List<File> selectedFiles;

  const CompressPdfScreen({super.key, required this.selectedFiles, required this.title});

  @override
  State<CompressPdfScreen> createState() =>
      _CompressPdfScreenState();
}

class _CompressPdfScreenState extends State<CompressPdfScreen> {

  late List<File> selectedFiles;

  /// ✅ Compression Level
  String selectedLevel = "Medium";

  @override
  void initState() {
    super.initState();
    selectedFiles = widget.selectedFiles;
  }

  /// ✅ GET QUALITY BASED ON LEVEL
  int getQuality() {
    switch (selectedLevel) {
      case "Low":
        return 70; // less compression
      case "High":
        return 30; // high compression
      default:
        return 50; // medium
    }
  }

  /// COMPRESS ALL FILES
  Future<void> compressAll() async {

    if (selectedFiles.isEmpty) return;

    /// LOADER
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator()),
    );

    File? lastFile;

    for (final file in selectedFiles) {

      final pdf = await PdfDocument.openFile(file.path);
      final newPdf = sfpdf.PdfDocument();

      for (int i = 1; i <= pdf.pagesCount; i++) {

        final page = await pdf.getPage(i);

        final img = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.jpeg,
        );

        /// ✅ DYNAMIC QUALITY
        final compressed =
            await FlutterImageCompress.compressWithList(
          img!.bytes,
          quality: getQuality(),
        );

        final newPage = newPdf.pages.add();

        newPage.graphics.drawImage(
          sfpdf.PdfBitmap(compressed),
          Rect.fromLTWH(
            0,
            0,
            newPage.getClientSize().width,
            newPage.getClientSize().height,
          ),
        );

        await page.close();
      }

      final dir = await getApplicationDocumentsDirectory();

      lastFile = File(
        "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await lastFile.writeAsBytes(await newPdf.save());

      newPdf.dispose();
    }

    /// CLOSE LOADER
    if (mounted) Navigator.pop(context);

    /// SUCCESS
    if (lastFile != null) {
      SuccessDialog.show(context, lastFile);
    }
  }

  /// FILE SIZE
  String getFileSize(File file) {
    int bytes = file.lengthSync();
    double kb = bytes / 1024;
    double mb = kb / 1024;

    if (mb >= 1) {
      return "${mb.toStringAsFixed(2)} MB";
    } else {
      return "${kb.toStringAsFixed(2)} KB";
    }
  }

  /// ✅ LEVEL UI
  Widget buildLevelButton(String level) {

    bool isSelected = selectedLevel == level;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedLevel = level;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor: Colors.grey,
            ),
          ),
          child: Column(
            children: [
              Text(
                level,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),

              /// Small hint
              Text(
                level == "Low"
                    ? "Better Quality"
                    : level == "Medium"
                        ? "Balanced"
                        : "Smaller Size",
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
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

          /// ✅ LEVEL SELECTOR
         

          /// FILE LIST
          ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(12),
            itemCount: selectedFiles.length,
            itemBuilder: (_, index) {
              final file = selectedFiles[index];
              final fileName = file.path.split('/').last;
              return PdfListCard(
                
                  title: fileName,
          
                  subtitle:
                      Text(getFileSize(file)),
          
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PdfPreviewPrintScreen(file: file),
                      ),
                    );
                  },
              
              );
            },
          ),
           Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                buildLevelButton("Low"),
                buildLevelButton("Medium"),
                buildLevelButton("High"),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 80,
        child: CustomButton(
          onPressed: compressAll,
          text: "compress_pdf",
        ),
      ),
    );
  }
}