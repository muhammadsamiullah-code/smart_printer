import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import '../../../ads/native_ads_widget.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/success_dialoge.dart';

class DeletePdfPagesScreen extends StatefulWidget {
  final File file;
  final String title;
  const DeletePdfPagesScreen({
    super.key,
    required this.file,
    required this.title,
  });

  @override
  State<DeletePdfPagesScreen> createState() => _DeletePdfPagesScreenState();
}

class _DeletePdfPagesScreenState extends State<DeletePdfPagesScreen> {
  pdfx.PdfDocument? document;
  int totalPages = 0;
  Set<int> selectedPages = {};
  Map<int, Uint8List> thumbnails = {};

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    document = await pdfx.PdfDocument.openFile(widget.file.path);
    totalPages = document!.pagesCount;

    // preload first thumbnails
    for (int i = 0; i < totalPages && i < 12; i++) {
      generateThumbnail(i);
    }

    setState(() {});
  }

  Future<void> generateThumbnail(int pageIndex) async {
    if (thumbnails.containsKey(pageIndex)) return;

    final page = await document!.getPage(pageIndex + 1);
    final img = await page.render(
      width: page.width,
      height: page.height,
      format: pdfx.PdfPageImageFormat.png,
    );
    await page.close();

    thumbnails[pageIndex] = img!.bytes;

    if (mounted) setState(() {});
  }

  void togglePage(int index) {
    setState(() {
      if (selectedPages.contains(index)) {
        selectedPages.remove(index);
      } else {
        selectedPages.add(index);
      }
    });
  }

  /// DELETE SELECTED PAGES AND SHOW LOADER + SUCCESS
  Future<void> deletePages() async {
    if (selectedPages.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );

    final bytes = await widget.file.readAsBytes();
    final sfpdf.PdfDocument pdf = sfpdf.PdfDocument(inputBytes: bytes);

    final sorted = selectedPages.toList()..sort((a, b) => b.compareTo(a));
    for (var pageIndex in sorted) {
      pdf.pages.removeAt(pageIndex);
    }

    final dir = await getApplicationDocumentsDirectory();
    final newFile = File(
      "${dir.path}/deleted_pages_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await newFile.writeAsBytes(await pdf.save());
    pdf.dispose();

    if (mounted) Navigator.pop(context); // Close loader

    // Show success dialog
    SuccessDialog.show(context, newFile);
  }

  Widget buildThumbnail(int index) {
    if (!thumbnails.containsKey(index)) generateThumbnail(index);

    return thumbnails.containsKey(index)
        ? Image.memory(thumbnails[index]!, fit: BoxFit.cover)
        : const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (document == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: widget.title, actions: [

  ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.5,
        ),
        itemCount: totalPages,
        itemBuilder: (context, index) {
          bool selected = selectedPages.contains(index);

          return GestureDetector(
            onTap: () => togglePage(index),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? AppColors.primaryColor : Colors.grey,
                  width: selected ? 3 : 1,
                ),
              ),
              child: Column(
                children: [
                  Expanded(child: buildThumbnail(index)),
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: Text("Page ${index + 1}"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              onPressed: selectedPages.isNotEmpty ? deletePages : null,
              text: "delete",
            ),
            SizedBox(height: 10),
            SquareNativeAdWidget(),
          ],
        ),
      ),
    );
  }
}
