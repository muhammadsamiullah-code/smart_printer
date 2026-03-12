
import 'package:flutter/material.dart';

import '../models/question_mdel.dart';
import '../widgets/question_loader.dart';

class QuizProvider extends ChangeNotifier {
  List<QuestionModel> allQuestions = [];
  List<String> selectedTopics = [];
  int totalQuestions = 0;
  List<QuestionModel> quizQuestions = [];

  static const int questionsPerTopic = 20;
  static const int maxTopics = 16;

  Future<void> loadQuestions() async {
    allQuestions = await QuestionLoader.loadQuestions();
    notifyListeners();
  }

  void toggleTopic(String topic) {
    if (selectedTopics.contains(topic)) {
      selectedTopics.remove(topic);
    } else {
      selectedTopics.add(topic);
    }

    // Reset totalQuestions if it exceeds max allowed for selected topics
    int maxAllowed = selectedTopics.length * questionsPerTopic;
    if (totalQuestions > maxAllowed) {
      totalQuestions = maxAllowed;
    }

    notifyListeners();
  }

  void increaseQuestions() {
    int maxAllowed = selectedTopics.isEmpty
        ? questionsPerTopic // if no topic selected, allow at least 20
        : selectedTopics.length * questionsPerTopic;

    if (totalQuestions < maxAllowed) {
      totalQuestions++;
      notifyListeners();
    }
  }

  void decreaseQuestions() {
    if (totalQuestions > 0) {
      totalQuestions--;
      notifyListeners();
    }
  }

  void generateQuiz() {
    // Filter questions by selected topics
    List<QuestionModel> filtered = allQuestions
        .where((q) => selectedTopics.contains(q.topic))
        .toList();

    filtered.shuffle();

    quizQuestions = filtered.take(totalQuestions).toList();

    notifyListeners();
  }

  void selectAnswer(int qIndex, int optionIndex) {
    quizQuestions[qIndex].selectedIndex = optionIndex;
    notifyListeners();
  }
}
// class QuizProvider extends ChangeNotifier {

//   List<QuestionModel> allQuestions = [];

//   List<String> selectedTopics = [];

//   int totalQuestions = 0;

//   List<QuestionModel> quizQuestions = [];

//   Future<void> loadQuestions() async {
//     allQuestions = await QuestionLoader.loadQuestions();
//     notifyListeners();
//   }

//   void toggleTopic(String topic) {

//     if (selectedTopics.contains(topic)) {
//       selectedTopics.remove(topic);
//     } else {
//       selectedTopics.add(topic);
//     }

//     notifyListeners();
//   }

//   void increaseQuestions() {
//     totalQuestions++;
//     notifyListeners();
//   }

//   void decreaseQuestions() {

//     if (totalQuestions > 0) {
//       totalQuestions--;
//     }

//     notifyListeners();
//   }

//   void generateQuiz() {

//     List<QuestionModel> filtered = allQuestions
//         .where((q) => selectedTopics.contains(q.topic))
//         .toList();

//     filtered.shuffle();

//     quizQuestions = filtered.take(totalQuestions).toList();

//     notifyListeners();
//   }

//   void selectAnswer(int qIndex, int optionIndex) {

//     quizQuestions[qIndex].selectedIndex = optionIndex;

//     notifyListeners();
//   }
// }