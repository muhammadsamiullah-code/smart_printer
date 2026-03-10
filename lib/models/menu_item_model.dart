
import 'package:flutter/material.dart';
class MenuItemModel {
  final String svgPath;
  final String title;
  final Color color;
  final VoidCallback onTap;

  MenuItemModel({
    required this.svgPath,
    required this.title,
    required this.color,
    required this.onTap,
  });
}