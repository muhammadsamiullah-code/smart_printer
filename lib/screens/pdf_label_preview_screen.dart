import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdfx/pdfx.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';
import 'package:smart_scanner/models/labels_shape.dart';
import 'package:smart_scanner/models/labels_template.dart';
import 'package:smart_scanner/providers/labels_provider.dart';
import 'package:smart_scanner/widgets/tr_text.dart';
import '../const/color.dart';
import '../widgets/custom_appbar.dart';
import 'format_selection_screen.dart';
import '../pdf_preview_screen.dart';

class PdfLabelPreviewScreen extends StatefulWidget {
  const PdfLabelPreviewScreen({super.key});

  @override
  State<PdfLabelPreviewScreen> createState() => _PdfLabelPreviewScreenState();
}

class _PdfLabelPreviewScreenState extends State<PdfLabelPreviewScreen> {
  PdfDocument? _document;
  final List<PreviewPage> pages = [];
  bool _isPrinting = false;
  double inchToMm(double inch) {
    return inch * 25.4;
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
    size = size.replaceAll('"', '').trim();

    if (!size.contains('x')) {
      double v = inch(size);
      return [v, v];
    }

    final parts = size.split('x');

    double w = inch(parts[0].trim());
    double h = inch(parts[1].trim());

    return [w, h];
  }

  Future<bool> isWifiReallyOn() async {
    final granted = await ensureLocationPermission();
    if (!granted) return false;

    final info = NetworkInfo();
    final wifiName = await info.getWifiName(); // <-- REAL CHECK

    return wifiName != null && wifiName.isNotEmpty;
  }

  Future<Uint8List> buildPrintablePdf(
    LabelTemplate template,
    File imageFile,
  ) async {
    final pdf = pw.Document();

    final imageBytes = await imageFile.readAsBytes();
    final image = pw.MemoryImage(imageBytes);

    final size = parseSize(template.displaySize);

    double labelW = inchToMm(size[0]);
    double labelH = inchToMm(size[1]);

    /// calculate grid
    final grid = calculateGrid(template.perSheet);
    int rows = grid[0];
    int columns = grid[1];
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(10 * PdfPageFormat.mm),
        build: (context) {
          return buildPdfGrid(template, image, labelW, labelH);
        },
      ),
    );
    return pdf.save();
  }

  List<int> calculateGrid(int perSheet) {
    int columns = (sqrt(perSheet)).ceil();
    int rows = (perSheet / columns).ceil();
    return [rows, columns];
  }

  Future<void> _handlePrint() async {
    final wifiOn = await isWifiReallyOn();

    if (!wifiOn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TrText('wifi_location_required')),
        );
      }
      return;
    }

    final sameWifi = await isSameWifi();
    if (!sameWifi) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: TrText('same_wifi_required')));
      }
      return;
    }

    // setState(() => _isPrinting = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final provider = Provider.of<LabelProvider>(context, listen: false);

      final pdfBytes = await buildPrintablePdf(
        provider.selectedTemplate!,
        provider.selectedImage!,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TrText('printer_not_available')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  pw.Widget _buildPdfLabel(LabelTemplate template, pw.MemoryImage image) {
    final img = pw.Image(image, fit: pw.BoxFit.cover);

    switch (template.shape) {
      case LabelShape.round:
        return pw.ClipOval(child: img);

      case LabelShape.oval:
        return pw.ClipOval(child: img);

      case LabelShape.square:
        return img;

      case LabelShape.rectangle:
        return img;
    }
  }

  Widget _buildPreviewLabel(LabelTemplate template, File imageFile) {
    final image = Image.file(imageFile, fit: BoxFit.cover);

    switch (template.shape) {
      case LabelShape.round:
        return ClipOval(child: image);

      case LabelShape.oval:
        return ClipOval(child: image);

      case LabelShape.square:
        return image;

      case LabelShape.rectangle:
        return image;
    }
  }

  pw.Widget buildPdfGrid(
    LabelTemplate template,
    pw.MemoryImage image,
    double labelW,
    double labelH,
  ) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: List.generate(template.rows, (row) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: List.generate(template.columns, (col) {
              return pw.Container(
                width: labelW * PdfPageFormat.mm,
                height: labelH * PdfPageFormat.mm,
                margin: const pw.EdgeInsets.all(2),
                child: _buildPdfLabel(template, image),
              );
            }),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LabelProvider>(context);
    final template = provider.selectedTemplate!;
    final imageFile = provider.selectedImage!;
    final size = parseSize(template.displaySize);
    double ratio = size[0] / size[1];
    if (template.shape == LabelShape.oval && template.perSheet == 4) {
      ratio = ratio * 1.3; // adjust height
    }
    final grid = calculateGrid(template.perSheet);
    int rows = grid[0];
    int columns = grid[1];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'preview',
        actions: [
          IconButton(
            icon: _isPrinting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                     color: AppColors.primaryColor
                    ),
                  )
                : const Icon(Icons.print, size: 24, color: Colors.black),
            onPressed: _isPrinting
                ? null
                : () async {
                    final adsProvider = context.read<AdsProvider>();

                    /// ✅ 1. Show Ad FIRST
                    await adsProvider.showAdInterstitial();

                    if (!mounted) return;

                    /// ✅ 2. Start Loader
                    setState(() => _isPrinting = true);

                    /// ✅ 3. Small delay (IMPORTANT)
                    // await Future.delayed(const Duration(milliseconds: 100));

                    /// ✅ 4. Start printing
                    await _handlePrint();

                    /// ✅ 5. Stop loader
                    if (mounted) {
                      setState(() => _isPrinting = false);
                    }
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.05)),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8), // same as pdf margin
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: template.rows * template.columns,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: template.columns,
                    mainAxisSpacing: 6, // same spacing as pdf
                    crossAxisSpacing: 6,
                    childAspectRatio: ratio,
                  ),
                  itemBuilder: (context, index) {
                    if (index >= template.perSheet) {
                      return const SizedBox();
                    }

                    return Container(
                      margin: const EdgeInsets.all(
                        2,
                      ), // same as pdf container margin
                      child: _buildPreviewLabel(template, imageFile),
                    );
                  },
                ),
              ),
            ),
          ),
          if (_isPrinting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
              ),
            ),
        ],
      ),
    );
  }
}
