import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/screens/camera_preview_screen.dart';
import 'package:smart_scanner/screens/format_selection_screen.dart';
import 'package:smart_scanner/screens/frame_selection_screen.dart';
import 'package:smart_scanner/pdf_preview_screen.dart';
import 'package:smart_scanner/providers/bottom_nav_provider.dart';
import 'package:smart_scanner/screens/gmail_scanner_screen.dart';
import 'package:smart_scanner/screens/note_screen.dart';
import 'package:smart_scanner/screens/web_page_scanner_screen.dart';
import 'package:smart_scanner/widgets/tr_text.dart';
import '../models/menu_item_model.dart';
import 'dart:io';
import 'dart:async';
import 'package:multicast_dns/multicast_dns.dart';

import 'contacts_screen.dart';
import 'shape_selection_screen.dart';
import 'topic_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> printers = [];
  bool isScanning = false;
  Future<void> discoverPrinters() async {
    setState(() {
      isScanning = true;
      printers.clear();
    });

    final MDnsClient client = MDnsClient();
    await client.start();

    await for (PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(
      ResourceRecordQuery.serverPointer('_ipp._tcp.local'),
    )) {
      await for (SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName),
      )) {
        await for (IPAddressResourceRecord ip
            in client.lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(srv.target),
            )) {
          debugPrint(
            "Printer Found: ${ptr.domainName} - ${ip.address.address}",
          );

          setState(() {
            printers.add("${ptr.domainName} (${ip.address.address})");
          });
        }
      }
    }

    await Future.delayed(const Duration(seconds: 5));
    client.stop();

    setState(() {
      isScanning = false;
    });
  }

  Future<void> pickFile() async {
    final provider = context.read<BottomNavProvider>();
    provider.setLoading(true);

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
        'json',
      ],
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final extension = path.split('.').last.toLowerCase();

      if (extension == 'pdf') {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PdfPreviewScreen(path: path)),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const TrText("file_not_supported_title"),
            content: const TrText("file_not_supported_message"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const TrText("ok"),
              ),
            ],
          ),
        );
      }
    }

    provider.setLoading(false);
  }

  Future<void> pickGalleryImages() async {
    final provider = context.read<BottomNavProvider>();
    provider.setLoading(true);

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 90);

    if (pickedFiles.isNotEmpty) {
      final files = pickedFiles.map((e) => File(e.path)).toList();

      try {
        /// ✅ PDF generate simulation delay (replace with actual PDF generation)
        await Future.delayed(const Duration(milliseconds: 800));

        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/gallery_preview.pdf';

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfPreviewScreen(path: path, initialImages: files),
          ),
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    provider.setLoading(false);
  }

  Future<void> openCameraScan() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    final File file = File(image.path);

    /// Preview Screen
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraPreviewScreen(
          image: file,
          onKeep: (ctx) async {
            final dir = await getTemporaryDirectory();
            final path = '${dir.path}/scan_preview.pdf';

            Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (_) =>
                    PdfPreviewScreen(path: path, initialImages: [file]),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openWebScanner() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const WebPageScannerScreen()),
    );

    if (result != null) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/web_scan_preview.pdf';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(path: path, initialImages: [result]),
        ),
      );
    }
  }

  Future<void> _openGmailAndScan() async {
    final result = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const GmailScannerScreen()),
    );

    if (result != null) {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/gmail_scan_preview.pdf';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(path: path, initialImages: [result]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<MenuItemModel> menuItems = [
      MenuItemModel(
        svgPath: 'assets/homeIcons/photos.svg',
        title: "photos",
        color: const Color.fromRGBO(213, 234, 255, 1),
        onTap: pickGalleryImages,
      ),
      MenuItemModel(
        svgPath: 'assets/homeIcons/documents.svg',
        title: "documents",
        color: const Color.fromRGBO(255, 240, 248, 1),
        onTap: pickFile,
      ),
      MenuItemModel(
        svgPath: 'assets/homeIcons/webpage.svg',
        title: "webpage",
        color: const Color.fromRGBO(248, 232, 235, 1),
        onTap: _openWebScanner,
      ),
      MenuItemModel(
        svgPath: 'assets/homeIcons/email.svg',
        title: "email",
        color: const Color.fromRGBO(249, 227, 255, 1),
        onTap: () {
          _openGmailAndScan();
        },
      ),

      MenuItemModel(
        svgPath: 'assets/homeIcons/formats.svg',
        title: "formats",
        color: const Color.fromRGBO(222, 255, 241, 1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormatSelectionScreen()),
          );
          // _showFormatDialog(context);
        },
      ),
      MenuItemModel(
        svgPath: 'assets/homeIcons/labels.svg',
        title: "labels",
        color: const Color.fromRGBO(236, 235, 235, 1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShapeSelectionScreen()),
          );
        },
      ),

      MenuItemModel(
        svgPath: 'assets/homeIcons/frame.svg',
        title: "frames",
        color: const Color.fromRGBO(248, 232, 235, 1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FrameSelectionScreen()),
          );
        },
      ),
      MenuItemModel(
        svgPath: 'assets/homeIcons/camera.svg',
        title: "camera",
        color: const Color.fromRGBO(213, 234, 255, 1),
        onTap: openCameraScan,
      ),

      // MenuItemModel(
      //   svgPath: 'assets/homeIcons/printable.svg',
      //   title: "printable",
      //   color: const Color.fromRGBO(255, 246, 231, 1),
      //   onTap: () {},
      // ),
      // MenuItemModel(
      //   svgPath: 'assets/homeIcons/textOcr.svg',
      //   title: "text_ocr",
      //   color: const Color.fromRGBO(237, 241, 248, 1),
      //   onTap: () {},
      // ),
      MenuItemModel(
        svgPath: 'assets/homeIcons/notes.svg',
        title: "notes",
        color: const Color.fromRGBO(248, 232, 235, 1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotesScreen()),
          );
        },
      ),
      MenuItemModel(
        svgPath: 'assets/homeIcons/quizzes.svg',
        title: "quizzes",
        color: const Color.fromRGBO(224, 252, 247, 1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TopicSelectionScreen()),
          );
        },
      ),
      MenuItemModel(
        svgPath: 'assets/homeIcons/contacts.svg',
        title: "contact",
        color: const Color.fromRGBO(255, 240, 248, 1),
        onTap: () {
          Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactsScreen(),
      ),
    );
        },
      ),

      // MenuItemModel(
      //   svgPath: 'assets/homeIcons/calendar.svg',
      //   title: "calendar",
      //   color: const Color.fromRGBO(249, 227, 255, 1),
      //   onTap: () {},
      // ),

      // MenuItemModel(
      //   svgPath: 'assets/homeIcons/clipboard.svg',
      //   title: "clipboard",
      //   color: const Color.fromRGBO(223, 241, 251, 1),
      //   onTap: () {},
      // ),
      // MenuItemModel(
      //   svgPath: 'assets/homeIcons/oneDrive.svg',
      //   title: "one_drive",
      //   color: const Color.fromRGBO(223, 241, 251, 1),
      //   onTap: () {},
      // ),
      // MenuItemModel(
      //   svgPath: 'assets/homeIcons/googleDrive.svg',
      //   title: "google_drive",
      //   color: const Color.fromRGBO(222, 255, 241, 1),
      //   onTap: () {},
      // ),
      // MenuItemModel(
      //   svgPath: 'assets/homeIcons/dropBox.svg',
      //   title: "dropbox",
      //   color: const Color.fromRGBO(213, 234, 255, 1),
      //   onTap: () {},
      // ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======= HEADER =======
                  TrText(
                    "home_title",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color.fromRGBO(30, 30, 30, 1),
                    ),
                  ),
                  TrText(
                    "home_subtitle",
                    style: TextStyle(
                      color: Color.fromRGBO(146, 146, 146, 1),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  // ======= CONNECT CARD =======
                  GestureDetector(
                    onTap: () async {
                      // if (!isScanning) {
                      //   await discoverPrinters();
                      // }
                    },
                    child: Container(
                      // height: 200,
                      // width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(6, 61, 118, 1),
                            Color.fromRGBO(60, 106, 180, 1),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),

                      // 👇 MAIN CONDITION START
                      child: isScanning
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : printers.isEmpty
                          ? Row(
                              children: [
                                Expanded(
                                  child: const TrText(
                                    "wifi_instruction",
                                    style: TextStyle(
                                      color: Color.fromRGBO(245, 245, 245, 1),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Image.asset(
                                  'assets/images/printerImage.png',
                                  height: 100,
                                  width: 100,
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: printers
                                  .map(
                                    (printer) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.print),
                                          const SizedBox(width: 10),
                                          Expanded(child: Text(printer)),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ======= GRID MENU =======
                  Column(
                    children: List.generate((menuItems.length / 2).ceil(), (
                      index,
                    ) {
                      final firstIndex = index * 2;
                      final secondIndex = firstIndex + 1;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: buildMenuItem(
                                svgPath: menuItems[firstIndex].svgPath,
                                title: menuItems[firstIndex].title,
                                color: menuItems[firstIndex].color,
                                onTap: menuItems[firstIndex].onTap,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: secondIndex < menuItems.length
                                  ? buildMenuItem(
                                      svgPath: menuItems[secondIndex].svgPath,
                                      title: menuItems[secondIndex].title,
                                      color: menuItems[secondIndex].color,
                                      onTap: menuItems[secondIndex].onTap,
                                    )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem({
    required String svgPath,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shadowColor: Color.fromRGBO(94, 94, 94, 0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color,
                child: SvgPicture.asset(
                  svgPath,
                  height: 20,
                  width: 20,
                  // colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 12), // use width in Row (not height)
              Expanded(
                child: TrText(title, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
