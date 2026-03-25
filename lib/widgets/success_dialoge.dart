
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_scanner/widgets/custom_button.dart';

import '../screens/tools_data_screens/merge_pdf/pdf_preview_screen.dart';
import 'tr_text.dart';

class SuccessDialog {
  static void show(BuildContext context, File file) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/imageIcons/checkBox.svg', height: 60, width: 60,),

              const SizedBox(height: 20),

              const Text(
                "File Saved Successfully",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  file.path.split('/').last,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _buildOption(
                    icon: 'assets/imageIcons/file.svg',
                    label: "open_file",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PdfPreviewPrintScreen(file: file),
                        ),
                      );
                    },
                  ),
                  _buildOption(
                    icon: 'assets/imageIcons/share.svg',
                    label: "share",
                    onTap: () {
                      SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(file.path)],
                        ),
                      );
                    },
                  ),
                  _buildOption(
                    icon: 'assets/imageIcons/print.svg',
                    label: "print",
                    onTap: () async {
                      await Printing.layoutPdf(
                        onLayout: (_) async =>
                            file.readAsBytes(),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CustomButton(text: "done", onPressed: (){
                   Navigator.pop(context);
                      Navigator.pop(context, true);
                }),
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
         SvgPicture.asset(icon, height: 30, width: 30,),
         
          const SizedBox(height: 5),
          TrText(label, style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),),
        ],
      ),
    );
  }
}