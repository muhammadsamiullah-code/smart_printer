import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/providers/translator_provider.dart';
import 'package:smart_scanner/screens/pdf_scan_view.dart';
import 'package:smart_scanner/screens/tools_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ads/ads_provider.dart';
import '../ads/ads_widget.dart';
import '../providers/bottom_nav_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../services/rating_manager.dart';
import '../services/remote_config_service.dart';
import 'home_screen.dart';
import 'setting_screen.dart';

class BottomNavScreen extends StatefulWidget {
  final int initialIndex;

  const BottomNavScreen({super.key, this.initialIndex = 0});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  late final List<Widget> screens;

  Future<String> convertUriToFilePath(String uri) async {
    if (uri.startsWith("file://")) {
      return uri.replaceAll("file://", "");
    }

    if (uri.startsWith("content://")) {
      final bytes = await http.readBytes(Uri.parse(uri));

      final dir = await getTemporaryDirectory();
      final file = File(
        "${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.pdf",
      );

      await file.writeAsBytes(bytes);
      return file.path;
    }

    return uri;
  }

  @override
  void initState() {
    super.initState();

    // 👇 Screens ek hi dafa create hongi (important for smoothness)
    screens = [
      const HomeScreen(),
      SizedBox(),
      const ToolsScreen(),
      const SettingScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<BottomNavProvider>().setIndex(widget.initialIndex);
       final shouldShow = await RatingManager.shouldShowRatingDialog();

      if (shouldShow && mounted) {
        showRatingDialog(context);
      }
    });

  }

Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'help.bintahir@aol.com',
      queryParameters: {'subject': 'Smart Printer Feedback', 'body': ''},
    );
    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $emailUri');
    }
  }

  void showRatingDialog(BuildContext context) {
    double selectedRating = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return PopScope(
              canPop: false,

              child: AlertDialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.all(20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      child: const Text("😃", style: TextStyle(fontSize: 66)),
                    ),
                    SizedBox(height: 6),
                    const Text(
                      "We are working hard for a better user experience.",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        // height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "We’d greatly appreciate if you can rate us.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        // height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "The best we can get :)",
                        style: TextStyle(color: Colors.blue, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 5),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 42,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff79A8ED),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: selectedRating == 0
                            ? null
                            : () async {
                                Navigator.pop(context);

                                if (selectedRating == 5) {
                                  await RatingManager.saveFiveStarRating();

                                  _launchURL(
                                    "https://play.google.com/store/apps/details?id=smartprinter.mobileprint.wirelessprinter.printdocuments",
                                  );
                                } else {
                                  _sendEmail();
                                }
                              },
                        child: const Text(
                          "RATE",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: Colors.white,
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
      },
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          // backgroundColor: const Color.fromRGBO(246, 247, 250, 1),

          /// ✅ Smooth Screen Switching
          body: Column(
            children: [
              Consumer<AdsProvider>(
                builder: (context, adsProvider, child) {
                  final ads = adsProvider.ads;

                  final isBannerVisible =
                      RemoteConfigService.bannerEnabled &&
                      ads.bannerAd != null &&
                      ads.isBannerLoaded;

                  if (!isBannerVisible) {
                    return const SizedBox(height: 30);
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 30),
                      BannerAdWidget(adsManager: ads),
                      // const SizedBox(height: 10),
                    ],
                  );
                },
              ),
              Expanded(
                child: Stack(
                  children: [
                    IndexedStack(
                      index: provider.currentIndex,
                      children: screens,
                    ),
                    if (provider.isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: provider.currentIndex,
              onTap: (index) async {
                // ✅ Agar Scanner tab press hua
                if (index == 1) {
                  final adsProvider = context.read<AdsProvider>();

                  /// 🔥 Step 1: Show Ad FIRST
                  
                  final result = await FlutterDocScanner()
                      .getScannedDocumentAsPdf();
                    await adsProvider.showAdInterstitial();
                  final uri = result?.pdfUri;

                  if (uri == null) return;

                  final path = await convertUriToFilePath(uri);

                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfViewScanScreen(pdfPath: path),
                    ),
                  );

                  return; // ❗ index change na ho
                }

                // ✅ Baqi tabs normal kaam karein
                provider.setIndex(index);
              },
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: const Color.fromRGBO(108, 108, 108, 1),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              // iconSize: 24,
              items: [
                BottomNavigationBarItem(
                  icon: provider.currentIndex == 0
                      ? _selectedIcon('assets/bottomNavImages/homeColor.svg')
                      : SvgPicture.asset('assets/bottomNavImages/home.svg'),
                  label: context.watch<TranslatorProvider>().tr("home"),
                ),
                BottomNavigationBarItem(
                  icon: provider.currentIndex == 1
                      ? _selectedIcon('assets/bottomNavImages/scannerColor.svg')
                      : SvgPicture.asset('assets/bottomNavImages/scanner.svg'),
                  label: context.watch<TranslatorProvider>().tr("scanner"),
                ),

                BottomNavigationBarItem(
                  icon: provider.currentIndex == 2
                      ? _selectedIcon('assets/bottomNavImages/toolColor.svg')
                      : SvgPicture.asset('assets/bottomNavImages/tool.svg'),
                  label: context.watch<TranslatorProvider>().tr("tool"),
                ),

                BottomNavigationBarItem(
                  icon: provider.currentIndex == 3
                      ? _selectedIcon('assets/bottomNavImages/settingColor.svg')
                      : SvgPicture.asset('assets/bottomNavImages/setting.svg'),
                  label: context.watch<TranslatorProvider>().tr("setting"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ Selected icon reusable method
  Widget _selectedIcon(String assetPath) {
    return Container(
      height: 40,
      width: 46,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(222, 238, 255, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(assetPath, height: 20, width: 20),
    );
  }
}
