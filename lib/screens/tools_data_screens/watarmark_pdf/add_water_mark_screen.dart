import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:math';

import '../../../widgets/custom_appbar.dart';
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
  pdfx.PdfPage? page;
  pdfx.PdfControllerPinch? pdfController;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    pdfController = pdfx.PdfControllerPinch(
      document: pdfx.PdfDocument.openFile(widget.file.path),
    );

    loadPageSize(); // ✅ controller ke baad call karo
  }
  // pdfx.PdfPage? page;

  void loadPageSize() async {
    if (pdfController == null) return;

    final doc = await pdfController!.document;
    final p = await doc.getPage(1);

    setState(() {
      page = p;
    });
  }

  // pdfx.PdfControllerPinch? pdfController;
  String fontType = "Helvetica";
  String fontStyle = "Regular";
  double fontSize = 24;

  Color textColor = Colors.red;

  String alignment = "Middle Center";

  double transparency = 0.3;
  double rotation = 0;

  Offset previewPosition = const Offset(120, 120);

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

  List<String> alignments = [
    "Top Left",
    "Top Center",
    "Top Right",
    "Middle Left",
    "Middle Center",
    "Middle Right",
    "Bottom Left",
    "Bottom Center",
    "Bottom Right",
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

  void updateAlignment() {
    const previewWidth = 300;
    const previewHeight = 300;

    switch (alignment) {
      case "Top Left":
        previewPosition = const Offset(10, 10);
        break;

      case "Top Center":
        previewPosition = const Offset(previewWidth / 2 - 50, 10);
        break;

      case "Top Right":
        previewPosition = const Offset(previewWidth - 120, 10);
        break;

      case "Middle Left":
        previewPosition = const Offset(10, previewHeight / 2);
        break;

      case "Middle Center":
        previewPosition = const Offset(
          previewWidth / 2 - 50,
          previewHeight / 2,
        );
        break;

      case "Middle Right":
        previewPosition = const Offset(previewWidth - 120, previewHeight / 2);
        break;

      case "Bottom Left":
        previewPosition = const Offset(10, previewHeight - 50);
        break;

      case "Bottom Center":
        previewPosition = const Offset(
          previewWidth / 2 - 50,
          previewHeight - 50,
        );
        break;

      case "Bottom Right":
        previewPosition = const Offset(previewWidth - 120, previewHeight - 50);
        break;
    }
  }

  /// ALIGNMENT
  Offset getAlignment(Size size) {
    switch (alignment) {
      case "Top Left":
        return const Offset(20, 20);

      case "Top Center":
        return Offset(size.width / 2, 20);

      case "Top Right":
        return Offset(size.width - 200, 20);

      case "Middle Left":
        return Offset(20, size.height / 2);

      case "Middle Right":
        return Offset(size.width - 200, size.height / 2);

      case "Bottom Left":
        return Offset(20, size.height - 50);

      case "Bottom Center":
        return Offset(size.width / 2, size.height - 50);

      case "Bottom Right":
        return Offset(size.width - 200, size.height - 50);

      default:
        return Offset(size.width / 2, size.height / 2);
    }
  }

  Future<void> applyWatermark() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    /// ✅ GET REAL PREVIEW SIZE
    final RenderBox box =
        previewKey.currentContext!.findRenderObject() as RenderBox;

    final previewSize = box.size;
    final previewWidth = previewSize.width;
    final previewHeight = previewSize.height;

    final bytes = await widget.file.readAsBytes();
    final PdfDocument document = PdfDocument(inputBytes: bytes);

    final font = getFont();

    for (int i = 0; i < document.pages.count; i++) {
      final page = document.pages[i];
      final size = page.getClientSize();

      page.graphics.save();

      /// ✅ transparency
      page.graphics.setTransparency(transparency);

      /// ✅ CORRECT RATIO (NO HARDCODE)
      final textSize = getTextSize();

      final ratioX = previewPosition.dx / previewWidth;
      final ratioY = previewPosition.dy / previewHeight;

      final pdfX = ratioX * size.width;
      final pdfY = ratioY * size.height;
      final centerX = pdfX + (textSize.width / 2);
      final centerY = pdfY + (textSize.height / 2);

      /// ✅ MOVE TO POSITION
      page.graphics.translateTransform(centerX, centerY);
      page.graphics.rotateTransform(rotation);

      page.graphics.drawString(
        controller.text.isEmpty ? "Watermark" : controller.text,
        font,
        brush: PdfSolidBrush(
          PdfColor(textColor.red, textColor.green, textColor.blue),
        ),
        bounds: Rect.fromCenter(
          center: const Offset(0, 0),
          width: textSize.width,
          height: textSize.height,
        ),
        format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle,
        ),
      );

      page.graphics.restore();
    }

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/watermark_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await document.save());
    document.dispose();

    if (!mounted) return;

    Navigator.pop(context);

    /// ✅ RETURN TRUE (IMPORTANT)
    SuccessDialog.show(context, file);
  }

  @override
  void dispose() {
    pdfController?.dispose();
    controller.dispose();
    super.dispose();
  }

  Widget buildPreview() {
    final textSize = getTextSize();

    if (page == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      key: previewKey, // ✅ IMPORTANT
      child: Stack(
        children: [
          /// ✅ PDF VIEW (REAL RATIO)
          AspectRatio(
            aspectRatio: page!.width / page!.height,
            child: pdfx.PdfViewPinch(
              controller: pdfController!,
              scrollDirection: Axis.vertical,
              builders: pdfx.PdfViewPinchBuilders<pdfx.DefaultBuilderOptions>(
                options: const pdfx.DefaultBuilderOptions(),
                documentLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                errorBuilder: (_, error) =>
                    Center(child: Text(error.toString())),
              ),
            ),
          ),

          /// ✅ WATERMARK (DRAGGABLE)
          Positioned(
            left: previewPosition.dx,
            top: previewPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  previewPosition += details.delta;
                });
              },
              child: Transform.rotate(
                angle: rotation * pi / 180,
                child: Transform.translate(
                  // ✅ ADD THIS
                  offset: Offset(-textSize.width / 2, -textSize.height / 2),
                  child: Opacity(
                    opacity: 1 - transparency,
                    child: Text(
                      controller.text.isEmpty ? "Watermark" : controller.text,
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
      ),
    );
  }

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
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.black,
      Colors.orange,
      Colors.purple,
    ];

    return Row(
      children: colors.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              textColor = color;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 10),
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildWatermarkUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
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

          /// ================= POSITION =================
          sectionTitle("Watermark Position"),
          cardContainer(
            Column(
              children: [
                buildDropdownRow(
                  label: "Alignment",
                  value: alignment,
                  items: alignments,
                  onChanged: (v) {
                    setState(() {
                      alignment = v!;
                      updateAlignment();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// ================= SETTINGS =================
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

                /// Rotation
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// Selected File
            const SizedBox(height: 20),

            /// Preview
            buildPreview(),

            const SizedBox(height: 20),
            buildWatermarkUI(),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: applyWatermark,
                child: const Text("Apply Watermark"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
