import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_scanner/camera_preview_screen.dart';
import 'package:smart_scanner/frame_selection_screen.dart';
import 'package:smart_scanner/format_selection_screen.dart';
import 'package:smart_scanner/pdf_preview_screen.dart';
import 'package:smart_scanner/web_page_scanner_screen.dart';

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({super.key});

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  
  Future<void> pickFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: [
      'pdf',
      'doc',
      'docx',
      'ppt',
      'pptx',
      'xls',
      'xlsx',
      'txt',
      'html',
      'htm',
      'csv',
      'xml',
      'json'
    ],
  );

  if (result != null && result.files.single.path != null) {
    final path = result.files.single.path!;
    final extension = path.split('.').last.toLowerCase();

    // ✅ If PDF → open preview
    if (extension == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(path: path),
        ),
      );
    } 
    // ❌ If NOT PDF → Show dialog
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("File Not Supported"),
          content: const Text(
              "Please first convert this file into PDF for printing."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }
}

  // Future<void> pickFile() async {
  //   final result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf'],
  //   );

  //   if (result != null && result.files.single.path != null) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (_) => PdfPreviewScreen(path: result.files.single.path!),
  //       ),
  //     );
  //   }
  // }

  Future<void> pickGalleryImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 90);

    if (pickedFiles.isNotEmpty) {
      // Convert to File list
      final files = pickedFiles.map((e) => File(e.path)).toList();

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/gallery_preview.pdf';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            path: path,
            initialImages: files, // 👈 Gallery images as initial pages
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Printer')),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: pickFile,
              child: const Text('Select PDF'),
            ),
          ),
          SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => CameraScreen()),
                // );
              },
              child: const Text('camera screen'),
            ),
          ),
           SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push<File>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WebPageScannerScreen(),
                  ),
                );

                if (result != null) {
                  final dir = await getTemporaryDirectory();
                  final path = '${dir.path}/web_scan_preview.pdf';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PdfPreviewScreen(path: path, initialImages: [result]),
                    ),
                  );
                }
              },
              child: const Text('Open web page scanner'),
            ),
          ),
           SizedBox(height: 50),
          Center(
            child: ElevatedButton(
              onPressed: pickGalleryImages,
              child: const Text('Select Gallery Image(s)'),
            ),
          ),
           SizedBox(height: 50),
            Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FrameSelectionScreen()),
                );
              },
              child: const Text('Frame Selection'),
            ),
          ),
          SizedBox(height: 50),
            Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FormatSelectionScreen()),
                );
              },
              child: const Text('Layout Selection Image'),
            ),
          ),
        ],
      ),
    );
  }
}
