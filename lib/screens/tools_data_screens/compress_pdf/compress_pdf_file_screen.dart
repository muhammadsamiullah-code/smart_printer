import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/ads/ads_provider.dart';

import '../../../ads/native_ads_widget.dart';
import '../../../const/color.dart';
import '../../../const/enum.dart';
import '../../../widgets/build_commeon_fab.dart';
import '../../../widgets/center_widget_for_pdf.dart';
import '../../../widgets/common_delete_dialoge.dart';
import '../../../widgets/common_input_dialoge.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/file_option_menu.dart';
import '../../../widgets/pdf_list_card.dart';
import '../../../widgets/tr_text.dart';
import '../merge_pdf/pdf_preview_screen.dart';
import 'compress_pdf_screen.dart';

class CompressPdfFileScreen extends StatefulWidget {
  final String title;
  final String icon;
  final Color color;
  const CompressPdfFileScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  State<CompressPdfFileScreen> createState() => _CompressPdfFileScreenState();
}

class _CompressPdfFileScreenState extends State<CompressPdfFileScreen> {
  List<File> pdfFiles = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  /// LOAD SAVED FILES
  Future<void> loadFiles() async {
    final dir = await getApplicationDocumentsDirectory();

    final files = dir.listSync().where((file) {
      return file.path.contains("compressed_") && file.path.endsWith(".pdf");
    }).toList();

    setState(() {
      pdfFiles = files.map((e) => File(e.path)).toList();
    });
  }

  /// PICK FILES + NAVIGATE
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result != null) {
      final files = result.paths.map((e) => File(e!)).toList();

      final updated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CompressPdfScreen(selectedFiles: files, title: widget.title),
        ),
      );

      if (updated == true) loadFiles();
    }
  }

  void deleteFile(File file) async {
    showDialog(
      context: context,
      builder: (context) {
        return CommonDeleteDialog(
          title: "delete_file",
          message: "delete_file_confirmation",
          onConfirm: () async {
            await file.delete();

            if (mounted) {
              Navigator.pop(context);

              loadFiles();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: TrText("file_deleted_successfully")),
              );
            }
          },
        );
      },
    );
  }

  void renameFile(File file) {
    final controller = TextEditingController(
      text: file.path.split('/').last.replaceAll(".pdf", ""),
    );
    showCommonInputDialog(
      context: context,
      titleKey: "rename_file",
      buttonKey: "rename",
      controller: controller,
      onPressed: () async {
        final dir = file.parent.path;
        final newName = controller.text;
        final newFile = File("$dir/compressed_$newName.pdf");
        await file.rename(newFile.path);
        Navigator.pop(context);
        loadFiles();
      },
    );
  }

  String formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else if (bytes >= 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else {
      return "$bytes B";
    }
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat("dd MMM yyyy 'at' hh:mm a").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final reversedList = pdfFiles.reversed.toList();
    return Scaffold(
      appBar: CustomAppBar(title: widget.title),

      body: pdfFiles.isEmpty
          ? CenterWidgetForPDF(
              borderColor: Color.fromRGBO(19, 180, 113, 1),
              title: widget.title,
              icon: widget.icon,
              color: widget.color,
            )
          : SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, ),
                    child: RectangleNativeAdWidget(),
                  ),
                ListView.builder(
                   shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    itemCount: reversedList.length,
                    itemBuilder: (_, index) {
                      final file = reversedList[index];
                      final fileSize = formatFileSize(file.lengthSync());
                      final fileName = file.path.split('/').last;
                      final lastModified = file.lastModifiedSync();
                      final formattedDate = formatDateTime(lastModified);
                      return PdfListCard(
                        title: fileName,
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fileSize, style: TextStyle(fontSize: 12)),
                            Text(formattedDate, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        trailing: FileOptionsMenu(
                          onRename: () => renameFile(file),
                          onDelete: () => deleteFile(file),
                        ),
                        onTap: () async {
                          await context.read<AdsProvider>().showAdInterstitial(
                            type: InterstitialType.pdfList,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfPreviewPrintScreen(file: file),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),

      /// FAB WITH LOADER
      floatingActionButton: buildCommonFAB(
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
          if (mounted) Navigator.pop(context);

          final adsProvider = context.read<AdsProvider>();

          /// 🔥 Step 3: Show Ad
          await adsProvider.showAdInterstitial();

          await pickFiles();

          // if (mounted) Navigator.pop(context);
        },
        label: 'select_file',
      ),
    );
  }
}
