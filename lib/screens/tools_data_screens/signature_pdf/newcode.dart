import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
  Color color; // ✅ NEW
  bool isDrawn;
  bool isFinalized; // ✅ ADD THIS

  SignatureData({
    required this.image,
    required this.position,
    required this.size,
    required this.rotation,
    this.color = Colors.black,
    this.isDrawn = false, // default
    this.isFinalized = false,
  });
}

class NewSignaturePdfScreen extends StatefulWidget {
  final File file;
  final String title;
  const NewSignaturePdfScreen({
    super.key,
    required this.file,
    required this.title,
  });

  @override
  State<NewSignaturePdfScreen> createState() => _SignaturePdfScreenState();
}

class _SignaturePdfScreenState extends State<NewSignaturePdfScreen> {
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
  double rotation = 0;
  double zoom = 1.0;
  Color selectedColor = Colors.black;
  bool isExporting = false;
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
        isDrawn: false, // ❌ image
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
                    isDrawn: true, // ❌ image
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
    setState(() {
      isSaving = true;
      isExporting = true; // ✅ hide UI
    });
    await Future.delayed(const Duration(milliseconds: 100));

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
        final originalBytes = await widget.file.readAsBytes();
        final originalPdf = sfpdf.PdfDocument(inputBytes: originalBytes);

        final template = originalPdf.pages[i].createTemplate();
        final width = page.getClientSize().width;
        final height = page.getClientSize().height;
        page.graphics.drawPdfTemplate(
          template,
          Offset.zero,
          Size(width, height),
        );

        originalPdf.dispose();
        // final originalBytes = await widget.file.readAsBytes();
        // final originalPdf = sfpdf.PdfDocument(inputBytes: originalBytes);

        // final template = originalPdf.pages[i].createTemplate();

        // page.graphics.drawPdfTemplate(template, Offset.zero);

        // originalPdf.dispose();
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
      setState(() {
        isSaving = false;
        isExporting = false; // ✅ show UI back
      });
    }

    SuccessDialog.show(context, file);
  }

  @override
  Widget build(BuildContext context) {
    final sig = signatures[currentPage];

    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: selectedFile == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
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
                              onScaleUpdate:
                                  (_) {}, // ignore pinch gestures on PDF
                              child: PDFView(
                                filePath: selectedFile!.path,
                                swipeHorizontal: true,
                                pageSnap: true,
                                pageFling: true,
                                autoSpacing: false,
                                fitPolicy:
                                    FitPolicy.BOTH, // ya WIDTH try kar sakte ho
                                // fitPolicy: FitPolicy.WIDTH, // force fixed fit
                                preventLinkNavigation: true,
                                gestureRecognizers:
                                    <Factory<OneSequenceGestureRecognizer>>{
                                      Factory<HorizontalDragGestureRecognizer>(
                                        () => HorizontalDragGestureRecognizer(),
                                      ),
                                    },
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
                                  onScaleStart: (_) {
                                    _initialSize = sig.size;
                                  },
                                  onScaleUpdate: (details) {
                                    setState(() {
                                      /// MOVE
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

                                      /// ZOOM
                                      sig.size = Size(
                                        (_initialSize!.width * details.scale)
                                            .clamp(0.05, 0.7),
                                        (_initialSize!.height * details.scale)
                                            .clamp(0.05, 0.7),
                                      );

                                      /// ROTATE
                                      // sig.rotation += details.rotation;
                                    });
                                  },
                                  child: GestureDetector(
                                    onTap: () {
                                      if (sig.isFinalized) {
                                        setState(() {
                                          sig.isFinalized =
                                              false; // 👈 wapas editable mode
                                        });
                                      }
                                    },
                                    child: Transform.rotate(
                                      angle: rotation * (3.1416 / 180),
                                      child: Transform.scale(
                                        scale: zoom,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            /// SIGNATURE + BORDER
                                            Container(
                                              height: 100,
                                              width: 120,
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  topRight: Radius.circular(16),
                                                  bottomRight: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                                border:
                                                    (isExporting ||
                                                        sig.isFinalized)
                                                    ? null
                                                    : Border.all(
                                                        color: Colors.green,
                                                        width: 2,
                                                      ),
                                              ),

                                              child: sig.isDrawn
                                                  ? ColorFiltered(
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                            selectedColor,
                                                            BlendMode.srcIn,
                                                          ),
                                                      child: Image.memory(
                                                        sig.image,
                                                        width:
                                                            viewWidth *
                                                            sig.size.width,
                                                        height:
                                                            viewHeight *
                                                            sig.size.height,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                                  : Image.memory(
                                                      sig.image,
                                                      width:
                                                          viewWidth *
                                                          sig.size.width,
                                                      height:
                                                          viewHeight *
                                                          sig.size.height,
                                                      fit: BoxFit.contain,
                                                    ),
                                            ),

                                            /// CONTROLS (NOW WILL ROTATE ✅)
                                            if (!isExporting &&
                                                !sig.isFinalized) ...[
                                              Positioned(
                                                top: 0,
                                                left: 0,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .opaque, // ✅ IMPORTANT
                                                  onTap: () {
                                                    setState(() {
                                                      signatures.remove(
                                                        currentPage,
                                                      );
                                                    });
                                                  },
                                                  child: SizedBox(
                                                    height: 60,
                                                    width: 60,
                                                    child: Center(
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        child: Container(
                                                          width:
                                                              24, // ✅ bigger hit area
                                                          height: 24,
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .white, // optional (improves tap feel)
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 4,
                                                                color: Colors
                                                                    .black26,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Icon(
                                                            Icons.close,
                                                            size: 24,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .opaque, // ✅ IMPORTANT
                                                  onTap: () {
                                                    showSignatureEditSheet(
                                                      context: context,
                                                      rotation: rotation,
                                                      zoom: zoom,
                                                      sig: sig,
                                                      onRotationChanged: (v) {
                                                        rotation = v;
                                                        sig.rotation =
                                                            v * (3.1416 / 180);
                                                      },
                                                      onZoomChanged: (v) {
                                                        zoom = v;
                                                      },
                                                      onUpdate: () {
                                                        setState(() {});
                                                      },
                                                    );
                                                  },
                                                  child: SizedBox(
                                                    height: 60,
                                                    width: 60,
                                                    child: Center(
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Container(
                                                          width:
                                                              24, // ✅ bigger hit area
                                                          height: 24,
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .white, // optional (improves tap feel)
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 4,
                                                                color: Colors
                                                                    .black26,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Icon(
                                                            Icons.more_horiz,
                                                            size: 24,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior
                                                      .opaque, // ✅ IMPORTANT
                                                  onTap: () {
                                                    setState(() {
                                                      sig.isFinalized = true;
                                                    });
                                                  },
                                                  child: SizedBox(
                                                    height: 60,
                                                    width: 60,
                                                    child: Center(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child: Container(
                                                          width:
                                                              24, // ✅ bigger hit area
                                                          height: 24,
                                                          decoration: BoxDecoration(
                                                            color: Colors
                                                                .white, // optional (improves tap feel)
                                                            shape:
                                                                BoxShape.circle,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 4,
                                                                color: Colors
                                                                    .black26,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Icon(
                                                            Icons.check,
                                                            size: 24,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  Widget buildSlider({
    required String title,
    required double value,
    double min = 0,
    required double max,
    required String label,
    required Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
          activeColor: AppColors.primaryColor,
        ),
      ],
    );
  }

  Widget buildColorPicker(
    SignatureData sig,
    Function(void Function()) setModalState,
    VoidCallback onUpdate,
  ) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.grey,
      Colors.indigo,
      Colors.teal,
      Colors.cyan,
      Colors.amber,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
      Colors.lime,
      Colors.pink,
      Colors.blueGrey,
      Colors.yellow.shade800,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      children: colors.map((color) {
        final isSelected = selectedColor == color;

        return GestureDetector(
          onTap: () {
            setModalState(() {
              selectedColor = color;
              sig.color = color;
            });
            onUpdate();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: isSelected ? 36 : 30,
            height: isSelected ? 36 : 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  void showSignatureEditSheet({
    required BuildContext context,
    required double rotation,
    required double zoom,
    required dynamic sig,
    required Function(double) onRotationChanged,
    required Function(double) onZoomChanged,
    required VoidCallback onUpdate,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double tempRotation = rotation; // ✅ local copy
        double tempZoom = zoom;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildSlider(
                    title: "Rotation",
                    value: tempRotation, // ✅ use local
                    max: 180,
                    min: -180,
                    label: "${tempRotation.toInt()}°",
                    onChanged: (v) {
                      setModalState(() {
                        tempRotation = v; // ✅ update local UI FIRST
                      });

                      onRotationChanged(v); // ✅ update actual data
                      onUpdate(); // ✅ refresh main UI
                    },
                  ),

                  const SizedBox(height: 10),

                  if (sig.isDrawn) ...[
                    buildColorPicker(sig, setModalState, onUpdate),
                  ],

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          double newZoom = (tempZoom - 0.1).clamp(0.5, 3.0);

                          setModalState(() {
                            tempZoom = newZoom; // ✅ local update
                          });

                          onZoomChanged(newZoom); // ✅ actual update
                          onUpdate();
                        },
                        icon: const Icon(Icons.zoom_out, size: 36),
                      ),

                      IconButton(
                        onPressed: () {
                          double newZoom = (tempZoom + 0.1).clamp(0.5, 3.0);

                          setModalState(() {
                            tempZoom = newZoom; // ✅ local update
                          });

                          onZoomChanged(newZoom);
                          onUpdate();
                        },
                        icon: const Icon(Icons.zoom_in, size: 36),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  CustomButton(
                    onPressed: () => Navigator.pop(context),
                    text: "Done",
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
