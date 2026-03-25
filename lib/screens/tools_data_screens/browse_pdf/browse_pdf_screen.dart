import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/success_dialoge.dart';
import '../../../widgets/tr_text.dart';

class BrowswePDFScreen extends StatefulWidget {
  final String title;
  const BrowswePDFScreen({super.key, required this.title});

  @override
  State<BrowswePDFScreen> createState() => _BrowswePDFScreenState();
}

class _BrowswePDFScreenState extends State<BrowswePDFScreen> {
  late final WebViewController _controller;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.google.com'));
  }

  /// Convert captured image to PDF
  Future<File?> _captureWebPageAsPdf() async {
    try {
      final image = await _screenshotController.capture();
      if (image == null) return null;

      // Create PDF document
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();

      // Draw the image
      page.graphics.drawImage(
        PdfBitmap(image),
        Rect.fromLTWH(
          0,
          0,
          page.getClientSize().width,
          page.getClientSize().height,
        ),
      );

      // Save PDF file
      final dir = await getApplicationDocumentsDirectory();
      final file = File(
        '${dir.path}/web_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await document.save());
      document.dispose();

      return file;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: CustomAppBar(
        title: widget.title,
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.picture_as_pdf,
        //       size: 28,
        //       color: Colors.black,
        //     ),
        //     onPressed: () async {
        //       /// SHOW LOADER
        //       showDialog(
        //         context: context,
        //         barrierDismissible: false,
        //         builder: (_) =>
        //             const Center(child: CircularProgressIndicator()),
        //       );

        //       final file = await _captureWebPageAsPdf();

        //       /// CLOSE LOADER
        //       if (mounted) Navigator.pop(context);

        //       if (file != null) {
        //         /// SMALL DELAY (smooth transition)
        //         await Future.delayed(const Duration(milliseconds: 200));

        //         /// SUCCESS
        //         SuccessDialog.show(context, file);
        //       } else {
        //         ScaffoldMessenger.of(context).showSnackBar(
        //           const SnackBar(content: Text("Failed to create PDF")),
        //         );
        //       }
        //     },
        //   ),
        // ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: WebViewWidget(controller: _controller),
      ),
      bottomNavigationBar: Container(
              padding: const EdgeInsets.all(12),
              // height: 80,
              child: CustomButton(
              
                 onPressed: () async {
                            /// SHOW LOADER
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) =>
              const Center(child: CircularProgressIndicator()),
                            );
              
                            final file = await _captureWebPageAsPdf();
              
                            /// CLOSE LOADER
                            if (mounted) Navigator.pop(context);
              
                            if (file != null) {
                              /// SMALL DELAY (smooth transition)
                              await Future.delayed(const Duration(milliseconds: 200));
              
                              /// SUCCESS
                              SuccessDialog.show(context, file);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: TrText("failed_to_create_pdf")),
                              );
                            }
                          },
                text: "convert_pdf",
              ),
            ),
    );
  }
}
