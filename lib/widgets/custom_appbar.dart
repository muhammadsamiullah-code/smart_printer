import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color iconColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final bool centerTitle;
    final PreferredSizeWidget? bottom; // 👈 optional bottom widget

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.backgroundColor = Colors.transparent,
    this.iconColor = Colors.black,
    this.titleFontSize = 22,
    this.titleFontWeight = FontWeight.w600,
    this.centerTitle = true,
     this.bottom, // 👈 constructor
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      foregroundColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 24,
                color: iconColor,
              ),
            )
          : null,
      title: TrText(
        title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: titleFontWeight,
          color: iconColor,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}