import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_scanner/screens/bottom_nav_screeen.dart';
import 'package:smart_scanner/screens/select_language_screen.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final box = GetStorage();
  int progress = 0;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (progress < 100) {
        setState(() {
          progress++;
        });
      } else {
        timer.cancel();

        final box = GetStorage();

        bool hasSelectedLanguage = box.read('hasSelectedLanguage') ?? false;
        bool isOnboarded = box.read('onboardingDone') ?? false;

        if (!hasSelectedLanguage) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SelectLanguageScreen()),
          );
        } else if (!isOnboarded) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          // Positioned.fill(
          //   child: Image.asset(
          //     "assets/images/splash_bg.png",
          //     fit: BoxFit.cover,
          //   ),
          // ),

          /// Exact Matching Gradient Overlay
          Positioned.fill(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(20, 155, 160, 1), // Teal top
                    Color.fromRGBO(10, 77, 146, 1), // Deep Blue bottom
                  ],
                ),
              ),
            ),
          ),

          /// Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Icon Container
              SizedBox(
                width: double.infinity,
                // padding: const EdgeInsets.all(22),
                // decoration: BoxDecoration(
                //   color: const Color(0xFF1565C0),
                //   borderRadius: BorderRadius.circular(14),
                // ),
                child: Image.asset(
                  'assets/images/printerImage.png',
                  height: 170,
                  width: 170,
                ),
              ),

              const SizedBox(height: 10),

              const TrText(
                "app_name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          /// Animated Loading Text
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: TrText(
                "Loading ($progress%).....",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
