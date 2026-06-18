

import 'package:flutter/material.dart';

import '../const/color.dart';
import 'tr_text.dart';

class CommonDeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  const CommonDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: TrText(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: TrText(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const TrText(
            "cancel",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),

        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onConfirm,
          child: const TrText("confirm"),
        ),
      ],
    );
  }
}