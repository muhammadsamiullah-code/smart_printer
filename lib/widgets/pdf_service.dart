import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:smart_scanner/models/labels_shape.dart';
import 'package:smart_scanner/models/labels_template.dart';

class PdfService {
  static const double inchToPoint = 72;

  static Future<Uint8List> generatePdf({
    required LabelTemplate template,
    required File imageFile,
  }) async {
    final pdf = pw.Document();

    final imageBytes = await imageFile.readAsBytes();
    final image = pw.MemoryImage(imageBytes);

    final pageWidth = PdfPageFormat.a4.width;
    final pageHeight = PdfPageFormat.a4.height;

    const spacing = 6.0;

    /// Template size in points
    final labelWidth = template.widthInch! * inchToPoint;
    final labelHeight = template.heightInch! * inchToPoint;

    /// Total grid size before scaling
    final gridWidth =
        (template.columns * labelWidth) + ((template.columns - 1) * spacing);

    final gridHeight =
        (template.rows * labelHeight) + ((template.rows - 1) * spacing);

    /// Calculate scale to fit inside A4
    final scaleX = pageWidth / gridWidth;
    final scaleY = pageHeight / gridHeight;

    final scale = scaleX < scaleY ? scaleX : scaleY;

    /// Apply scale
    final finalWidth = labelWidth * scale;
    final finalHeight = labelHeight * scale;
    final scaledSpacing = spacing * scale;
    final totalWidth =
        (template.columns * finalWidth) + ((template.columns - 1) * spacing);

    final totalHeight =
        (template.rows * finalHeight) + ((template.rows - 1) * spacing);

    /// Center grid
    final startX = (pageWidth - totalWidth) / 2;
    final startY = (pageHeight - totalHeight) / 2;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Stack(
            children: [
              for (int row = 0; row < template.rows; row++)
                for (int col = 0; col < template.columns; col++)
                  pw.Positioned(
                    left: startX + col * (finalWidth + scaledSpacing),
                    top: startY + row * (finalHeight + scaledSpacing),
                    child: _buildLabel(
                      template.shape,
                      finalWidth,
                      finalHeight,
                      image,
                    ),
                  ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildLabel(
    LabelShape shape,
    double width,
    double height,
    pw.ImageProvider image,
  ) {
    pw.Widget imageWidget = pw.Container(
      width: width,
      height: height,
      decoration: pw.BoxDecoration(
        image: pw.DecorationImage(
          image: image,
          fit: pw.BoxFit.cover,
          alignment: pw.Alignment.center,
        ),
      ),
    );

    switch (shape) {
      case LabelShape.round:
        return pw.ClipOval(child: imageWidget);

      case LabelShape.oval:
        return pw.ClipRRect(
          horizontalRadius: height / 2,
          verticalRadius: height / 2,
          child: imageWidget,
        );

      case LabelShape.square:
        return pw.Container(width: width, height: width, child: imageWidget);

      case LabelShape.rectangle:
        return imageWidget;
    }
  }
}

// class PdfService {
//   static const double inchToPoint = 72.0;

//  static Future<Uint8List> generatePdf({
//   required LabelTemplate template,
//   required File imageFile,
//   required double margin,
// }) async {
//   final pdf = pw.Document();

//   final imageBytes = await imageFile.readAsBytes();
//   final image = pw.MemoryImage(imageBytes);

//   const double inchToPoint = 72;

//   final labelWidth = template.widthInch * inchToPoint;
//   final labelHeight = template.heightInch * inchToPoint;

//   final pageWidth = PdfPageFormat.a4.width;
//   final pageHeight = PdfPageFormat.a4.height;

//   // Small fixed spacing (compact layout)
//   const double spacing = 2;

//   final totalWidth =
//       (template.columns * labelWidth) +
//           ((template.columns - 1) * spacing);

//   final totalHeight =
//       (template.rows * labelHeight) +
//           ((template.rows - 1) * spacing);

//   // Center grid inside margins
//   final startX = (pageWidth - totalWidth) / 2;
//   final startY = (pageHeight - totalHeight) / 2;

//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a4,
//       build: (context) {
//         return pw.Stack(
//           children: [
//             for (int row = 0; row < template.rows; row++)
//               for (int col = 0; col < template.columns; col++)
//                 pw.Positioned(
//                   left: startX + col * (labelWidth + spacing),
//                   top: startY + row * (labelHeight + spacing),
//                   child: _buildLabel(
//                     template.shape,
//                     labelWidth,
//                     labelHeight,
//                     image,
//                   ),
//                 ),
//           ],
//         );
//       },
//     ),
//   );

//   return pdf.save();
// }

//   static pw.Widget _buildLabel(
//     LabelShape shape,
//     double width,
//     double height,
//     pw.ImageProvider image,
//   ) {
//     switch (shape) {
//       case LabelShape.round:
//         return pw.Container(
//           width: width,
//           height: width,
//           decoration: pw.BoxDecoration(
//             shape: pw.BoxShape.circle,
//             image: pw.DecorationImage(
//               image: image,
//               fit: pw.BoxFit.cover,
//             ),
//           ),
//         );

//       case LabelShape.oval:
//         return pw.Container(
//           width: width,
//           height: height,
//           decoration: pw.BoxDecoration(
//             borderRadius: pw.BorderRadius.circular(height / 2),
//             image: pw.DecorationImage(
//               image: image,
//               fit: pw.BoxFit.cover,
//             ),
//           ),
//         );

//       case LabelShape.square:
//         return pw.Container(
//           width: width,
//           height: width,
//           decoration: pw.BoxDecoration(
//             image: pw.DecorationImage(
//               image: image,
//               fit: pw.BoxFit.cover,
//             ),
//           ),
//         );

//       case LabelShape.rectangle:
//       return pw.Container(
//           width: width,
//           height: height,
//           decoration: pw.BoxDecoration(
//             image: pw.DecorationImage(
//               image: image,
//               fit: pw.BoxFit.cover,
//             ),
//           ),
//         );
//     }
//   }
// }
