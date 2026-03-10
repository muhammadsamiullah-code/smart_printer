import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:smart_scanner/screens/pdf_scan_view.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  Future<String> convertUriToFilePath(String uri) async {
    if (uri.startsWith("file://")) {
      return uri.replaceAll("file://", "");
    }

    if (uri.startsWith("content://")) {
      final bytes = await http.readBytes(Uri.parse(uri));

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await file.writeAsBytes(bytes);
      return file.path;
    }

    return uri;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            /// Scanner Design Icon (Like Your Image)
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                /// Outer Border
                SizedBox(
                  height: 200,
                  width: 200,
                  child: CustomPaint(painter: BorderPainter()),
                ),

                /// Inner Border
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CustomPaint(painter: BorderPainter(strokeWidth: 4)),
                ),
              ],
            ),

            const Spacer(),

            /// Scan Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0D5DB8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final result = await FlutterDocScanner()
                        .getScannedDocumentAsPdf();

                    final uri = result?.pdfUri;

                    if (uri == null) return;

                    final path = await convertUriToFilePath(uri);

                    if (!mounted) return;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewScanScreen(pdfPath: path),
                      ),
                    );
                  },

                  child: const Text(
                    "Scan Documents",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Border Painter (4 Corner Scanner Design)
class BorderPainter extends CustomPainter {
  final double strokeWidth;

  BorderPainter({this.strokeWidth = 6});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double cornerLength = 30;

    /// Top Left
    canvas.drawLine(Offset(0, 0), Offset(cornerLength, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerLength), paint);

    /// Top Right
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width, cornerLength),
      paint,
    );

    /// Bottom Left
    canvas.drawLine(
      Offset(0, size.height),
      Offset(cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - cornerLength),
      paint,
    );

    /// Bottom Right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - cornerLength, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
