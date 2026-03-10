
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final Color backgroundColor;
  final Color titleColor;
  final Color iconColor;
  final bool showIcon;
  final bool useCloseIcon;
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.useCloseIcon = true,
    this.backgroundColor = Colors.transparent,
    this.titleColor = Colors.black,
    this.iconColor = Colors.pink,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: backgroundColor, // same as appbar
        statusBarIconBrightness: Brightness.dark, // dark icons
        statusBarBrightness: Brightness.light,
      ),
      title: Row(
        children: [
          if (showBackButton)
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                useCloseIcon ? Icons.close : Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white,
              ),
            ),
          if (showBackButton) const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
         
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}