
import 'package:flutter/material.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

Widget buildCommonFAB({
  required VoidCallback onPressed,
  required String label,
}) {
  return SizedBox(
    height: 50,
    child: FloatingActionButton.extended(
      backgroundColor: AppColors.primaryColor,
      onPressed: onPressed,
      label: TrText(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      extendedPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}