import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;
import '../../../const/color.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/success_dialoge.dart';
import '../../../widgets/tr_text.dart';

class SignatureData {
  Uint8List image;
  Offset position;
  Size size;
  double rotation;

  SignatureData({
    required this.image,
    required this.position,
    required this.size,
    required this.rotation,
  });
}

class SignaturePdfScreen extends StatefulWidget {
  final File file;
  final String title;
  const SignaturePdfScreen({
    super.key,
    required this.file,
    required this.title,
  });

  @override
  State<SignaturePdfScreen> createState() => _SignaturePdfScreenState();
}

class _SignaturePdfScreenState extends State<SignaturePdfScreen> {
  File? selectedFile;
  GlobalKey previewKey = GlobalKey();
  PDFViewController? pdfController;
  bool isSaving = false;
  // Uint8List? signatureImage;
  double rotationAngle = 0;
  // double _initialScale = 1.0;
  Size? _initialSize;
  int currentPage = 0;
  int totalPages = 0;
  Size signatureSizeRatio = const Size(0.2, 0.1);
  Offset signatureRatio = const Offset(0.5, 0.8);
  Map<int, SignatureData> signatures = {};
  final SignatureController signController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    selectedFile = widget.file;
  }

  /// Import Signature
  Future<void> importSignature() async {
    final picker = ImagePicker();

    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final img = await File(file.path).readAsBytes();

      signatures[currentPage] = SignatureData(
        image: img,
        position: const Offset(0.5, 0.5), // ✅ center
        size: const Size(0.2, 0.1),
        rotation: 0,
      );

      setState(() {});
    }
  }

  /// Draw Signature
  void drawSignature() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(234, 244, 255, 1),
          title: Center(child: const TrText("draw_signature")),

          content: SizedBox(
            width: 300,
            height: 200,
            child: Signature(
              controller: signController,
              backgroundColor: Colors.white,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                signController.clear();
              },
              child: const TrText(
                "clear",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),

            TextButton(
              onPressed: () async {
                // signatureImage = await signController.toPngBytes();
                final img = await signController.toPngBytes();

                if (img != null) {
                  signatures[currentPage] = SignatureData(
                    image: img,
                    position: const Offset(0.5, 0.5), // ✅ center

                    size: const Size(0.2, 0.1),
                    rotation: 0,
                  );
                }
                Navigator.pop(context);
                setState(() {});

                // setState(() {});
              },
              child: const TrText(
                "done",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void openSignatureOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          // backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          contentPadding: const EdgeInsets.all(24),
          title: TrText(
            'add_signature',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.7, // 80% of screen width
            // height: 300, // Increase height
            child: Row(
              children: [
                // Import from Gallery
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      importSignature();
                    },
                    child: Container(
                      height: 120,
                      width: 150,
                      padding: EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.image,
                            size: 40,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(height: 12),
                          TrText(
                            "import_signature",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Draw Signature
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      drawSignature();
                    },
                    child: Container(
                      height: 120,
                      width: 150,
                      padding: EdgeInsets.all(8),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.draw,
                            size: 40,
                            color: AppColors.primaryColor,
                          ),
                          SizedBox(height: 12),
                          TrText(
                            "draw_your_sign",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List> capturePreview() async {
    RenderRepaintBoundary boundary =
        previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);

    final byteData = await image.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Save PDF
  Future<void> savePdf() async {
    // if (signatureImage == null) return;
    if (signatures.isEmpty) return;
    setState(() => isSaving = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final pdf = sfpdf.PdfDocument();

    /// LOOP THROUGH ALL PAGES
    for (int i = 0; i < totalPages; i++) {
      await pdfController!.setPage(i);
      await Future.delayed(const Duration(milliseconds: 300));

      final screenshotBytes = await capturePreview();

      final page = pdf.pages.add();

      final size = page.getClientSize();

      /// Check if signature exists on this page
      if (signatures.containsKey(i)) {
        page.graphics.drawImage(
          sfpdf.PdfBitmap(screenshotBytes),
          Rect.fromLTWH(0, 0, size.width, size.height),
        );
      } else {
        /// original page (no signature)
        // final originalBytes = await widget.file.readAsBytes();
        // final tempPdf = sfpdf.PdfDocument(inputBytes: originalBytes);
        final originalBytes = await widget.file.readAsBytes();
        final originalPdf = sfpdf.PdfDocument(inputBytes: originalBytes);

        final template = originalPdf.pages[i].createTemplate();

        page.graphics.drawPdfTemplate(template, Offset.zero);

        originalPdf.dispose();
      }
    }

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/signed_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    pdf.dispose();

    if (mounted) {
      Navigator.pop(context);
      setState(() => isSaving = false);
    }

    SuccessDialog.show(context, file);
  }

  void nextPage() async {
    if (pdfController == null) return;

    if (currentPage + 1 < totalPages) {
      currentPage++;

      await pdfController!.setPage(currentPage);

      setState(() {});
    }
  }

  /// Previous Page
  void previousPage() async {
    if (pdfController == null) return;

    if (currentPage > 0) {
      currentPage--;

      await pdfController!.setPage(currentPage);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final sig = signatures[currentPage];

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        actions: [
          /// Add Signature Button
          // IconButton(
          //   onPressed: openSignatureOptions,
          //   icon: const Icon(Icons.edit, color: Colors.black),
          //   tooltip: "Add Signature",
          // ),

          // /// Save PDF Button
          // IconButton(
          //   onPressed: isSaving ? null : savePdf,
          //   icon: const Icon(Icons.save, color: Colors.black),
          //   tooltip: "Save PDF",
          // ),
        ],
      ),

      body: selectedFile == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                double viewWidth = constraints.maxWidth;
                double viewHeight = constraints.maxHeight;

                return RepaintBoundary(
                  key: previewKey,
                  child: Stack(
                    children: [
                      /// PDF Viewer
                      GestureDetector(
                        onScaleStart: (_) {},
                        onScaleUpdate: (_) {}, // ignore pinch gestures on PDF
                        child: PDFView(
                          filePath: selectedFile!.path,
                          swipeHorizontal: true,
                          pageSnap: true,
                          pageFling: true,
                          autoSpacing: false,
                          fitPolicy:
                              FitPolicy.BOTH, // ya WIDTH try kar sakte ho
                      
                          onRender: (pages) =>
                              setState(() => totalPages = pages!),
                          onViewCreated: (controller) =>
                              pdfController = controller,
                          onPageChanged: (page, total) =>
                              setState(() => currentPage = page!),
                        ),
                      ),

                      if (sig != null)
                        Positioned(
                          left: viewWidth * sig.position.dx,
                          top: viewHeight * sig.position.dy,
                          child: GestureDetector(
                            onScaleStart: (details) {
                              _initialSize =
                                  sig.size; // store size at start of gesture
                            },
                            onScaleUpdate: (details) {
                              setState(() {
                                // MOVE
                                sig.position = Offset(
                                  (sig.position.dx +
                                          details.focalPointDelta.dx /
                                              viewWidth)
                                      .clamp(0, 1),
                                  (sig.position.dy +
                                          details.focalPointDelta.dy /
                                              viewHeight)
                                      .clamp(0, 1),
                                );

                                // ZOOM
                                final newWidth =
                                    (_initialSize!.width * details.scale).clamp(
                                      0.05,
                                      0.7,
                                    );
                                final newHeight =
                                    (_initialSize!.height * details.scale)
                                        .clamp(0.05, 0.7);
                                sig.size = Size(newWidth, newHeight);

                                // ROTATE
                                sig.rotation += details.rotation;
                              });
                            },
                            onDoubleTap: () {
                              setState(() {
                                sig.size = const Size(0.3, 0.15); // reset zoom
                              });
                            },
                            child: Transform.rotate(
                              angle: sig.rotation,
                              child: Image.memory(
                                sig.image,
                                width: viewWidth * sig.size.width,
                                height: viewHeight * sig.size.height,
                              ),
                            ),
                          ),
                        ),

                      /// ⬅️ Previous Button
                      Positioned(
                        bottom: 70,
                        left: 120,
                        right: 120,
                        child: !isSaving
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  /// ⬅️ Previous
                                  IconButton(
                                    onPressed: previousPage,
                                    icon: const Icon(Icons.arrow_back_ios),
                                  ),

                                  /// 🔢 Page Indicator
                                  Text(
                                    "${currentPage + 1} / $totalPages",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  /// ➡️ Next
                                  IconButton(
                                    onPressed: nextPage,
                                    icon: const Icon(Icons.arrow_forward_ios),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 80,
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                borderWidth: 1.5,
                borderColor: AppColors.primaryColor,
                onPressed: openSignatureOptions,
                text: 'draw_signature',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: CustomButton(
                onPressed: isSaving ? null : savePdf,
                text: "sign_pdf",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
