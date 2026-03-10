import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

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
      appBar: AppBar(
          automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // same as appbar
          statusBarIconBrightness: Brightness.dark, // dark icons
          statusBarBrightness: Brightness.light,
        ),
        foregroundColor: Colors.transparent,
        
        title: const TrText('preview',   style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),),
           centerTitle: true,
            leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
        ),
          ),
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
        return const Center(
          child: CircularProgressIndicator(),
        );
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
               Expanded(child: CustomButton(text: 'done', onPressed: () => onKeep(context),)),
             
              ],
            ),

          ),
          SizedBox(height: 16,)
        ],
      ),
    );
  }
}