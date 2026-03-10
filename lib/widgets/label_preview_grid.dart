
import 'package:flutter/material.dart';

import '../models/labels_shape.dart';

class TemplatePreviewWidget extends StatelessWidget {
  final int rows;
  final int columns;
  final LabelShape shape;

  const TemplatePreviewWidget({
    super.key,
    required this.rows,
    required this.columns,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final total = rows * columns;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: total,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade200,
            borderRadius: _getShape(),
          ),
        );
      },
    );
  }

  BorderRadius _getShape() {
    switch (shape) {
      case LabelShape.round:
        return BorderRadius.circular(100);

      case LabelShape.oval:
        return BorderRadius.circular(40);

      case LabelShape.square:
        return BorderRadius.circular(4);

      case LabelShape.rectangle:
        return BorderRadius.circular(6);
    }
  }
}