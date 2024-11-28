import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionPage extends StatefulWidget {
  final List<String> lessonId;

  QuestionPage({required this.lessonId});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  bool isSubmitted = false;
  int correctAnswers = 0;

  void calculateScore(List<Map<String, dynamic>> questions) {
    correctAnswers = 0;
    for (var question in questions) {
      if (question['selectedAnswer'] == question['correctAnswer']) {
        correctAnswers++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise'),
        backgroundColor: Colors.blue[800],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('questions')
            .where(FieldPath.documentId, whereIn: widget.lessonId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}', // Display detailed error message
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Check if there is no data or the questions list is empty
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No questions available for this lesson',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          // Get the list of questions
          List<Map<String, dynamic>> questions = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;

            // Check and create `selectedAnswer` if it doesn't exist
            if (!data.containsKey('selectedAnswer')) {
              FirebaseFirestore.instance
                  .collection('questions')
                  .doc(doc.id)
                  .update({'selectedAnswer': -1});
              data['selectedAnswer'] = -1;
            }

            return data;
          }).toList();

          return Column(
            children: [
              if (isSubmitted)
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Text(
                    'Result: $correctAnswers/${questions.length} correct answers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    var question = questions[index];
                    var answers = List<String>.from(question['answers']);
                    var selectedAnswer = question['selectedAnswer'];
                    var correctAnswer = question['correctAnswer'];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSubmitted
                              ? (selectedAnswer == correctAnswer
                                  ? Colors.green
                                  : Colors.red)
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${index + 1}: ${question['question']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            SizedBox(height: 8),
                            ...List.generate(answers.length, (answerIndex) {
                              return InkWell(
                                onTap: isSubmitted
                                    ? null
                                    : () {
                                        setState(() {
                                          question['selectedAnswer'] =
                                              answerIndex;
                                        });

                                        // Save `selectedAnswer` to Firestore
                                        FirebaseFirestore.instance
                                            .collection('questions')
                                            .doc(question['id'])
                                            .update({
                                          'selectedAnswer': answerIndex,
                                        });
                                      },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: selectedAnswer == answerIndex
                                        ? (isSubmitted
                                            ? (selectedAnswer == correctAnswer
                                                ? Colors.green[100]
                                                : Colors.red[100])
                                            : Colors.blue[100])
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selectedAnswer == answerIndex
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    answers[answerIndex],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: selectedAnswer == answerIndex
                                          ? Colors.blue[900]
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: isSubmitted
                      ? null
                      : () {
                          setState(() {
                            isSubmitted = true;
                            calculateScore(questions);
                          });
                        },
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
