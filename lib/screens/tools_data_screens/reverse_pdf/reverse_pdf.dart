import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../const/color.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/success_dialoge.dart';
import '../merge_pdf/pdf_preview_screen.dart';

class ReversePdfScreen extends StatefulWidget {
  final List<File> selectedFiles;
  final String title;

  const ReversePdfScreen({
    super.key,
    required this.selectedFiles,
    required this.title,
  });

  @override
  State<ReversePdfScreen> createState() => _ReversePdfScreenState();
}

class _ReversePdfScreenState extends State<ReversePdfScreen> {
  late List<File> selectedFiles;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    selectedFiles = widget.selectedFiles;
  }

  /// REVERSE ALL FILES
  // Future<void> reverseAll() async {
  //   if (selectedFiles.isEmpty) return;

  //   /// 🔥 SHOW LOADER
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => const Center(child: CircularProgressIndicator()),
  //   );

  //   for (final file in selectedFiles) {
  //     final bytes = await file.readAsBytes();

  //     final oldPdf = PdfDocument(inputBytes: bytes);
  //     final newPdf = PdfDocument();

  //     for (int i = oldPdf.pages.count - 1; i >= 0; i--) {
  //       newPdf.pages.add().graphics.drawPdfTemplate(
  //         oldPdf.pages[i].createTemplate(),
  //         const Offset(0, 0),
  //       );
  //     }

  //     final dir = await getApplicationDocumentsDirectory();

  //     final output = File(
  //       "${dir.path}/reversed_${DateTime.now().millisecondsSinceEpoch}.pdf",
  //     );

  //     await output.writeAsBytes(await newPdf.save());

  //     oldPdf.dispose();
  //     newPdf.dispose();
  //     Navigator.pop(context);

  //     /// SHOW SUCCESS (last file)
  //     SuccessDialog.show(context, output);
  //   }
  // }
  Future<void> reverseAll() async {
    if (selectedFiles.isEmpty) return;

    /// 🔥 SHOW LOADER
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
    );

    for (final file in selectedFiles) {
      final bytes = await file.readAsBytes();

      final oldPdf = PdfDocument(inputBytes: bytes);
      final newPdf = PdfDocument();

      for (int i = oldPdf.pages.count - 1; i >= 0; i--) {
        final newPage = newPdf.pages.add();
        final template = oldPdf.pages[i].createTemplate();

        final width = newPage.getClientSize().width;
        final height = newPage.getClientSize().height;

        newPage.graphics.drawPdfTemplate(
          template,
          Offset.zero, // top-left
          Size(width, height), // full page scaling
        );
      }

      final dir = await getApplicationDocumentsDirectory();

      final output = File(
        "${dir.path}/reversed_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await output.writeAsBytes(await newPdf.save());

      oldPdf.dispose();
      newPdf.dispose();
      /// CLOSE LOADER (after each file)
      Navigator.pop(context);
      /// SHOW SUCCESS (last file)
      SuccessDialog.show(context, output);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: selectedFiles.length,
        itemBuilder: (_, index) {
          final file = selectedFiles[index];
          final fileName = file.path.split('/').last;
          return PdfListCard(
            title: fileName,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PdfPreviewPrintScreen(file: file),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 80,
        child: CustomButton(onPressed: reverseAll, text: "reverse_pages"),
      ),
    );
  }
}
