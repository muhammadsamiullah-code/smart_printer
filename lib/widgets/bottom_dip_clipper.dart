
import 'package:flutter/material.dart';

class BottomDipClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start from top left
    path.lineTo(0, 0);

    // Go to curve start point
    path.lineTo(0, 60);

    // Downward dip curve (\_/)
    path.quadraticBezierTo(
      size.width / 2,   // control point X
      140,              // 👈 yahan value zyada hogi to curve aur nichay jayega
      size.width,
      0,
    );

    // Complete rectangle
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}