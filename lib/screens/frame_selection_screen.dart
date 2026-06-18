import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/screens/format_selection_screen.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:smart_scanner/widgets/snack_bar_helper.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

import '../widgets/custom_appbar.dart';
// ---------------- FRAME SELECTION SCREEN ----------------

class FrameSelectionScreen extends StatefulWidget {
  const FrameSelectionScreen({super.key});

  @override
  State<FrameSelectionScreen> createState() => _FrameSelectionScreenState();
}

class _FrameSelectionScreenState extends State<FrameSelectionScreen> {
  int selectedFrame = 0;

  double _paddingForFrame(int frame) {
    switch (frame) {
      case 0:
        return 0;
      case 1:
        return 8;
      case 2:
        return 16;
      case 3:
        return 8;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: CustomAppBar(title: 'select_frame'),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedFrame = index),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedFrame == index
                            ? AppColors.primaryColor
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(_paddingForFrame(index)),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                                ),
                                if (index == 3) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 22,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black54),
                                    ),
                                    child: const TrText(
                                      'text_area',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          selectedFrame == index
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selectedFrame == index
                              ? AppColors.primaryColor
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'next',
              onPressed: () async {
                if (selectedFrame == -1) {
                  SnackbarHelper.show(context, "Please Select Frame");
                  return;
                }
                final picker = ImagePicker();
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (image == null) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PreviewScreen(
                      frame: selectedFrame,
                      imageFile: File(image.path),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- PREVIEW SCREEN ----------------

class PreviewScreen extends StatefulWidget {
  final int frame;
  final File imageFile;

  const PreviewScreen({
    super.key,
    required this.frame,
    required this.imageFile,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: _defaultLorem100());
  }

  String _defaultLorem100() {
    return 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. '
        'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ';
  }

  double _paddingForFrame() {
    switch (widget.frame) {
      case 0:
        return 0;
      case 1:
        return 8;
      case 2:
        return 16;
      case 3:
        return 8;
      default:
        return 0;
    }
  }

  Future<Uint8List> buildPrintablePdf() async {
    final pdf = pw.Document();

    final bytes = await widget.imageFile.readAsBytes();

    final image = pw.MemoryImage(bytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Container(
              decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
              child: pw.Image(image, fit: pw.BoxFit.contain),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<bool> isWifiReallyOn() async {
    final granted = await ensureLocationPermission();
    if (!granted) return false;

    final info = NetworkInfo();
    final wifiName = await info.getWifiName(); // <-- REAL CHECK

    return wifiName != null && wifiName.isNotEmpty;
  }

  Future<void> printImage() async {
    final wifiOn = await isWifiReallyOn();

    if (!wifiOn) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText('wifi_location_required')));
      return;
    }

    final sameWifi = await isSameWifi();
    if (!sameWifi) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText('same_wifi_required')));
      return;
    }

    try {
      final pdfBytes = await buildPrintablePdf();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText('printer_not_available')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: CustomAppBar(
        title: 'preview',
        actions: [
          IconButton(
            icon: const Icon(Icons.print, size: 24, color: Colors.black),
            onPressed: () async {
              final adsProvider = context.read<AdsProvider>();

              /// ✅ 1. Show Ad FIRST
              await adsProvider.showAdInterstitial();

              if (!mounted) return;

              /// ✅ 2. Show Loader
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                ),
              );

              /// ✅ 3. UI render delay (IMPORTANT)
              // await Future.delayed(const Duration(milliseconds: 100));

              try {
                /// ✅ 4. Call your function
                await printImage();
              } finally {
                /// ✅ 5. Close Loader safely
                if (mounted && Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                ),
                padding: EdgeInsets.all(_paddingForFrame()),
                child: Column(
                  children: [
                    Image.file(widget.imageFile),
                    if (widget.frame == 3) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller,
                        maxLines: null,
                        minLines: 4,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
