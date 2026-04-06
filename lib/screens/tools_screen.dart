import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/tr_text.dart';
import 'tools_data_screens/browse_pdf/browse_pdf_file_screen.dart';
import 'tools_data_screens/compress_pdf/compress_pdf_file_screen.dart';
import 'tools_data_screens/create_pdf/create_pdf_file_screen.dart';
import 'tools_data_screens/delete_pdf/delete_pdf_home.dart';
import 'tools_data_screens/image_to_pdf/image_to_pdf_file_screen.dart';
import 'tools_data_screens/merge_pdf/merge_pdf_files_screen.dart';
import 'tools_data_screens/page_number_pdf/page_number_file_screen.dart';
import 'tools_data_screens/qr_code_pdf/pdf_qr_file_screen.dart';
import 'tools_data_screens/reverse_pdf/reverse_pdf_file_screen.dart';
import 'tools_data_screens/rotation_pdf/rotate_pdf_file_screen.dart';
import 'tools_data_screens/signature_pdf/signature_pdf_file_screen.dart';
import 'tools_data_screens/split_pdf/split_pdf_file_screen.dart';
import 'tools_data_screens/watarmark_pdf/water_mark_pdf_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  bool isLoading = false;

  late List<Map<String, dynamic>> tools;

  @override
  void initState() {
    super.initState();

    tools = [
      {
        "title": "merge_pdf",
        "icon": "assets/toolsIcon/mergePDF.svg",
        "color": const Color.fromRGBO(225, 240, 255, 1),
      },
      {
        "title": "split_pdf",
        "icon": "assets/toolsIcon/splitPDF.svg",
        "color": const Color.fromRGBO(251, 238, 255, 1),
      },
      {
        "title": "create_pdf",
        "icon": "assets/toolsIcon/createPDF.svg",
        "color": const Color.fromRGBO(231, 255, 245, 1),
      },
      {
        "title": "image_to_pdf",
        "icon": "assets/toolsIcon/imageToPDF.svg",
        "color": const Color.fromRGBO(255, 243, 224, 1),
      },
      {
        "title": "qr_to_pdf",
        "icon": "assets/toolsIcon/qrToPDF.svg",
        "color": const Color.fromRGBO(209, 241, 255, 1),
      },
      {
        "title": "watermark_pdf",
        "icon": "assets/toolsIcon/watermarkPDF.svg",
        "color": const Color.fromRGBO(255, 237, 234, 1),
      },
      {
        "title": "page_number",
        "icon": "assets/toolsIcon/pageNoPDF.svg",
        "color": const Color.fromRGBO(226, 255, 253, 1),
      },
      {
        "title": "signature_pdf",
        "icon": "assets/toolsIcon/signaturePDF.svg",
        "color": const Color.fromRGBO(255, 242, 237, 1),
      },
      {
        "title": "reverse_pages",
        "icon": "assets/toolsIcon/reversePDF.svg",
        "color": const Color.fromRGBO(251, 238, 255, 1),
      },
      {
        "title": "browse_pdf",
        "icon": "assets/toolsIcon/browserPDF.svg",
        "color": const Color.fromRGBO(225, 240, 255, 1),
      },
      {
        "title": "compress_pdf",
        "icon": "assets/toolsIcon/compressPDF.svg",
        "color": const Color.fromRGBO(231, 255, 245, 1),
      },
      {
        "title": "rotate_pdf",
        "icon": "assets/toolsIcon/rotatePDF.svg",
        "color": const Color.fromRGBO(255, 243, 224, 1),
      },
      {
        "title": "delete_pdf",
        "icon": "assets/toolsIcon/deletePDF.svg",
        "color": const Color.fromRGBO(209, 241, 255, 1),
      },
    ];
  }

  Future<void> openTool(Map<String, dynamic> tool) async {
    Widget screen;

    switch (tool["title"]) {
      case "merge_pdf":
        screen = MergedPDFFilesScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "split_pdf":
        screen = SplitPDFFilesScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "create_pdf":
        screen = CreatePdfFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "image_to_pdf":
        screen = ImageToPdfFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "qr_to_pdf":
        screen = PdfQrFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "watermark_pdf":
        screen = WatermarkPdfScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "page_number":
        screen = PageNumberFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "signature_pdf":
        screen = SignaturePdfFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "reverse_pages":
        screen = ReversePdfFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "browse_pdf":
        screen = BrowsePdfFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "compress_pdf":
        screen = CompressPdfFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "rotate_pdf":
        screen = RotatePdfFileScreen(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      case "delete_pdf":
        screen = DeletePdfHome(
          title: tool["title"],
          icon: tool["icon"],
          color: tool["color"],
        );
        break;

      default:
        return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (result == true) {
      setState(() => isLoading = true);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(title: "pdf_tools", showBackButton: false),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: TrText(
                  'pdf_tools',
                  style: TextStyle(
                    // color: titleColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: buildTools()),
        ],
      ),
    );
  }

  Widget buildTools() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        int remainingItems = tools.length % 2;
        bool isLastRow =
            index >= tools.length - (remainingItems == 0 ? 2 : remainingItems);
        return GestureDetector(
          onTap: () => openTool(tool),
          child: Container(
            margin: EdgeInsets.only(
              bottom: isLastRow ? 12 : 0, // 👈 apply margin
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color.fromARGB(255, 231, 231, 231),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tool["color"], // 🔥 dynamic bg color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SvgPicture.asset(tool["icon"], width: 26, height: 26),
                ),
                const SizedBox(height: 10),
                TrText(
                  tool["title"],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
