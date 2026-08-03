import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';
import 'package:smart_scanner/screens/bottom_nav_screeen.dart';
import 'package:smart_scanner/screens/select_language_screen.dart';
import 'package:smart_scanner/services/app_open_manager.dart';
import 'package:smart_scanner/subscription/purchase_provider.dart';
import 'package:smart_scanner/subscription/subscription_screen.dart';
import 'package:smart_scanner/widgets/tr_text.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  bool isSubscriptionShown = false;
  bool isLoadingCompleted = false;
  final box = GetStorage();
  int progress = 0;

  @override
  void initState() {
    super.initState();
    startLoading();

    Future.delayed(Duration.zero, () {
      context.read<AdsProvider>().loadAppOpenAd();
    });
  }

  void startLoading() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (progress < 100) {
        setState(() {
          progress++;
        });
      } else {
        timer.cancel();

        isLoadingCompleted = true;

        /// ✅ FIRST check subscription AFTER loading complete
        checkSubscriptionPopup();
      }
    });
  }

  Future<void> checkSubscriptionPopup() async {
    final count = await AppOpenManager.incrementAndGetCount();
    final isPremium = context.read<PurchaseProvider>().isPremium;

    if (isPremium) {
      proceedNavigation();
      return;
    }

    if (count % 3 == 0) {
      isSubscriptionShown = true;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      );

      /// 👇 User back → now continue
      proceedNavigation();
    } else {
      proceedNavigation();
    }
  }

  void proceedNavigation() {
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                child: Image.asset(
                  'assets/images/splashImage.png',
                  height: 170,
                  width: 170,
                ),
              ),

              const SizedBox(height: 10),

              const TrText(
                "smart_printer_mobile_documents",
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
          /// Loading Text + Progress Bar
          Positioned(
            bottom: 50,
            left: 90,
            right: 90,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: TrText(
                    "Loading ($progress%).....",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 12),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Positioned(
          //   bottom: 50,
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: TrText(
          //       "Loading ($progress%).....",
          //       style: const TextStyle(color: Colors.white70, fontSize: 14),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
