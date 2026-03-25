
import 'package:flutter/material.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

class CustomButton extends StatelessWidget {
  final String text; // required
  final VoidCallback ? onPressed; // required
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding ;
  final Color ? backgroundColor;
  final double borderRadius;
  final TextStyle? textStyle;
 final Color? borderColor;
  final double borderWidth;
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 50,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.backgroundColor,
    this.borderRadius = 14,
    this.textStyle,
     this.borderColor,        // optional
    this.borderWidth = 1.5,  // default width
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: AppColors.buttonGradient,
          border: borderColor != null ? Border.all(color: borderColor!, width: borderWidth) : null,
        ),
        child: Center(
          child: TrText(
            text,
            style: textStyle ??
                const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}


class CustomButtonWithBorder extends StatelessWidget {
  final String text; // required
  final VoidCallback ? onPressed; // required
  final double height;
  final double? width;
  final EdgeInsetsGeometry padding ;
  final Color ? backgroundColor;
  final double borderRadius;
  final TextStyle? textStyle;
 final Color? borderColor;
  final double borderWidth;
  const CustomButtonWithBorder({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 50,
    this.width,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.backgroundColor,
    this.borderRadius = 14,
    this.textStyle,
     this.borderColor,        // optional
    this.borderWidth = 1.5,  // default width
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          // gradient: AppColors.buttonGradient,
          border: borderColor != null ? Border.all(color: borderColor!, width: borderWidth) : null,
        ),
        child: Center(
          child: TrText(
            text,
            style: textStyle ??
                const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
          ),
        ),
      ),
    );
  }
}