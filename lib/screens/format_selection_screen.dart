import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/providers/translator_provider.dart';
import 'package:smart_scanner/subscription/purchase_provider.dart';
import 'package:smart_scanner/subscription/subscription_screen.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:smart_scanner/widgets/snack_bar_helper.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

import '../widgets/custom_appbar.dart';

class FormatSelectionScreen extends StatefulWidget {
  const FormatSelectionScreen({super.key});

  @override
  State<FormatSelectionScreen> createState() => _FormatSelectionScreenState();
}

class _FormatSelectionScreenState extends State<FormatSelectionScreen> {
  int selectedLayout = -1; // 2,4,6,9
  final ImagePicker picker = ImagePicker();
  List<XFile> images = [];

  Future<void> pickImages() async {
    if (selectedLayout == -1) return;

    final List<XFile> picked = await picker.pickMultiImage();

    if (picked.isEmpty) return;

    List<XFile> finalImages = picked;

    if (picked.length > selectedLayout) {
      finalImages = picked.take(selectedLayout).toList();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You selected ${picked.length} images. Only first $selectedLayout will be used.',
          ),
        ),
      );
    }

    if (picked.length < selectedLayout) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least $selectedLayout images'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DisplayScreen(images: finalImages)),
    );
  }

  bool isPremiumLayout(int count) {
    return count != 2; // sirf 2 free hai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: CustomAppBar(title: 'select_photo_layout'),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _layoutCard(2),
                _layoutCard(4),
                _layoutCard(6),
                _layoutCard(9),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'next',
              onPressed: () {
                if (selectedLayout == -1) {
                  SnackbarHelper.show(context, "please_seleect_photo_layout");
                  return;
                }

                pickImages();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _layoutCard(int count) {
    final isPremiumUser = context.watch<PurchaseProvider>().isPremium;
    final isLocked = isPremiumLayout(count) && !isPremiumUser;

    return GestureDetector(
      onTap: () {
        /// 🔒 LOCK CHECK
        // if (isLocked) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
        //   );
        //   return;
        // }

        // /// ✅ Allowed
        setState(() => selectedLayout = count);
      },
      child: Stack(
        children: [
          /// 🔹 MAIN CARD
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedLayout == count
                    ? AppColors.primaryColor
                    : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                '$count ${context.watch<TranslatorProvider>().tr("photos")}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// 🔒 LOCK ICON
          // if (isLocked)
          //   Positioned(
          //     top: 8,
          //     right: 8,
          //     child: Container(
          //       padding: const EdgeInsets.all(4),
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.6),
          //         borderRadius: BorderRadius.circular(20),
          //       ),
          //       child: const Icon(Icons.lock, color: Colors.white, size: 14),
          //     ),
          //   ),
        ],
      ),
    );
  }

  // Widget _layoutCard(int count) {
  //   return GestureDetector(
  //     onTap: () => setState(() => selectedLayout = count),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color: selectedLayout == count
  //               ? AppColors.primaryColor
  //               : Colors.grey,
  //           width: 2,
  //         ),
  //       ),
  //       child: Center(
  //         child: Text(
  //           '$count ${context.watch<TranslatorProvider>().tr("photos")}',
  //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class DisplayScreen extends StatefulWidget {
  final List<XFile> images;
  const DisplayScreen({super.key, required this.images});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
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
          'preview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, size: 24, color: Colors.black),
            onPressed: _isPrinting
                ? null
                : () async {
                    final wifiOn = await isWifiReallyOn();
                    final sameWifi = await isSameWifi();

                    if (!wifiOn || !sameWifi) {
                      await printAllPages();
                      return;
                    }

                    final adsProvider = context.read<AdsProvider>();

                    /// 🔥 Step 1: Show Ad
                    await adsProvider.showAdInterstitial();

                    if (!mounted) return;

                    /// 🔥 Step 2: START loader BEFORE heavy work
                    setState(() => _isPrinting = true);

                    /// 🔥 Step 3: Small delay so UI render ho jaye
                    await Future.delayed(const Duration(milliseconds: 100));

                    /// 🔥 Step 4: Start printing
                    await printAllPages();
                  },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    height: 500,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),

                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(widget.images[index].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isPrinting) const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
        ],
      ),
    );
  }

  // ---------------- PRINT LOGIC ----------------

  Future<Uint8List> buildPrintablePdf() async {
    final pdf = pw.Document();
    int getGridCount(int count) {
      if (count <= 2) return 2;
      if (count <= 4) return 2;
      if (count <= 6) return 3;
      return 3;
    }

    final imageWidgets = <pw.Widget>[];

    for (final img in widget.images) {
      final bytes = await img.readAsBytes();
      imageWidgets.add(
        pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.5)),
          child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.cover),
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.GridView(
            crossAxisCount: getGridCount(widget.images.length),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: imageWidgets,
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printAllPages() async {
    final wifiOn = await isWifiReallyOn();

    if (!wifiOn) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText("wifi_location_required")));
      return;
    }

    final sameWifi = await isSameWifi();
    if (!sameWifi) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText("same_wifi_required")));
      return;
    }

    // setState(() => _isPrinting = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final pdfBytes = await buildPrintablePdf();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText("printer_not_available")));
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }
}

// ---------------- WIFI & PERMISSION ----------------

Future<bool> isWifiOn() async {
  final connectivity = Connectivity();
  final result = await connectivity.checkConnectivity();
  return result == ConnectivityResult.wifi;
}

Future<bool> isSameWifi() async {
  final info = NetworkInfo();
  final ssid = await info.getWifiName();
  return ssid != null && ssid.isNotEmpty;
}

Future<bool> ensureLocationPermission() async {
  final status = await Permission.locationWhenInUse.status;
  if (status.isGranted) return true;
  final result = await Permission.locationWhenInUse.request();
  return result.isGranted;
}

Future<bool> isWifiReallyOn() async {
  final granted = await ensureLocationPermission();
  if (!granted) return false;

  final info = NetworkInfo();
  final wifiName = await info.getWifiName();
  return wifiName != null && wifiName.isNotEmpty;
}
