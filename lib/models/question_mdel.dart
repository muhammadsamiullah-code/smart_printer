
class QuestionModel {
  final String topic;
  final String question;
  final List<String> options;
  final int correctIndex;

  int? selectedIndex;

  QuestionModel({
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.selectedIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      topic: json["topic"],
      question: json["question"],
      options: List<String>.from(json["options"]),
      correctIndex: json["correctIndex"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "topic": topic,
      "question": question,
      "options": options,
      "correctIndex": correctIndex,
    };
  }
}