import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_scanner/screens/select_language_screen.dart';
import 'package:smart_scanner/widgets/custom_appbar.dart';
import 'package:smart_scanner/widgets/tr_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'tools_data_screens/merge_pdf/pdf_results_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
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
      queryParameters: {'subject': 'Smart Printer', 'body': ''},
    );
    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $emailUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xffF5F6FA),
    // appBar: CustomAppBar(title: 'settings_title', 
    // showBackButton: false,
    // ),
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   // leading: const BackButton(color: Colors.black),
      //   title: const TrText(
      //     "settings_title",
      //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
      //   ),
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
               Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TrText(
                'settings_title',
                style: TextStyle(
                  // color: titleColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
              _buildTile(
                svgPath: 'assets/settingIcons/sendFeedback.svg',
                titleKey: "send_feedback",
                onTap: _sendEmail,
              ),
              const SizedBox(height: 14),
              _buildTile(
                svgPath: 'assets/settingIcons/termCondition.svg',
                titleKey: "terms_to_use",
                onTap: () {
                  _launchURL("https://www.toclicksol.com/terms-conditions");
                },
              ),
              const SizedBox(height: 14),
              _buildTile(
                svgPath: 'assets/settingIcons/privacyPolicy.svg',
                titleKey: "privacy_policy",
                onTap: () {
                  _launchURL("https://www.toclicksol.com/privacy-policy");
                },
              ),
              const SizedBox(height: 14),
              _buildTile(
                svgPath: 'assets/settingIcons/shareApp.svg',
                titleKey: "share_app",
                onTap: () {},
              ),
              const SizedBox(height: 14),
              _buildTile(
                svgPath: 'assets/settingIcons/moreApp.svg',
                titleKey: "more_apps",
                onTap: () {},
              ),
              const SizedBox(height: 14),
              _buildTile(
                svgPath: 'assets/settingIcons/language.svg',
                titleKey: "change_language",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const SelectLanguageScreen(fromSettings: true),
                    ),
                  );
                },
              ),
               const SizedBox(height: 14),
              // _buildTile(
              //   svgPath: 'assets/settingIcons/language.svg',
              //   titleKey: "tools",
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) =>
              //             const ResultScreen(),
              //       ),
              //     );
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required String svgPath,
    required String titleKey,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
           border: Border.all(
                color: const Color.fromARGB(255, 231, 231, 231),
                width: 1,
              ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.04),
          //     blurRadius: 6,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xffEAF2FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(svgPath, height: 24, width: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TrText(
                titleKey,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
