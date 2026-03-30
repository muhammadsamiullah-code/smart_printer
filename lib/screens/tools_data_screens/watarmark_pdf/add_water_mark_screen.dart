import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/success_dialoge.dart';

class AddWatermarkScreen extends StatefulWidget {
  final File file;
  final String title;

  const AddWatermarkScreen({
    super.key,
    required this.file,
    required this.title,
  });

  @override
  State<AddWatermarkScreen> createState() => _AddWatermarkScreenState();
}

class _AddWatermarkScreenState extends State<AddWatermarkScreen> {
  final GlobalKey previewKey = GlobalKey();
  pdfx.PdfControllerPinch? pdfController;
  final controller = TextEditingController();
  PDFViewController? pdfViewController;
  bool isCapturing = false;
  int totalPages = 0;
  int currentPage = 0;
  double scale = 1.0;
  double minScale = 0.5;
  double maxScale = 3.0;
  String fontType = "Helvetica";
  String fontStyle = "Regular";
  double fontSize = 24;

  Color textColor = Colors.red;

  double transparency = 0.3;
  double rotation = 0;

  Offset previewPosition = const Offset(120, 120);
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<double> fontSizes = [
    12,
    16,
    20,
    24,
    28,
    32,
    36,
    40,
    48,
    56,
    64,
    72,
    80,
    96,
    108,
    120,
  ];
  String get fileName => widget.file.path.split('/').last;

  /// FONT
  PdfFont getFont() {
    PdfFontStyle style = PdfFontStyle.regular;

    if (fontStyle == "Bold") style = PdfFontStyle.bold;
    if (fontStyle == "Italic") style = PdfFontStyle.italic;

    switch (fontType) {
      case "Courier":
        return PdfStandardFont(PdfFontFamily.courier, fontSize, style: style);

      case "Times":
        return PdfStandardFont(
          PdfFontFamily.timesRoman,
          fontSize,
          style: style,
        );

      default:
        return PdfStandardFont(PdfFontFamily.helvetica, fontSize, style: style);
    }
  }

  Offset getClampedPosition(
    Offset newPosition,
    Size previewSize,
    Size textSize,
  ) {
    final halfWidth = (textSize.width * scale) / 2;
    final halfHeight = (textSize.height * scale) / 2;

    double dx = newPosition.dx;
    double dy = newPosition.dy;

    dx = dx.clamp(halfWidth, previewSize.width - halfWidth);
    dy = dy.clamp(halfHeight, previewSize.height - halfHeight);

    return Offset(dx, dy);
  }

  Future<Uint8List> capturePreview() async {
    RenderRepaintBoundary boundary =
        previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);

    final byteData = await image.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

Future<void> applyWatermark() async {
  setState(() => isCapturing = true);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  final pdf = PdfDocument();

  /// LOOP ALL PAGES
  for (int i = 0; i < totalPages; i++) {
    /// 👉 switch page
    await pdfViewController?.setPage(i);

    /// 👉 wait UI render
    await Future.delayed(const Duration(milliseconds: 300));

    /// 👉 capture preview (WITH watermark)
    final screenshotBytes = await capturePreview();

    final page = pdf.pages.add();

    /// 🔥 GET CLIENT SIZE
    final width = page.getClientSize().width;
    final height = page.getClientSize().height;

    /// 👉 draw screenshot full page (scaled perfectly)
    page.graphics.drawImage(
      PdfBitmap(screenshotBytes),
      Rect.fromLTWH(0, 0, width, height),
    );
  }

  final dir = await getApplicationDocumentsDirectory();

  final file = File(
    "${dir.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.pdf",
  );

  await file.writeAsBytes(await pdf.save());
  pdf.dispose();

  if (!mounted) return;

  Navigator.pop(context); // loader close
  setState(() => isCapturing = false);

  /// ✅ OPEN PDF VIEW
  SuccessDialog.show(context, file);
}
  // Future<void> applyWatermark() async {
  //   setState(() => isCapturing = true);

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => const Center(child: CircularProgressIndicator()),
  //   );

  //   final pdf = PdfDocument();

  //   /// LOOP ALL PAGES
  //   for (int i = 0; i < totalPages; i++) {
  //     /// 👉 switch page
  //     await pdfViewController?.setPage(i);

  //     /// 👉 wait UI render
  //     await Future.delayed(const Duration(milliseconds: 300));

  //     /// 👉 capture preview (WITH watermark)
  //     final screenshotBytes = await capturePreview();

  //     final page = pdf.pages.add();
  //     final size = page.getClientSize();

  //     /// 👉 draw screenshot full page
  //     page.graphics.drawImage(
  //       PdfBitmap(screenshotBytes),
  //       Rect.fromLTWH(0, 0, size.width, size.height),
  //     );
  //   }

  //   final dir = await getApplicationDocumentsDirectory();

  //   final file = File(
  //     "${dir.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.pdf",
  //   );

  //   await file.writeAsBytes(await pdf.save());

  //   pdf.dispose();

  //   if (!mounted) return;

  //   Navigator.pop(context); // loader close
  //   setState(() => isCapturing = false);

  //   /// ✅ OPEN PDF VIEW
  //   SuccessDialog.show(context, file);
  // }

  void nextPage() {
    if (currentPage < totalPages - 1) {
      pdfViewController?.setPage(currentPage + 1);
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      pdfViewController?.setPage(currentPage - 1);
    }
  }

  double currentRotation = 0;
  double baseRotation = 0;

  double baseScale = 1.0;

  Size getTextSize() {
    final text = controller.text.isEmpty ? "Watermark" : controller.text;

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontStyle == "Bold" ? FontWeight.bold : FontWeight.normal,
          fontStyle: fontStyle == "Italic"
              ? FontStyle.italic
              : FontStyle.normal,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.size;
  }

  Widget buildColorPicker() {
    List<Color> colors = [
      Colors.black,
      Colors.grey,
      Colors.blueGrey,

      Colors.red,
      Colors.redAccent,
      Colors.pink,

      Colors.orange,
      Colors.deepOrange,
      Colors.amber,

      Colors.yellow,
      Colors.green,
      Colors.lightGreen,

      Colors.teal,
      Colors.cyan,

      Colors.blue,
      Colors.indigo,

      Colors.purple,
      Colors.deepPurple,

      Colors.brown,
      Colors.white,
    ];

    return Wrap(
      spacing: 10, // horizontal gap
      runSpacing: 10, // vertical gap
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              textColor = color;
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: textColor == color ? Colors.black : Colors.grey,
                width: textColor == color ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget cardContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildTextFieldRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: Text("Text", style: TextStyle(fontSize: 14)),
          ),

          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              onChanged: (v) => setState(() {}),
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                hintText: "Watermark",
                border: InputBorder.none, // ❌ remove border
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownRow({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget buildPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        /// ✅ A4 ratio
        final height = width * 1.414;

        return SizedBox(
          height: height,
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: RepaintBoundary(
              key: previewKey,
              child: Stack(
                children: [
                  /// ✅ PDF VIEW (BACKGROUND)
                  Positioned.fill(
                    child: PDFView(
                      filePath: widget.file.path,
                      // swipeHorizontal: true,
                      pageSnap: true,
                      autoSpacing: false,
                      enableSwipe: false,
                      swipeHorizontal: false,

                      onRender: (pages) {
                        setState(() {
                          totalPages = pages ?? 0;
                        });
                      },

                      onViewCreated: (controller) {
                        pdfViewController = controller;
                      },

                      onPageChanged: (page, total) {
                        setState(() {
                          currentPage = page ?? 0;
                        });
                      },
                    ),
                  ),

                  /// ✅ WATERMARK (TOP LAYER)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final previewSize = Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        );

                        final textSize = getTextSize();

                        return Stack(
                          children: [
                            Positioned(
                              left: previewPosition.dx,
                              top: previewPosition.dy,
                              child: GestureDetector(
                                onScaleStart: (details) {
                                  baseScale = scale;
                                  baseRotation = currentRotation;
                                },

                                onScaleUpdate: (details) {
                                  setState(() {
                                    /// ✅ SCALE (PINCH)
                                    scale = (baseScale * details.scale).clamp(
                                      minScale,
                                      maxScale,
                                    );

                                    /// ✅ ROTATION (2 FINGER)
                                    currentRotation =
                                        baseRotation + details.rotation;

                                    /// ✅ MOVE
                                    final newPos =
                                        previewPosition +
                                        details.focalPointDelta;

                                    previewPosition = getClampedPosition(
                                      newPos,
                                      previewSize,
                                      textSize,
                                    );
                                  });
                                },

                                child: Transform.rotate(
                                  angle:
                                      currentRotation + (rotation * pi / 180),
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Opacity(
                                      opacity: 1 - transparency,
                                      child: Text(
                                        controller.text.isEmpty
                                            ? "Watermark"
                                            : controller.text,
                                        style: TextStyle(
                                          fontSize: fontSize,
                                          color: textColor,
                                          fontWeight: fontStyle == "Bold"
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontStyle: fontStyle == "Italic"
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  /// ✅ CONTROLS
                  if (!isCapturing)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: previousPage,
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                          Text("${currentPage + 1} / $totalPages"),
                          IconButton(
                            onPressed: nextPage,
                            icon: const Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildWatermarkUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= TEXT FORMAT =================
          sectionTitle("Text Format"),
          cardContainer(
            Column(
              children: [
                buildTextFieldRow(),
                buildDropdownRow(
                  label: "Font Type",
                  value: fontType,
                  items: ["Helvetica", "Courier", "Times"],
                  onChanged: (v) => setState(() => fontType = v!),
                ),
                buildDropdownRow(
                  label: "Font Size",
                  value: fontSize.toString(), // e.g. "24.0"
                  items: fontSizes
                      .map((e) => e.toString())
                      .toList(), // double to string
                  onChanged: (v) => setState(() => fontSize = double.parse(v!)),
                ),
                buildDropdownRow(
                  label: "Font Style",
                  value: fontStyle,
                  items: ["Regular", "Bold", "Italic"],
                  onChanged: (v) => setState(() => fontStyle = v!),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),
          const Text("Watermark Color"),
          const SizedBox(height: 10),
          buildColorPicker(),
          const SizedBox(height: 15),
          sectionTitle("Setting"),
          cardContainer(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Transparency
                buildSlider(
                  title: "Transparency",
                  value: transparency,
                  max: 1,
                  label: transparency.toStringAsFixed(2),
                  onChanged: (v) => setState(() => transparency = v),
                ),

                const SizedBox(height: 10),

                // / Rotation
                buildSlider(
                  title: "Rotation",
                  value: rotation,
                  max: 180,
                  min: -180,
                  label: "${rotation.toInt()}°",
                  onChanged: (v) => setState(() => rotation = v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ IMPORTANT
      appBar: CustomAppBar(title: widget.title),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// ✅ FIXED PREVIEW (NO SCROLL)
              buildPreview(),

              const SizedBox(height: 10),

              /// ✅ ONLY THIS PART SCROLLS
              buildWatermarkUI(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12),
        height: 80,
        child: CustomButton(onPressed: applyWatermark, text: "apply_watermark"),
      ),
    );
  }
}
