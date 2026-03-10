import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_scanner/widgets/tr_text.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPageScannerScreen extends StatefulWidget {
  const WebPageScannerScreen({super.key});

  @override
  State<WebPageScannerScreen> createState() => _WebPageScannerScreenState();
}

class _WebPageScannerScreenState extends State<WebPageScannerScreen> {
  late final WebViewController _controller;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.google.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: AppBar(
        automaticallyImplyLeading: false,
         backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // same as appbar
          statusBarIconBrightness: Brightness.dark, // dark icons
          statusBarBrightness: Brightness.light,
        ),
        foregroundColor: Colors.transparent,
        title: const TrText(
          'browser',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28, color: Colors.black),
            onPressed: () async {
              final image = await _screenshotController.capture();
              if (image != null) {
                final file = File(
                  '${(await getTemporaryDirectory()).path}/web_${DateTime.now().millisecondsSinceEpoch}.png',
                );
                await file.writeAsBytes(image);
                Navigator.pop(context, file);
              }
            },
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
