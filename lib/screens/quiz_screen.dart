import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_scanner/const/color.dart';
import 'package:smart_scanner/widgets/custom_appbar.dart';
import 'package:smart_scanner/widgets/custom_button.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/question_mdel.dart';
import '../providers/question_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Uint8List> buildQuizPdf({
    required List<QuestionModel> questions,
    required bool isAnswerSheet,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),

        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: List.generate(questions.length, (index) {
              final q = questions[index];

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),

                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    /// Question number
                    pw.Text(
                      "Question: ${index + 1}",
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 6),

                    /// Question text
                    pw.Text(
                      q.question,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    /// Options
                    ...List.generate(q.options.length, (optIndex) {
                      final option = q.options[optIndex];

                      final isCorrect = optIndex == q.correctIndex;
                      final isSelected = optIndex == q.selectedIndex;

                      PdfColor borderColor = PdfColors.grey300;
                      PdfColor bgColor = PdfColors.white;

                      // if (isAnswerSheet) {
                      //   if (isCorrect) {
                      //     borderColor = PdfColors.blue;
                      //     bgColor = PdfColors.blue100;
                      //   } else if (isSelected && !isCorrect) {
                      //     borderColor = PdfColors.red;
                      //     bgColor = PdfColors.red100;
                      //   }
                      // }
                      if (isAnswerSheet && isCorrect) {
                        borderColor = PdfColors.blue;
                        bgColor = PdfColors.blue100;
                      }

                      if (isAnswerSheet && isSelected && !isCorrect) {
                        borderColor = PdfColors.red;
                        bgColor = PdfColors.red100;
                      }
                      return pw.Container(
                        width: double.infinity,
                        margin: const pw.EdgeInsets.only(bottom: 6),

                        padding: const pw.EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),

                        decoration: pw.BoxDecoration(
                          color: bgColor,
                          border: pw.Border.all(color: borderColor, width: 1.2),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),

                        child: pw.Text(
                          option,
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: isCorrect
                                ? pw.FontWeight.bold
                                : pw.FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  Future<void> previewAndPrint({
    required BuildContext context,
    required List<QuestionModel> questions,
    required int currentTab,
  }) async {
    final isAnswerSheet = currentTab == 1;

    final pdfBytes = await buildQuizPdf(
      questions: questions,
      isAnswerSheet: isAnswerSheet,
    );

    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuizProvider>(context);
    // const optionLetters = ['A', 'B', 'C', 'D'];

    return Scaffold(
      appBar: CustomAppBar(
        title: "quiz",
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black54,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Question Sheet"),
                Tab(text: "Answer Sheet"),
              ],
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: TabBarView(
          controller: _tabController,
          children: [
            /// Question Sheet
            ListView.builder(
              itemCount: provider.quizQuestions.length,
              itemBuilder: (context, index) {
                final q = provider.quizQuestions[index];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Question: ${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,

                          color: Colors.black,
                        ),
                      ),
                    ),

                    Card(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                q.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),
                              ...List.generate(q.options.length, (optIndex) {
                                final isSelected = q.selectedIndex == optIndex;

                                return GestureDetector(
                                  // onTap: () {
                                  //   provider.selectAnswer(index, optIndex);
                                  // },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 60,
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          q.options[optIndex],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            // color: isSelected
                                            //     ? Colors.blue
                                            //     : Colors.black87,
                                            // fontWeight: isSelected
                                            //     ? FontWeight.w600
                                            //     : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            /// Answer Sheet
            ListView.builder(
              itemCount: provider.quizQuestions.length,
              itemBuilder: (context, index) {
                final q = provider.quizQuestions[index];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        "Question: ${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,

                          color: Colors.black,
                        ),
                      ),
                    ),
                    Card(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   "Topic: ${q.topic}",
                              //   style: const TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 14,
                              //     color: Colors.blueAccent,
                              //   ),
                              // ),
                              // Question
                              Text(
                                q.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Options
                              ...List.generate(q.options.length, (optIndex) {
                                final option = q.options[optIndex];
                                final isCorrect = optIndex == q.correctIndex;
                                final isSelected = optIndex == q.selectedIndex;
                                Color borderColor = Colors.grey.shade300;
                                Color bgColor = Colors.white;
                                Color textColor = Colors.black;

                                if (isCorrect) {
                                  borderColor = AppColors.primaryColor;
                                  bgColor = const Color.fromRGBO(
                                    205,
                                    226,
                                    246,
                                    1,
                                  );
                                  textColor = Colors.black;
                                }

                                if (isSelected && !isCorrect) {
                                  borderColor = Colors.red;
                                  bgColor = Colors.red.shade50;
                                  textColor = Colors.red;
                                }
                                // Color borderColor = Colors.grey.shade300;
                                // Color bgColor = Colors.white;
                                // Color textColor = Colors.grey;

                                // if (isCorrect) {
                                //   borderColor = AppColors.primaryColor;
                                //   // borderColor = Colors.green;
                                //   bgColor = Color.fromRGBO(205, 226, 246, 1);
                                //   // bgColor = Colors.green.shade50;
                                //   textColor = Color.fromRGBO(30, 30, 30, 1);
                                // } else if (isSelected && !isCorrect) {
                                //   borderColor = Colors.red;
                                //   bgColor = Colors.red.shade50;
                                //   textColor = Colors.red;
                                // }

                                return Container(
                                  alignment: Alignment.center,
                                  height: 60,
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        option,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 16,
                                          fontWeight: isCorrect
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: CustomButton(
          text: 'print',
          onPressed: () {
            previewAndPrint(
              context: context,
              questions: provider.quizQuestions,
              currentTab: _tabController.index,
            );
          },
        ),
      ),
    );
  }
}
