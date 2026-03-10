

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslatorProvider extends ChangeNotifier {
  String _languageCode;
  Map<String, dynamic> _localizedStrings = {};

  String get languageCode => _languageCode;

  TranslatorProvider(this._languageCode) {
    loadLanguage(_languageCode);
  }

  Future<void> loadLanguage(String code) async {
    _languageCode = code;

    String jsonString =
        await rootBundle.loadString('lib/language/$code.json');

    _localizedStrings = json.decode(jsonString);

    notifyListeners();
  }

  String tr(String key) {
    return _localizedStrings[key] ?? key;
  }
}