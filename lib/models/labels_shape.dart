enum LabelShape {
  rectangle,
  round,
  oval,
  square,
}

extension LabelShapeExtension on LabelShape {
  String get imagePath {
    switch (this) {
      case LabelShape.rectangle:
        return "assets/templates/rectangle/4.svg";
      case LabelShape.round:
        return "assets/templates/round/4.svg";
      case LabelShape.oval:
        return "assets/templates/oval/4.svg";
      case LabelShape.square:
        return "assets/templates/square/4.svg";
    }
  }

  String get displayName => name.toLowerCase();
}