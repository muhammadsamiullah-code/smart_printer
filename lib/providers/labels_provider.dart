import 'dart:io';
import 'package:flutter/material.dart';

import '../models/labels_shape.dart';
import '../models/labels_template.dart';

class LabelProvider extends ChangeNotifier {
  LabelShape? selectedShape;
  LabelTemplate? selectedTemplate;
  File? selectedImage;

  double pageMargin = 20; // customizable margin

  void setShape(LabelShape shape) {
    selectedShape = shape;
    selectedTemplate = null;

    notifyListeners();
  }

  void setTemplate(LabelTemplate template) {
    selectedTemplate = template;
    notifyListeners();
  }

  void setImage(File image) {
    selectedImage = image;
    notifyListeners();
  }

  void setMargin(double value) {
    pageMargin = value;
    notifyListeners();
  }

  void resetShape() {
  selectedShape = null;
  selectedTemplate = null;
  notifyListeners();
}
}
