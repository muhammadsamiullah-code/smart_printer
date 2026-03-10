
import 'dart:ui';

import 'package:flutter/material.dart';

class PageText {
  Offset position;
  String text;

  double fontSize;
  bool bold;
  bool italic;
  bool underline;
  Color color;
  String fontFamily;

  PageText({
    required this.text,
    required this.position,
    this.fontSize = 22,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color = Colors.black,
    this.fontFamily = 'Roboto',
  });
}

