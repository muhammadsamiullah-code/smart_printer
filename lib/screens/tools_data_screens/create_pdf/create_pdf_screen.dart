import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/success_dialoge.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreatePdfScreen extends StatefulWidget {
  final String title;
  const CreatePdfScreen({super.key, required this.title});

  @override
  State<CreatePdfScreen> createState() => _CreatePdfScreenState();
}

class _CreatePdfScreenState extends State<CreatePdfScreen> {
  List<PdfPageOrientation> orientations = [];
  List<Size> pageSizes = [];

  PdfPageOrientation selectedOrientation = PdfPageOrientation.portrait;
  Size selectedPageSize = PdfPageSize.a4;
  List<TextEditingController> pageControllers = [];
  List<Color> pageColors = [];

  // int numPages = 1;
  Color selectedPageColor = Colors.white;
  @override
  void initState() {
    super.initState();
    addPage();
  }

  Size getPreviewSize(int index) {
    Size size = pageSizes[index];

    double width = size.width;
    double height = size.height;

    /// Apply orientation
    if (orientations[index] == PdfPageOrientation.landscape) {
      double temp = width;
      width = height;
      height = temp;
    }

    /// Scale down for screen preview
    double scale = 0.5;

    return Size(width * scale, height * scale);
  }

  /// Add a new page
  void addPage() {
    pageControllers.add(TextEditingController());
    pageColors.add(selectedPageColor);
    orientations.add(selectedOrientation);
    pageSizes.add(selectedPageSize);
    setState(() {
      pageControllers.length;
    });
  }

  /// Remove last page
  void removePage() {
    if (pageControllers.isNotEmpty) {
      pageControllers.removeLast();
      pageColors.removeLast();
      orientations.removeLast();
      pageSizes.removeLast();
      setState(() {
        pageControllers.length;
      });
    }
  }

  /// Build page preview
  Widget buildPage(int index) {
    Size preview = getPreviewSize(index);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: preview.width,
        height: preview.height,
        decoration: BoxDecoration(
          color: pageColors[index],
          // border: Border.all(color: Colors.grey.shade400),
          // // boxShadow: const [
          //   BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 2),
          // ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: TextFormField(
            controller: pageControllers[index],
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              hintText: "Type your text here",
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  /// Save PDF and navigate to ResultScreen
  Future<void> savePdf() async {
    /// 🔥 SHOW LOADER
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
    );

    final PdfDocument document = PdfDocument();

    for (int i = 0; i < pageControllers.length; i++) {
      document.pageSettings.size = pageSizes[i];
      document.pageSettings.orientation = orientations[i];

      PdfPage page = document.pages.add();

      final brush = PdfSolidBrush(
        PdfColor(pageColors[i].red, pageColors[i].green, pageColors[i].blue),
      );

      page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(
          0,
          0,
          page.getClientSize().width,
          page.getClientSize().height,
        ),
        brush: brush,
      );

      page.graphics.drawString(
        pageControllers[i].text,
        PdfStandardFont(PdfFontFamily.helvetica, 16),
        bounds: Rect.fromLTWH(
          20,
          20,
          page.getClientSize().width - 40,
          page.getClientSize().height - 40,
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/create_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await document.save());

    document.dispose();

    Navigator.pop(context); // ❌ remove loader

    /// ✅ SHOW SUCCESS DIALOG
    SuccessDialog.show(context, file);
  }

  /// Show options dialog
  Future<void> showOptionsDialog({
    required String title,
    required Widget Function(void Function(void Function())) builder,
  }) async {
    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(title),
              content: builder(setDialogState), // 👈 pass state setter
              actions: [
                CustomButton(
                  text: "Confirm",
                  onPressed: () {
                    setState(() {
                      for (int i = 0; i < orientations.length; i++) {
                        orientations[i] = selectedOrientation;
                      }

                      for (int i = 0; i < pageColors.length; i++) {
                        pageColors[i] = selectedPageColor;
                      }

                      for (int i = 0; i < pageSizes.length; i++) {
                        pageSizes[i] = selectedPageSize;
                      }
                    });

                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Orientation selector
 Widget orientationSelector(void Function(void Function()) setDialogState) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: () {
          setDialogState(() {
            selectedOrientation = PdfPageOrientation.portrait;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selectedOrientation == PdfPageOrientation.portrait
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Portrait",
            style: TextStyle(
              color: selectedOrientation == PdfPageOrientation.portrait
                  ? AppColors.primaryColor
                  : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          setDialogState(() {
            selectedOrientation = PdfPageOrientation.landscape;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selectedOrientation == PdfPageOrientation.landscape
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Landscape",
            style: TextStyle(
              color: selectedOrientation == PdfPageOrientation.landscape
                  ? AppColors.primaryColor
                  : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  );
}

  /// Page color selector
  Widget colorSelector(void Function(void Function()) setDialogState) {
    return SingleChildScrollView(
      child: ColorPicker(
        pickerColor: selectedPageColor,
        onColorChanged: (color) {
          setDialogState(() {
            selectedPageColor = color; // 🔥 live update in dialog
          });
        },
        showLabel: true,
        pickerAreaHeightPercent: 0.8,
      ),
    );
  }

  /// Page size selector
 Widget pageSizeSelector(void Function(void Function()) setDialogState) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(
        onTap: () {
          setDialogState(() {
            selectedPageSize = PdfPageSize.a4;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selectedPageSize == PdfPageSize.a4
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "A4",
            style: TextStyle(
              color: selectedPageSize == PdfPageSize.a4
                  ? AppColors.primaryColor
                  : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          setDialogState(() {
            selectedPageSize = PdfPageSize.letter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selectedPageSize == PdfPageSize.letter
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Letter",
            style: TextStyle(
              color: selectedPageSize == PdfPageSize.letter
                  ? AppColors.primaryColor
                  : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      GestureDetector(
        onTap: () {
          setDialogState(() {
            selectedPageSize = const Size(500, 700);
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selectedPageSize == const Size(500, 700)
                  ? AppColors.primaryColor
                  : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "Fit",
            style: TextStyle(
              color: selectedPageSize == const Size(500, 700)
                  ? AppColors.primaryColor
                  : Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
  );
}

  /// Page count selector
  Widget pageCountSelector(void Function(void Function()) setDialogState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            if (pageControllers.length > 1) {
              setDialogState(() {
                removePage(); // 🔥 actual remove
              });
            }
          },
          icon: const Icon(Icons.remove),
        ),
        Text(pageControllers.length.toString()), // 🔥 real count
        IconButton(
          onPressed: () {
            setDialogState(() {
              addPage(); // 🔥 actual add
            });
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(icon, height: 24, width: 24),

          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(108, 108, 108, 1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: pageControllers
              .asMap()
              .entries
              .map((e) => buildPage(e.key))
              .toList(),
        ),
      ),
      bottomNavigationBar: Container(
        height: 156,
        color: Color.fromRGBO(255, 255, 255, 1),
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: CustomButton(
                  height: 50,
                  onPressed: savePdf,
                  text: "done",
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildOption(
                    icon: 'assets/imageIcons/orientation.svg',
                    label: 'Orientation',
                    onTap: () => showOptionsDialog(
                      title: "Select Orientation",
                      builder: (setDialogState) => orientationSelector(setDialogState),
                    ),
                  ),

                  _buildOption(
                    icon: 'assets/imageIcons/color.svg',
                    label: 'Page Color',
                    onTap: () => showOptionsDialog(
                      title: "Select Page Color",
                      builder: (setDialogState) =>
                          colorSelector(setDialogState),
                    ),
                  ),

                  _buildOption(
                    icon: 'assets/imageIcons/pageSize.svg',
                    label: 'Page Size',
                    onTap: () => showOptionsDialog(
                      title: "Select Page Size",
                         builder: (setDialogState) => pageSizeSelector(setDialogState),

                    ),
                  ),

                  _buildOption(
                    icon: 'assets/imageIcons/pageNumber.svg',
                    label: 'No of Pages',
                    onTap: () => showOptionsDialog(
                      title: "Number of Pages",
                      builder: (setDialogState) =>
                          pageCountSelector(setDialogState),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
