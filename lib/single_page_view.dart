import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:smart_scanner/const/color.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:smart_scanner/text_model.dart';

enum ViewerType { pdf, image }

class SinglePageViewerScreen extends StatefulWidget {
  final ViewerType type;

  // PDF params
  final String? pdfPath;
  final int? pdfPageNumber;

  // Image param
  final File? image;

  const SinglePageViewerScreen.pdf({
    super.key,
    required this.pdfPath,
    required this.pdfPageNumber,
  }) : type = ViewerType.pdf,
       image = null;

  const SinglePageViewerScreen.image({super.key, required this.image})
    : type = ViewerType.image,
      pdfPath = null,
      pdfPageNumber = null;

  @override
  State<SinglePageViewerScreen> createState() => _SinglePageViewerScreenState();
}

class _SinglePageViewerScreenState extends State<SinglePageViewerScreen> {
  final List<String> fontFamilies = [
    'Roboto',
    'Poppins',
    'Montserrat',
    'Lobster',
    'Open Sans',
    'Oswald',
    'Raleway',
    'Merriweather',
    'Playfair Display',
    'Nunito',
    'Ubuntu',
    'Lato',
    'PT Sans',
    'Rubik',
    'Bebas Neue',
    'Pacifico',
    'Dancing Script',
    'Cinzel',
    'Josefin Sans',
    'Titillium Web',
  ];

  final List<Color> textColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  final double pageHeight = 500;
  Uint8List? pageBytes;
  final List<PageText> texts = [];
  PageText? selectedText;
  bool editingText = false;

  final GlobalKey repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.type == ViewerType.pdf) {
      _renderPdfPage();
    } else {
      pageBytes = widget.image!.readAsBytesSync();
    }
  }

  Future<void> _renderPdfPage() async {
    final doc = await PdfDocument.openFile(widget.pdfPath!);
    final page = await doc.getPage(widget.pdfPageNumber!);

    final img = await page.render(
      width: page.width * 2,
      height: page.height * 2,
      format: PdfPageImageFormat.png,
    );

    setState(() => pageBytes = img!.bytes);

    await page.close();
    await doc.close();
  }

  /// ➕ Add text dialog
  Future<void> addText() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Text', style: TextStyle(color: Colors.black)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter text'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        texts.add(PageText(text: result, position: const Offset(100, 100)));
      });
    }
  }

  /// 💾 Save edited image
  Future<void> savePage() async {
    final boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    final file = File(
      '${(await getTemporaryDirectory()).path}/edited_${DateTime.now().millisecondsSinceEpoch}.png',
    );

    await file.writeAsBytes(byteData!.buffer.asUint8List());

    Navigator.pop(context, file);
  }

  Future<File> _bytesToTempFile(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/page_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> cropPage() async {
    if (pageBytes == null) return;

    final inputFile = await _bytesToTempFile(pageBytes!);

    final cropped = await ImageCropper().cropImage(
      sourcePath: inputFile.path,

      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: false,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),

        IOSUiSettings(title: 'Crop', aspectRatioLockEnabled: false),
      ],
    );

    if (cropped != null) {
      final bytes = await cropped.readAsBytes();

      setState(() {
        pageBytes = bytes; // 👈 updated cropped page
      });
    }
  }

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
        title: const Text(
          'Edit',
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
      ),

      body: pageBytes == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : Center(
              child: Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(8),
                height: pageHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),

                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: InteractiveViewer(
                    maxScale: 6,
                    child: RepaintBoundary(
                      key: repaintKey,
                      child: Stack(
                        children: [
                          Image.memory(pageBytes!),

                          /// 🔤 Text overlays
                          ...texts.map(
                            (t) => Positioned(
                              left: t.position.dx,
                              top: t.position.dy,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedText = t;
                                    editingText = true;
                                  });
                                },
                                onPanUpdate: (d) {
                                  setState(() => t.position += d.delta);
                                },
                                child: Text(
                                  t.text,
                                  style: GoogleFonts.getFont(
                                    t.fontFamily,
                                    fontSize: t.fontSize,
                                    fontWeight: t.bold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontStyle: t.italic
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    decoration: t.underline
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    color: t.color,
                                    backgroundColor: selectedText == t
                                        ? Colors.black12
                                        : Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        height: 100,
        child: editingText && selectedText != null
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    /// Font family
                    DropdownButton<String>(
                      value: selectedText!.fontFamily,
                      items: fontFamilies
                          .map(
                            (f) => DropdownMenuItem(
                              value: f,
                              child: Text(f, style: GoogleFonts.getFont(f)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setState(() => selectedText!.fontFamily = v!);
                      },
                    ),

                                       IconButton(
                      icon: const Icon(Icons.format_bold),
                      onPressed: () {
                        setState(
                          () => selectedText!.bold = !selectedText!.bold,
                        );
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.format_italic),
                      onPressed: () {
                        setState(
                          () => selectedText!.italic = !selectedText!.italic,
                        );
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.format_underline),
                      onPressed: () {
                        setState(
                          () => selectedText!.underline =
                              !selectedText!.underline,
                        );
                      },
                    ),

                    /// Font size
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          selectedText!.fontSize = (selectedText!.fontSize - 2)
                              .clamp(8, 100);
                        });
                      },
                    ),

                    Text('${selectedText!.fontSize.toInt()}'),

                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          selectedText!.fontSize = (selectedText!.fontSize + 2)
                              .clamp(8, 100);
                        });
                      },
                    ),

                    /// Colors
                    IconButton(
                      icon: const Icon(Icons.color_lens),
                      onPressed: () async {
                        final color = await showDialog<Color>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Pick Text Color'),
                            content: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: textColors
                                  .map(
                                    (c) => GestureDetector(
                                      onTap: () => Navigator.pop(context, c),
                                      child: CircleAvatar(
                                        backgroundColor: c,
                                        radius: 16,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        );

                        if (color != null) {
                          setState(() => selectedText!.color = color);
                        }
                      },
                    ),
                    

                    /// OK
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        setState(() {
                          editingText = false;
                          selectedText = null;
                        });
                      },
                    ),
                  ],
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  iconTextButton(
                    icon: Icons.text_fields,
                    label: "Add Text",
                    onPressed: addText,
                  ),
                  iconTextButton(
                    icon: Icons.save,
                    label: "Save",
                    onPressed: savePage,
                  ),
                  iconTextButton(
                    icon: Icons.crop,
                    label: "Crop",
                    onPressed: cropPage,
                  ),
                ],
              ),
      ),
    );
  }

  Widget iconTextButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 24, color: AppColors.primaryColor),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
