import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/providers/translator_provider.dart';
import 'package:smart_scanner/screens/pdf_scan_view.dart';
import 'package:smart_scanner/screens/tools_screen.dart';
import '../providers/bottom_nav_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
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
      // const ToolsScreen(),
      SizedBox(),
      const SettingScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavProvider>().setIndex(widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          // backgroundColor: const Color.fromRGBO(246, 247, 250, 1),

          /// ✅ Smooth Screen Switching
          body: Stack(
            children: [
              IndexedStack(index: provider.currentIndex, children: screens),
              if (provider.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
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
                  final result = await FlutterDocScanner()
                      .getScannedDocumentAsPdf();

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
              // onTap: (index) {
              //   provider.setIndex(index);
              // },
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
              items: [
                BottomNavigationBarItem(
                  icon: provider.currentIndex == 0
                      ? _selectedIcon('assets/bottomNavImages/homeColor.svg')
                      : SvgPicture.asset('assets/bottomNavImages/home.svg'),
                  label: context.watch<TranslatorProvider>().tr("home"),
                ),

                // BottomNavigationBarItem(
                //   icon: provider.currentIndex == 1
                //       ? _selectedIcon('assets/bottomNavImages/toolColor.svg')
                //       : SvgPicture.asset('assets/bottomNavImages/tool.svg'),
                //   label: context.watch<TranslatorProvider>().tr("tool"),
                // ),
                BottomNavigationBarItem(
                  icon: provider.currentIndex == 1
                      ? _selectedIcon('assets/bottomNavImages/scannerColor.svg')
                      : SvgPicture.asset('assets/bottomNavImages/scanner.svg'),
                  label: context.watch<TranslatorProvider>().tr("scanner"),
                ),
                BottomNavigationBarItem(
                  icon: provider.currentIndex == 2
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
      child: SvgPicture.asset(assetPath),
    );
  }
}
