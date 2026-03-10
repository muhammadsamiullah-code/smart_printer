import 'labels_shape.dart';

class LabelTemplate {
  final int perSheet;
  final String displaySize;
  final double? widthInch;
  final double? heightInch;
  final int columns;
  final int rows;
  final LabelShape shape;
  final String svgPath;

  LabelTemplate({
    required this.perSheet,
    required this.displaySize,
    this.widthInch,
    this.heightInch,
    required this.columns,
    required this.rows,
    required this.shape,
    required this.svgPath,
  });
  
  @override
  bool operator ==(Object other) {
    return other is LabelTemplate &&
        other.perSheet == perSheet &&
        other.widthInch == widthInch &&
        other.heightInch == heightInch &&
        other.columns == columns &&
        other.rows == rows &&
        other.shape == shape;
  }

  @override
  int get hashCode =>
      perSheet.hashCode ^
      widthInch.hashCode ^
      heightInch.hashCode ^
      columns.hashCode ^
      rows.hashCode ^
      shape.hashCode;
}


// class LabelTemplate {
//   final int perSheet;
//   final double widthInch;
//   final double heightInch;
//   final int columns;
//   final int rows;
//   final LabelShape shape;

//   LabelTemplate({
//     required this.perSheet,
//     required this.widthInch,
//     required this.heightInch,
//     required this.columns,
//     required this.rows,
//     required this.shape,
//   });

//   String get displayText =>
//       "$perSheet per sheet (${widthInch.toStringAsFixed(2)}\" x ${heightInch.toStringAsFixed(2)}\")";
// }