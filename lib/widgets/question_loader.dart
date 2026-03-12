
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/question_mdel.dart';

class QuestionLoader {

  static Future<List<QuestionModel>> loadQuestions() async {

    final data = await rootBundle.loadString("lib/questions.json");

    final List jsonResult = json.decode(data);

    return jsonResult
        .map((e) => QuestionModel.fromJson(e))
        .toList();
  }
}