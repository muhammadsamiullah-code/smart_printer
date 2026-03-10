import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_scanner/widgets/tr_text.dart';
import '../const/color.dart';
import '../widgets/bottom_dip_clipper.dart';
import '../widgets/custom_button.dart';
import 'bottom_nav_screeen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final box = GetStorage();
  //wifi_info_plugin_plus
  // final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "image": "assets/images/onBoardingOne.png",
      "title": "title_print_easy",
      "subtitle": "subtitle_print_easy",
      "button": "button_get_started",
    },
    {
      "image": "assets/images/onBoardingTwo.png",
      "title": "title_connect_printer",
      "subtitle": "",
      "button": "button_continue",
    },
    {
      "image": "assets/images/onBoardingThree.png",
      "title": "title_wifi_print",
      "subtitle": "",
      "button": "button_next",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: buildPage(
        image: pages[currentIndex]["image"]!,
        title: pages[currentIndex]["title"]!,
        subtitle: pages[currentIndex]["subtitle"]!,
        buttonText: pages[currentIndex]["button"]!,
        isLast: currentIndex == pages.length - 1,
      ),
    );
  }

  Widget buildPage({
    required String image,
    required String title,
    required String subtitle,
    required String buttonText,
    required bool isLast,
  }) {
    return Column(
      children: [
        /// TOP CURVED SECTION SAME RAHE GA
        Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                gradient: AppColors.onboardingGradient,
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: BottomDipClipper(),
                child: Container(height: 220, color: Colors.white),
              ),
            ),

            /// 🔥 Animated Image
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Image.asset(
                      image,
                      key: ValueKey(image),
                      height: 320,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        /// 🔥 Animated Title
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: Padding(
            key: ValueKey(title),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: TrText(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 0, 0, 1),
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// 🔥 Animated Subtitle
        if (subtitle.isNotEmpty)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Padding(
              key: ValueKey(subtitle),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: TrText(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromRGBO(130, 130, 130, 1),
                ),
              ),
            ),
          ),

        const Spacer(),

        /// DOTS SAME RAHEN GY
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: currentIndex == index ? 10 : 8,
              height: currentIndex == index ? 10 : 8,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? const Color(0xFF174EA6)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        /// 🔥 BUTTON
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: CustomButton(
            text: buttonText,
            textStyle: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            onPressed: () {
              if (!isLast) {
                setState(() {
                  currentIndex++;
                });
              } else {
                box.write('onboardingDone', true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BottomNavScreen(),
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
