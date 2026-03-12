import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/custom_button.dart';

import '../providers/question_provider.dart';
import '../widgets/custom_appbar.dart';
import 'quiz_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  List<String> quizTopics = [
    "Sport",
    "Film",
    "Entertainment",
    "Arts",
    "Nature",
    "History",
    "Music",
    "General",
    "Leisure",
    "Television",
    "Geography",
    "Science",
    "Literature",
    "Food & Cooking",
    "Animals & Wildlife",
    "Human Body",
  ];
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuizProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Quizzes'),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Topics',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            SingleChildScrollView(
              child: Column(
                children: List.generate((quizTopics.length / 3).ceil(), (
                  rowIndex,
                ) {
                  return Row(
                    children: List.generate(3, (colIndex) {
                      int index = rowIndex * 3 + colIndex;

                      if (index >= quizTopics.length) {
                        return const Expanded(child: SizedBox());
                      }

                      final topic = quizTopics[index];
                      final selected = provider.selectedTopics.contains(topic);

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: GestureDetector(
                            onTap: () {
                              provider.toggleTopic(topic);
                            },
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primaryColor
                                    : const Color.fromRGBO(235, 235, 235, 1),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: Center(
                                child: Text(
                                  topic,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Total Questions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Container(
              height: 55,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 1),
                // color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  /// Minus Button
                  Container(
                    width: 90,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(235, 235, 235, 1),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(30),
                        left: Radius.circular(12),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: provider.decreaseQuestions,
                    ),
                  ),

                  /// Center Number
                  Expanded(
                    child: Center(
                      child: Text(
                        "${provider.totalQuestions}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  /// Plus Button
                  Container(
                    width: 90,
                    height: 55,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(12),
                        left: Radius.circular(30),
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: provider.increaseQuestions,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            CustomButton(
              text: 'Create Quiz',
              onPressed: () {
                if (provider.selectedTopics.isEmpty) {
                  // No topic selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a topic")),
                  );
                  return;
                }

                if (provider.totalQuestions <= 0) {
                  // No questions added
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please add question numbers"),
                    ),
                  );
                  return;
                }

                // Everything is okay, generate quiz
                provider.generateQuiz();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
