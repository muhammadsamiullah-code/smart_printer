import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor (prevent instance creation)

  // =========================
  // 🎨 Solid Colors
  // =========================

  static const Color primaryColor = Color.fromRGBO(10, 77, 146, 1);
  static const Color secondary = Color(0xFF0A4D92);
  static const Color lightBlue = Color(0xFFA1CFFF);

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF777777);

  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);

  // =========================
  // 🌈 Linear Gradients
  // =========================

  static const LinearGradient onboardingGradient = LinearGradient(
    colors: [Color.fromRGBO(161, 207, 255, 1), Color.fromRGBO(10, 77, 146, 1)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color.fromRGBO(11, 109, 209, 1), Color.fromRGBO(10, 77, 146, 1)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF28A745), Color(0xFF1E7E34)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFC107), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
