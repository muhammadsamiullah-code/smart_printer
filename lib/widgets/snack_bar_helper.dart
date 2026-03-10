
import 'package:flutter/material.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

class SnackbarHelper {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TrText(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}