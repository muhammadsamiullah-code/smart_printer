

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

import '../providers/translator_provider.dart';

Future<void> showCommonInputDialog({
  required BuildContext context,
  required String titleKey,
  required String buttonKey,
  required TextEditingController controller,
  required Future<void> Function() onPressed,
}) async {
  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      title: TrText(titleKey),
      content: TextField(
        controller: controller,
        cursorColor: AppColors.primaryColor,
        decoration: InputDecoration(
          hintText: context.watch<TranslatorProvider>().tr("rename_your_file"),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),

          onPressed: () => Navigator.pop(context),
          child: const TrText("cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),

          onPressed: () async {
            await onPressed();
          },
          child: TrText(buttonKey),
        ),
      ],
    ),
  );
}
