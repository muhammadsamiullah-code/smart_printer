
import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _languageCode;

  LanguageProvider(this._languageCode);

  String get languageCode => _languageCode;

  void changeLanguage(String code) {
    _languageCode = code;
    notifyListeners();
  }
}