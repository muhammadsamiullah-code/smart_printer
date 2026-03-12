import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/custom_appbar.dart';

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
      appBar: CustomAppBar(title: 'browser', 
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
