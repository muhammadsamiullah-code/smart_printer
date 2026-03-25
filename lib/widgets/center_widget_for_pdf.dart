
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

class CenterWidgetForPDF extends StatelessWidget {
  final String title;
  final String icon;
  final Color color;

  const CenterWidgetForPDF({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 120,
            width: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color,
            ),
            child: Center(
              child: SvgPicture.asset(
                icon,
                height: 50,
                width: 50,
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