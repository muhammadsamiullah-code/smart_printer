
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

class CenterWidgetForPDF extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;
  final Color borderColor;

  const CenterWidgetForPDF({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.borderColor
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 90,
            width: 90,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color,
              border: Border.all(
                color: borderColor,
                width: 1,
              ),
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                height: 40,
                width: 40,
              ),
            ),
          ),

          const SizedBox(height: 16),

          TrText(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}