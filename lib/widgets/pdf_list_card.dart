
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PdfListCard extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const PdfListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(206, 230, 254, 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset('assets/imageIcons/pdfIcon.svg'),
        ),

        title: Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),

        /// 🔥 optional subtitle
        subtitle: subtitle,

        /// 🔥 optional trailing
        trailing: trailing,

        onTap: onTap,
      ),
    );
  }
}