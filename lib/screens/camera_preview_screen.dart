import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import '../widgets/custom_appbar.dart';

class CameraPreviewScreen extends StatelessWidget {
  final File image;
  final Function(BuildContext) onKeep;

  const CameraPreviewScreen({
    super.key,
    required this.image,
    required this.onKeep,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDEDED),
      appBar: CustomAppBar(title: 'preview'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(
                image,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return child;
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          // Expanded(child: Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Image.file(image),
          // )),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Expanded(child: CustomButton(text: 'Retake',  onPressed: () => Navigator.pop(context),)),
                // SizedBox(width: 10,),
                Expanded(
                  child: CustomButton(
                    text: 'done',
                    onPressed: () => onKeep(context),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
