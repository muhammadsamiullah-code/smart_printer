import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sfpdf;

import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/success_dialoge.dart';

class PageNumberPdfScreen extends StatefulWidget {
  final List<File> files;
  final String title;

  const PageNumberPdfScreen({super.key, required this.files, required this.title});

  @override
  State<PageNumberPdfScreen> createState() => _PageNumberPdfScreenState();
}

class _PageNumberPdfScreenState extends State<PageNumberPdfScreen> {
  pdfx.PdfPageImage? firstPageImage;
  File? selectedFile;
  late List<File> selectedFiles;

  @override
  void initState() {
    super.initState();

    selectedFiles = [...widget.files];

    if (selectedFiles.isNotEmpty) {
      loadPreview(selectedFiles.first); // 👈 YAHAN CALL
    }
  }

  pdfx.PdfControllerPinch? controller;

  int totalPages = 0;

  /// Text type
  String numberFormat = "number";

  /// Font
  String fontType = "Helvetica";
  String fontStyle = "Regular";
  double fontSize = 20;

  Color textColor = Colors.black;

  /// Position
  String alignment = "Center";
  String verticalPosition = "Bottom";

  /// Pick PDF
  ///
  Future<void> loadPreview(File file) async {
    final doc = await pdfx.PdfDocument.openFile(file.path);

    totalPages = doc.pagesCount;

    final page = await doc.getPage(1);

    firstPageImage = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: pdfx.PdfPageImageFormat.png,
    );

    await page.close();

    setState(() {});
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      selectedFile = File(result.files.single.path!);

      final doc = await pdfx.PdfDocument.openFile(selectedFile!.path);

      totalPages = doc.pagesCount;

      /// render first page
      final page = await doc.getPage(1);

      firstPageImage = await page.render(
        width: page.width * 2,
        height: page.height * 2,
        format: pdfx.PdfPageImageFormat.png,
      );

      await page.close();

      setState(() {});
    }
  }

  sfpdf.PdfFont getFont() {
    sfpdf.PdfFontStyle style = sfpdf.PdfFontStyle.regular;

    if (fontStyle == "Bold") style = sfpdf.PdfFontStyle.bold;
    if (fontStyle == "Italic") style = sfpdf.PdfFontStyle.italic;

    switch (fontType) {
      case "Times-Roman":
        return sfpdf.PdfStandardFont(
          sfpdf.PdfFontFamily.timesRoman,
          fontSize,
          style: style,
        );

      case "Courier":
        return sfpdf.PdfStandardFont(
          sfpdf.PdfFontFamily.courier,
          fontSize,
          style: style,
        );

      default:
        return sfpdf.PdfStandardFont(
          sfpdf.PdfFontFamily.helvetica,
          fontSize,
          style: style,
        );
    }
  }

  /// Get alignment
  sfpdf.PdfTextAlignment getAlignment() {
    if (alignment == "Left") return sfpdf.PdfTextAlignment.left;
    if (alignment == "Right") return sfpdf.PdfTextAlignment.right;

    return sfpdf.PdfTextAlignment.center;
  }

  /// Apply page numbers
  Future<void> applyPageNumbers() async {
    if (selectedFiles.isEmpty) return;

    /// 🔥 SHOW LOADER
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    for (final file in selectedFiles) {
      final bytes = await file.readAsBytes();

      final sfpdf.PdfDocument pdf = sfpdf.PdfDocument(inputBytes: bytes);

      final font = getFont();

      for (int i = 0; i < pdf.pages.count; i++) {
        final page = pdf.pages[i];

        String text = numberFormat == "pageXofY"
            ? "Page ${i + 1} of ${pdf.pages.count}"
            : "${i + 1}";

        final size = page.getClientSize();

        double y = verticalPosition == "Bottom" ? size.height - 40 : 20;

        page.graphics.drawString(
          text,
          font,
          brush: sfpdf.PdfSolidBrush(
            sfpdf.PdfColor(textColor.red, textColor.green, textColor.blue),
          ),
          bounds: Rect.fromLTWH(0, y, size.width, 40),
          format: sfpdf.PdfStringFormat(alignment: getAlignment()),
        );
      }

      final dir = await getApplicationDocumentsDirectory();

      final newFile = File(
        "${dir.path}/page_numbers_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await newFile.writeAsBytes(await pdf.save());

      pdf.dispose();

      /// REMOVE LOADER BEFORE DIALOG
      Navigator.pop(context);

      /// SHOW SUCCESS
      SuccessDialog.show(context, newFile);
    }
  }
  
Widget buildColorPicker() {
  List<Color> colors = [
    Colors.black,
    Colors.grey,
    Colors.blueGrey,

    Colors.red,
    Colors.pink,
    Colors.orange,
    Colors.deepOrange,

    Colors.yellow,
    Colors.amber,
    Colors.lime,

    Colors.green,
    Colors.teal,

    Colors.cyan,
    Colors.blue,
    Colors.indigo,

    Colors.purple,
    Colors.deepPurple,

    Colors.brown,

    const Color(0xFF2C3E50), // dark navy
    const Color(0xFF7F8C8D), // soft gray
  ];

  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: colors.map((c) {
      final isSelected = textColor == c;

      return GestureDetector(
        onTap: () {
          setState(() {
            textColor = c;
          });
        },
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
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
        Slider(value: value, min: min, max: max, onChanged: onChanged, activeColor: AppColors.primaryColor,),
      ],
    );
  }
  Widget buildRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.grey)),
      ],
    ),
  );
}
  Widget buildPageNumberUI() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// ================= INFO =================
        sectionTitle("Info"),
        cardContainer(
          buildRow("Total Pages", "$totalPages"),
        ),

        const SizedBox(height: 15),

        /// ================= FORMAT =================
        sectionTitle("Format"),
        cardContainer(
          Column(
            children: [
              buildDropdownRow(
                label: "Format",
                value: numberFormat,
                items: const [
                  "number",
                  "pageXofY",
                ],
                displayItems: const [
                  "Insert Only Page Number",
                  "Page X of Y",
                ],
                onChanged: (v) => setState(() => numberFormat = v!),
              ),

              buildDropdownRow(
                label: "Font Type",
                value: fontType,
                items: const ["Helvetica", "Times-Roman", "Courier"],
                onChanged: (v) => setState(() => fontType = v!),
              ),

              buildDropdownRow(
                label: "Font Style",
                value: fontStyle,
                items: const ["Regular", "Bold", "Italic"],
                onChanged: (v) => setState(() => fontStyle = v!),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),

        /// ================= STYLE =================
        sectionTitle("Style"),
        cardContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSlider(
                title: "Font Size",
                value: fontSize,
                min: 12,
                max: 60,
                label: fontSize.toStringAsFixed(0),
                onChanged: (v) => setState(() => fontSize = v),
              ),

              const SizedBox(height: 10),

              const Text("Color"),
              const SizedBox(height: 10),
              buildColorPicker(),
            ],
          ),
        ),

        const SizedBox(height: 15),

        /// ================= POSITION =================
        sectionTitle("Position"),
        cardContainer(
          Column(
            children: [
              buildDropdownRow(
                label: "Alignment",
                value: alignment,
                items: const ["Left", "Center", "Right"],
                onChanged: (v) => setState(() => alignment = v!),
              ),

              buildDropdownRow(
                label: "Vertical",
                value: verticalPosition,
                items: const ["Top", "Bottom"],
                onChanged: (v) => setState(() => verticalPosition = v!),
              ),
            ],
          ),
        ),

       // /// ================= BUTTON =================
        // SizedBox(
        //   width: double.infinity,
        //   child: ElevatedButton(
        //     onPressed: applyPageNumbers,
        //     child: const Text("Confirm"),
        //   ),
        // ),

      ],
    ),
  );
}

Widget buildDropdownRow({
  required String label,
  required String value,
  required List<String> items,
  List<String>? displayItems,
  required Function(String?) onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),

        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          items: List.generate(items.length, (index) {
            return DropdownMenuItem(
              value: items[index],
              child: Text(displayItems != null
                  ? displayItems[index]
                  : items[index]),
            );
          }),
          onChanged: onChanged,
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: Column(
        children: [
          /// Preview
          Expanded(
            child: Center(
              child: firstPageImage == null
                  ? const CircularProgressIndicator()
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        /// First page image
                        Image.memory(firstPageImage!.bytes),
      
                        /// Live page number preview
                        Positioned(
                          left: alignment == "Left" ? 20 : null,
                          right: alignment == "Right" ? 20 : null,
                          bottom: verticalPosition == "Bottom" ? 20 : null,
                          top: verticalPosition == "Top" ? 20 : null,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              numberFormat == "pageXofY"
                                  ? "Page 1 of $totalPages"
                                  : "1",
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
                      ],
                    ),
            ),
          ),
         SizedBox(
          height: 400,
          child: buildPageNumberUI()),
               
          const SizedBox(height: 10),
        ],
      ),
      bottomNavigationBar: Container(
              padding: const EdgeInsets.all(12),
              height: 70,
              child: CustomButton(
                            
                onPressed: applyPageNumbers,
                text: "confirm",
              ),
            ),
    );
  }
}
