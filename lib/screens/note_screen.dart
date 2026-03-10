import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:smart_scanner/format_selection_screen.dart';
import 'package:smart_scanner/widgets/tr_text.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController titleController = TextEditingController();
  final GlobalKey editorKey = GlobalKey();
  final quill.QuillController _controller = quill.QuillController.basic();

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  /// COPY
  void copyText() {
    final selection = _controller.selection;

    if (!selection.isCollapsed) {
      final text = _controller.document.getPlainText(
        selection.start,
        selection.end - selection.start,
      );

      Clipboard.setData(ClipboardData(text: text));
    }
  }

  Future<Uint8List> captureEditor() async {
    /// hide cursor
    FocusScope.of(context).unfocus();

    /// wait for UI update
    await Future.delayed(const Duration(milliseconds: 100));

    RenderRepaintBoundary boundary =
        editorKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);

    final byteData = await image.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// PASTE
  Future<void> pasteText() async {
    final data = await Clipboard.getData('text/plain');

    if (data != null) {
      final text = data.text ?? "";

      final selection = _controller.selection;

      _controller.document.insert(selection.baseOffset, text);

      _controller.updateSelection(
        TextSelection.collapsed(offset: selection.baseOffset + text.length),
        quill.ChangeSource.local,
      );
    }
  }

  Future<Uint8List> buildPdfFromImage() async {
    final imageBytes = await captureEditor();

    final pdf = pw.Document();

    final image = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(child: pw.Image(image));
        },
      ),
    );

    return pdf.save();
  }

  Future<void> printNote() async {
    final wifiOn = await isWifiReallyOn();

    if (!wifiOn) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText('wifi_location_required')));
      return;
    }

    final sameWifi = await isSameWifi();
    if (!sameWifi) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText('same_wifi_required')));
      return;
    }

    try {
      final pdfBytes = await buildPdfFromImage();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
      // final pdfBytes = await buildPrintablePdfUltimate();
      // await Printing.layoutPdf(
      //   onLayout: (PdfPageFormat format) async => pdfBytes,
      // );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: TrText('printer_not_available')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
        ),
        title: const TrText(
          'note',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print, size: 28, color: Colors.black),
            onPressed: printNote,
          ),
        ],
      ),

      // backgroundColor: const Color(0xffF5F6FA),
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   centerTitle: true,
      //   title: const Text("Notes", style: TextStyle(color: Colors.black)),
      //   actions: [
      // IconButton(
      //   icon: const Icon(Icons.print, color: Colors.black),
      //   onPressed: printNote,
      // ),
      //   ],
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// TOOLBAR
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: quill.QuillSimpleToolbar(controller: _controller),
              // ),

              /// EDITOR
              Expanded(
                child: RepaintBoundary(
                  key: editorKey,
                  child: quill.QuillEditor(
                    controller: _controller,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    config: const quill.QuillEditorConfig(
                      placeholder: "Write your notes...",
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   child: quill.QuillEditor(
              //     controller: _controller,
              //     focusNode: _focusNode,
              //     scrollController: _scrollController,
              //     config: const quill.QuillEditorConfig(
              //       placeholder: "Write your notes...",
              //     ),
              //   ),
              // ),

              /// COPY PASTE
              Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: copyText,
                      ),

                      IconButton(
                        icon: const Icon(Icons.paste),
                        onPressed: pasteText,
                      ),
                      quill.QuillSimpleToolbar(controller: _controller),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
