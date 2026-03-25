import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../const/color.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/success_dialoge.dart';
import 'qr_scan_screen.dart';

class CreateQRPdfScreen extends StatefulWidget {
  final String title;
  const CreateQRPdfScreen({super.key, required this.title});

  @override
  State<CreateQRPdfScreen> createState() => _CreateQRPdfScreenState();
}

class _CreateQRPdfScreenState extends State<CreateQRPdfScreen> {
  final TextEditingController controller = TextEditingController();

  /// Create PDF
  Future<void> createPdf(String text) async {
    /// 🔥 SHOW LOADER
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(child: pw.Text(text));
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/qr_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    /// REMOVE LOADER
    Navigator.pop(context);

    if (!mounted) return;

    /// ✅ SHOW SUCCESS DIALOG
    SuccessDialog.show(context, file);
  }

  /// Open QR Scanner
  void openQRScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (result != null) {
      createPdf(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: controller,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Enter Text or URL",
                  border: InputBorder.none,
                ),
              ),
            ),

            // TextField(
            //   controller: controller,
            //   maxLines: 6, // 🔥 lines increase (jitni chaho set kar sakte ho)
            //   decoration: InputDecoration(
            //     hintText: "Enter Text or URL",
            //     filled: true,
            //     fillColor: Colors.white, // 🔥 white background
            //     border: InputBorder.none, // 🔥 border remove
            //     enabledBorder: InputBorder.none,
            //     focusedBorder: InputBorder.none,
            //   ),
            // ),
            const SizedBox(height: 20),

           
          ],
        ),
      ),
       bottomNavigationBar: Container(
              padding: const EdgeInsets.all(12),
              height: 110,
              child: Row(
                children: [
                  Expanded(
                    child: CustomButtonWithBorder(
                      borderWidth: 1.5,
                      borderColor: AppColors.primaryColor,
                      onPressed: openQRScanner,
                      text: 'scan_qr_code',

                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: CustomButton(

                        onPressed: () {
                if (controller.text.isNotEmpty) {
                  createPdf(controller.text);
                }
              },
                      text: "saved_as_pdf",
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
