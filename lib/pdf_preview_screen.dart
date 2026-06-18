import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/providers/translator_provider.dart';
import 'package:smart_scanner/single_page_view.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:smart_scanner/screens/web_page_scanner_screen.dart';
import 'package:smart_scanner/widgets/custom_appbar.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

enum PageType { pdf, image }

class PreviewPage {
  final PageType type;
  final int? pdfPage;
  final File? image;

  PreviewPage.pdf(this.pdfPage) : type = PageType.pdf, image = null;

  PreviewPage.image(this.image) : type = PageType.image, pdfPage = null;
}

class PdfPreviewScreen extends StatefulWidget {
  final String path;
  final List<File>? initialImages;

  const PdfPreviewScreen({super.key, required this.path, this.initialImages});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  PdfDocument? _document;

  // late PdfDocument _document;
  final List<PreviewPage> pages = [];
  int currentIndex = 1;
  final ScrollController _scrollController = ScrollController();
  final double pageHeight = 500; // thumbnail approx height
  bool _isPrinting = false;
  final Map<int, Uint8List> _thumbCache = {};
  bool selectionMode = false;
  Set<int> selectedIndexes = {};
  @override
  void initState() {
    super.initState();
    _loadPdf();
    if (widget.initialImages != null) {
      pages.addAll(widget.initialImages!.map((img) => PreviewPage.image(img)));
    }
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      final maxOffset = _scrollController.position.maxScrollExtent;
      final viewport = _scrollController.position.viewportDimension;

      int index;

      // ✅ Last page detection
      if (offset + viewport >= maxOffset - 10) {
        index = pages.length;
      } else {
        index = (offset / pageHeight).floor() + 1;
      }

      if (index != currentIndex && index >= 1 && index <= pages.length) {
        setState(() {
          currentIndex = index;
        });
      }
    });
  }

  Future<void> _loadPdf() async {
    if (widget.path.isEmpty) return; // no PDF

    try {
      _document = await PdfDocument.openFile(widget.path);

      for (int i = 1; i <= _document!.pagesCount; i++) {
        pages.add(PreviewPage.pdf(i));
      }

      setState(() {});
    } catch (e) {
      // Agar file invalid hai ya PDF nahi, ignore
      _document = null;
      debugPrint('PDF load failed: $e');
    }
  }

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();

    if (picked.isNotEmpty) {
      setState(() {
        pages.addAll(picked.map((e) => PreviewPage.image(File(e.path))));
      });
    }
  }

  Future<void> captureFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (picked != null) {
      setState(() {
        pages.add(PreviewPage.image(File(picked.path)));
      });

      // 📌 Optional: newly added page pe scroll
      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> addBlankPage() async {
    double width = 1080;
    double height = 1920;

    if (_document != null && _document!.pagesCount > 0) {
      final page = await _document!.getPage(1);
      width = page.width.toDouble();
      height = page.height.toDouble();
      await page.close();
    }

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      Paint()..color = Colors.white,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ImageByteFormat.png);

    final file = File(
      '${(await getTemporaryDirectory()).path}/blank_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    setState(() {
      pages.add(PreviewPage.image(file));
    });

    await Future.delayed(const Duration(milliseconds: 300));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> openPage(int index) async {
    final page = pages[index];

    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => page.type == PageType.pdf
            ? SinglePageViewerScreen.pdf(
                pdfPath: widget.path,
                pdfPageNumber: page.pdfPage!,
              )
            : SinglePageViewerScreen.image(image: page.image!),
      ),
    );

    if (result != null) {
      setState(() {
        pages[index] = PreviewPage.image(result);
      });
    }
  }

  Future<Uint8List> buildPrintablePdf() async {
    final pdf = pw.Document();

    for (final page in pages) {
      if (page.type == PageType.pdf) {
        // 🔹 PDF page ko image bana ke add
        final pdfPage = await _document!.getPage(page.pdfPage!);
        final img = await pdfPage.render(
          width: pdfPage.width,
          height: pdfPage.height,
        );

        final image = pw.MemoryImage(img!.bytes);

        pdf.addPage(pw.Page(build: (_) => pw.Center(child: pw.Image(image))));

        await pdfPage.close();
      } else {
        // 🔹 Image page
        final bytes = await page.image!.readAsBytes();
        final image = pw.MemoryImage(bytes);

        pdf.addPage(pw.Page(build: (_) => pw.Center(child: pw.Image(image))));
      }
    }

    return pdf.save();
  }

  Future<bool> isWifiOn() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    return result == ConnectivityResult.wifi;
  }

  Future<bool> isSameWifi() async {
    final info = NetworkInfo();
    final ssid = await info.getWifiName();

    // agar ssid null ya empty hai → same wifi nahi
    return ssid != null && ssid.isNotEmpty;
  }

  Future<bool> hasInternet() async {
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
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
    final wifiName = await info.getWifiName(); // <-- REAL CHECK

    return wifiName != null && wifiName.isNotEmpty;
  }

  Future<void> printAllPages() async {
    final wifiOn = await isWifiReallyOn();

    if (!wifiOn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TrText('wifi_location_required')),
        );
      }
      return;
    }

    /// 🛑 CASE 2: Printer & Mobile same Wi-Fi par nahi
    final sameWifi = await isSameWifi();
    if (!sameWifi) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: TrText("same_wifi_required")));
      }
      return;
    }

    // ✅ Printing allowed
    setState(() => _isPrinting = true);

    try {
      await Future.delayed(const Duration(seconds: 2));

      final pdfBytes = await buildPrintablePdf();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: TrText("printer_not_available")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> scanFromWeb() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const WebPageScannerScreen()),
    );

    if (result != null) {
      setState(() {
        pages.add(PreviewPage.image(result));
      });

      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<Uint8List> _getThumbnail(int pageNumber) async {
    if (_thumbCache.containsKey(pageNumber)) {
      return _thumbCache[pageNumber]!;
    }

    final page = await _document!.getPage(pageNumber);

    final img = await page.render(width: page.width, height: page.height);

    await page.close();

    _thumbCache[pageNumber] = img!.bytes;

    return img.bytes;
  }

  void deleteSelectedPages() {
    setState(() {
      pages.removeWhere(
        (page) => selectedIndexes.contains(pages.indexOf(page)),
      );

      selectedIndexes.clear();
      selectionMode = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _document = null;
    _thumbCache.clear(); // if using cache map
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pages.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
          ),
          title: Text(''),
        ),
        body: Center(
          child: TrText(
            'no_pages_to_display',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    }
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xffEDEDED),
          appBar: CustomAppBar(
            title: selectionMode
                ? "${selectedIndexes.length} ${context.watch<TranslatorProvider>().tr("selected_pages")}"
                : "${context.watch<TranslatorProvider>().tr("page_counter")} $currentIndex / ${pages.length}",
            actions: [
              if (!selectionMode)
                IconButton(
                  icon: const Icon(
                    Icons.checklist,
                    size: 24,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      selectionMode = true;
                    });
                  },
                ),
              if (selectionMode)
                IconButton(
                  icon: const Icon(Icons.delete, size: 24, color: Colors.black),
                  onPressed: deleteSelectedPages,
                ),
              if (selectionMode)
                IconButton(
                  icon: const Icon(Icons.close, size: 24, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      selectionMode = false;
                      selectedIndexes.clear();
                    });
                  },
                ),
            ],
          ),
          body: ListView.builder(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
            itemCount: pages.length,
            itemBuilder: (_, index) {
              final page = pages[index];

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 20,
                ),
                child: Center(
                  child: Container(
                    height: pageHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: selectedIndexes.contains(index)
                          ? AppColors.primaryColor.withOpacity(0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: selectedIndexes.contains(index)
                          ? Border.all(color: AppColors.primaryColor, width: 2)
                          : null,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (selectionMode) {
                          setState(() {
                            if (selectedIndexes.contains(index)) {
                              selectedIndexes.remove(index);
                            } else {
                              selectedIndexes.add(index);
                            }
                          });
                        } else {
                          setState(() => currentIndex = index + 1);
                          openPage(index);
                        }
                      },
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),

                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: RepaintBoundary(
                                  child: page.type == PageType.pdf
                                      ? FutureBuilder<Uint8List>(
                                          future: _getThumbnail(page.pdfPage!),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      color: AppColors
                                                          .primaryColor,
                                                    ),
                                              );
                                            }

                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.contain,
                                            );
                                          },
                                        )
                                      : Image.file(
                                          page.image!,
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              ),

                              /// ✅ Selection Icon
                              if (selectionMode)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Icon(
                                    selectedIndexes.contains(index)
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: AppColors.primaryColor,
                                    size: 28,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                actionButton(
                  icon: Icons.add_photo_alternate,
                  label: "gallery",
                  onTap: pickImages,
                ),
                actionButton(
                  icon: Icons.camera_alt,
                  label: "camera",
                  onTap: captureFromCamera,
                ),
                actionButton(
                  icon: Icons.check_box_outline_blank_outlined,
                  label: "blank",
                  onTap: addBlankPage,
                ),
                actionButton(
                  icon: Icons.public,
                  label: "web",
                  onTap: scanFromWeb,
                ),
                actionButton(
                  icon: Icons.print_outlined,
                  label: "print",
                  onTap: _isPrinting
    ? null
    : () async {
        final wifiOn = await isWifiReallyOn();
        final sameWifi = await isSameWifi();

        if (!wifiOn || !sameWifi) {
          printAllPages(); // sirf error show karega
          return;
        }

        final adsProvider = context.read<AdsProvider>();

        /// 🔥 Only when valid → show ad
        await adsProvider.showAdInterstitial();

        await printAllPages();
      },
                  // onTap: _isPrinting
                  //     ? null
                  //     : () async {
                  //         final adsProvider = context.read<AdsProvider>();

                  //         /// 🔥 Step 1: Show Ad FIRST
                  //         await adsProvider.showAdInterstitial();

                  //         /// 🔥 Step 2: Then start printing
                  //         await printAllPages();
                  //       },
                ),
              ],
            ),
          ),
        ),

        /// 🔄 LOADING OVERLAY (ON TOP OF EVERYTHING)
        if (_isPrinting)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [CircularProgressIndicator(color: AppColors.primaryColor)],
              ),
            ),
          ),
      ],
    );
  }

  Widget actionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 24, color: AppColors.primaryColor),
          onPressed: onTap,
        ),
        TrText(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
