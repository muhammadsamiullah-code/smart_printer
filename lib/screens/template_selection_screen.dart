import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/models/labels_shape.dart';
import 'package:smart_scanner/models/labels_template.dart';
import 'package:smart_scanner/providers/labels_provider.dart';
import 'package:smart_scanner/providers/translator_provider.dart';
import 'package:smart_scanner/screens/pdf_label_preview_screen.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:smart_scanner/widgets/snack_bar_helper.dart';
import 'package:smart_scanner/widgets/tr_text.dart';
import 'package:image/image.dart' as img;

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() =>
      _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      _cropImage(File(picked.path));
    }
  }

  List<double> getTemplateRatio(LabelTemplate template) {
    final size = parseSize(template.displaySize);

    double w = size[0];
    double h = size[1];

    /// rectangle orientation
    if (template.shape == LabelShape.rectangle ||
        template.shape == LabelShape.oval) {
      /// agar width height se choti hai → vertical
      if (w < h) {
        return [w, h];
      }

      /// horizontal
      return [w, h];
    }

    /// circle & square
    return [1, 1];
  }

  Future<void> _cropImage(File imageFile) async {
    await cropImageByTemplate(imageFile);
  }

  double parseFraction(String value) {
    if (value.contains('/')) {
      var parts = value.split('/');
      return double.parse(parts[0]) / double.parse(parts[1]);
    }
    return double.parse(value);
  }

  double parseInch(String text) {
    text = text.replaceAll('"', '').trim();

    if (text.contains('-')) {
      var parts = text.split('-');
      return double.parse(parts[0]) + parseFraction(parts[1]);
    }

    if (text.contains('/')) {
      return parseFraction(text);
    }

    return double.parse(text);
  }

  double inch(String value) {
    if (value.contains("-")) {
      final parts = value.split("-");
      return inch(parts[0]) + inch(parts[1]);
    }

    if (value.contains("/")) {
      final parts = value.split("/");
      return double.parse(parts[0]) / double.parse(parts[1]);
    }

    return double.parse(value);
  }

  List<double> parseSize(String size) {
    size = size.replaceAll('"', '');

    if (size.contains('x')) {
      var parts = size.split('x');

      double w = parseInch(parts[0].trim());
      double h = parseInch(parts[1].trim());

      return [w, h];
    }

    // round label (single value)
    double d = parseInch(size.trim());
    return [d, d];
  }

  Future<void> cropImageByTemplate(File imageFile) async {
    final provider = context.read<LabelProvider>();
    final translator = context.read<TranslatorProvider>();

    final template = provider.selectedTemplate!;

    final ratio = getTemplateRatio(template);

    final cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: ratio[0], ratioY: ratio[1]),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: translator.tr("crop_image"),
          toolbarColor: AppColors.primaryColor,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: translator.tr("crop_image"),
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (cropped == null) return;

    File finalFile = File(cropped.path);

    /// apply real shape crop
    finalFile = await applyShapeCrop(finalFile, template.shape);

    provider.setImage(finalFile);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PdfLabelPreviewScreen()),
    );
  }

  Future<File> applyShapeCrop(File file, LabelShape shape) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return file;

    if (shape == LabelShape.round) {
      image = circleCrop(image);
    }

    if (shape == LabelShape.oval) {
      image = ovalCrop(image);
    }

    final newPath =
        "${file.parent.path}/shape_${DateTime.now().millisecondsSinceEpoch}.png";

    return await File(newPath).writeAsBytes(img.encodePng(image));
  }

  img.Image circleCrop(img.Image src) {
    int size = src.width < src.height ? src.width : src.height;

    img.Image dst = img.Image(width: size, height: size);

    int radius = size ~/ 2;

    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        int dx = x - radius;
        int dy = y - radius;

        if (dx * dx + dy * dy <= radius * radius) {
          dst.setPixel(x, y, src.getPixel(x, y));
        } else {
          dst.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }

    return dst;
  }

  img.Image ovalCrop(img.Image src) {
    int w = src.width;
    int h = src.height;

    img.Image dst = img.Image(width: w, height: h);

    double rx = w / 2;
    double ry = h / 2;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        double dx = (x - rx) / rx;
        double dy = (y - ry) / ry;

        if (dx * dx + dy * dy <= 1) {
          dst.setPixel(x, y, src.getPixel(x, y));
        } else {
          dst.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }

    return dst;
  }

  List<int> calculateSmartGrid(int perSheet) {
    int bestRows = 1;
    int bestCols = perSheet;

    for (int r = 1; r <= perSheet; r++) {
      int c = (perSheet / r).ceil();

      if (r * c >= perSheet) {
        int diff = (r - c).abs();

        int bestDiff = (bestRows - bestCols).abs();

        if (diff < bestDiff) {
          bestRows = r;
          bestCols = c;
        }
      }
    }

    return [bestRows, bestCols];
  }

  List<int> autoFitGrid(double labelW, double labelH) {
    const pageW = 210.0;
    const pageH = 297.0;

    const margin = 10.0;

    double usableW = pageW - margin * 2;
    double usableH = pageH - margin * 2;

    int cols = (usableW / labelW).floor();
    int rows = (usableH / labelH).floor();

    if (cols < 1) cols = 1;
    if (rows < 1) rows = 1;

    return [rows, cols];
  }

  List<LabelTemplate> _generateTemplates(LabelShape shape) {
    final shapeName = shape.name.toLowerCase();

    final Map<LabelShape, List<String>> sizes = {
      LabelShape.rectangle: [
        '3-1/3" x 4"',
        '2" x 3"',
        '1-1/2" x 2-3/4"',
        '1-1/3" x 4"',
        '3/4" x 3-1/2"',
        '1" x 2-5/8"',
      ],

      LabelShape.round: ['3-1/2"', '3"', '2-1/2"', '2"', '1-1/2"', '1-1/4"'],

      LabelShape.oval: [
        '4-1/4" x 2-1/2"',
        '2" x 3-1/3"',
        '1-1/2" x 3"',
        '1-1/2" x 2-1/2"',
        '1" x 2"',
      ],

      LabelShape.square: [
        '4" x 4"',
        '3" x 3"',
        '2-1/2" x 2-1/2"',
        '2" x 2"',
        '1-1/2" x 1-1/2"',
      ],
    };

    final list = sizes[shape]!;

    final templates = <LabelTemplate>[];
    final usedPerSheet = <int>{}; // duplicate prevent

    for (final size in list) {
      final parsed = parseSize(size);

      double w = parsed[0] * 25.4;
      double h = parsed[1] * 25.4;

      final grid = autoFitGrid(w, h);

      int rows = grid[0];
      int cols = grid[1];

      int perSheet = rows * cols;

      /// skip duplicate
      if (usedPerSheet.contains(perSheet)) continue;

      usedPerSheet.add(perSheet);

      templates.add(
        LabelTemplate(
          perSheet: perSheet,
          displaySize: size,
          columns: cols,
          rows: rows,
          shape: shape,
          svgPath: "assets/templates/$shapeName/$perSheet.svg",
        ),
      );
    }

    return templates;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LabelProvider>(context);
    final shape = provider.selectedShape!;
    final templates = _generateTemplates(shape);

    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // same as appbar
          statusBarIconBrightness: Brightness.dark, // dark icons
          statusBarBrightness: Brightness.light,
        ),
        foregroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
        ),
        title: const TrText(
          "select_label_template",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// GRID
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2 / 2,
              ),
              itemBuilder: (context, index) {
                final template = templates[index];
                final isSelected =
                    provider.selectedTemplate?.perSheet == template.perSheet;
                // final isSelected = provider.selectedTemplate == template;
                return GestureDetector(
                  onTap: () {
                    provider.setTemplate(template);
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Expanded(
                            //   child: SvgPicture.asset(
                            //     template.svgPath,
                            //     fit: BoxFit.contain,
                            //   ),
                            // ),
                            const SizedBox(height: 8),

                            Text(
                              "${template.perSheet} per Sheet",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              template.displaySize,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            // Text(
                            //   "${template.widthInch}\" x ${template.heightInch}\"",
                            //   style: const TextStyle(
                            //     fontSize: 12,
                            //     color: Colors.grey,
                            //   ),
                            // ),
                          ],
                        ),
                      ),

                      /// CHECKBOX
                      if (isSelected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          /// NEXT BUTTON
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'next',
              onPressed: () {
                if (provider.selectedTemplate == null) {
                  SnackbarHelper.show(context, "Please Select Label Template");
                  return;
                }

                _pickImage();
              },
            ),
          ),
        ],
      ),
    );
  }
}
