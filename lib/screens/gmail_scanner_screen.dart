import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/custom_appbar.dart';

class GmailScannerScreen extends StatefulWidget {
  const GmailScannerScreen({super.key});

  @override
  State<GmailScannerScreen> createState() => _GmailScannerScreenState();
}

class _GmailScannerScreenState extends State<GmailScannerScreen> {
  late final WebViewController _controller;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse('https://mail.google.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
         backgroundColor: const Color(0xffEDEDED),
      appBar: CustomAppBar(
        
         title: 'gmail',
         actions: [
          IconButton(
             icon: const Icon(Icons.check, size: 28, color: Colors.black),
            onPressed: () async {
              final image = await _screenshotController.capture();
              if (image != null) {
                final file = File(
                  '${(await getTemporaryDirectory()).path}/gmail_${DateTime.now().millisecondsSinceEpoch}.png',
                );
                await file.writeAsBytes(image);
                Navigator.pop(context, file);
              }
            },
          )
        ],
      ),
        
      
      body: Screenshot(
        controller: _screenshotController,
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}