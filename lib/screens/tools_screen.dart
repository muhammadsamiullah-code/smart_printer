import 'package:flutter/material.dart';

import 'tools_data_screens/compress_pdf/compress_pdf_screen.dart';
import 'tools_data_screens/image_to_pdf/image_to_pdf_screen.dart';
import 'tools_data_screens/merge_pdf/merge_pdf_screen.dart';
import 'tools_data_screens/reverse_pdf/reverse_pdf.dart';
import 'tools_data_screens/split_pdf/split_pdf_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center ,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
        child: ElevatedButton(
          child: const Text("Merge PDF"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MergePdfScreen(),
              ),
            );
          },
        ),
      ),
      SizedBox(height: 20,),
         Center(
        child: ElevatedButton(
          child: const Text("Split PDF"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SplitPdfScreen(),
              ),
            );
          },
        ),
        
      ),
       SizedBox(height: 20,),
         Center(
        child: ElevatedButton(
          child: const Text("Image to PDF Convert"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ImageToPdfScreen(),
              ),
            );
          },
        ),
        
      ),
       SizedBox(height: 20,),
         Center(
        child: ElevatedButton(
          child: const Text("Compress Pdf "),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CompressPdfScreen(),
              ),
            );
          },
        ),
        
      ),
        SizedBox(height: 20,),
         Center(
        child: ElevatedButton(
          child: const Text("Compress Pdf "),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReversePdfScreen(),
              ),
            );
          },
        ),
        
      ),
        ],
      ),
    );
  }
}