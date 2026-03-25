
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:smart_scanner/const/color.dart';

import '../../../widgets/custom_appbar.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool scanned = false;
  bool allowScan = false;

  @override
  void initState() {
    super.initState();

    /// Small delay so camera stabilizes
    Future.delayed(const Duration(seconds: 3), () {
      allowScan = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'scan_qr_code'),

      body: Stack(
        children: [

          /// Camera
          MobileScanner(
            onDetect: (BarcodeCapture capture) {

              if (!allowScan) return;
              if (scanned) return;

              final barcode = capture.barcodes.first;
              final code = barcode.rawValue;

              if (code != null) {
                scanned = true;
                Navigator.pop(context, code);
              }
            },
          ),

          /// Scan Box Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          /// Instruction text
          // Positioned(
          //   bottom: 80,
          //   left: 0,
          //   right: 0,
          //   child: const Center(
          //     child: Text(
          //       "Align QR code inside the box",
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontSize: 16,
          //         backgroundColor: Colors.black54,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}