// quiz_page.dart
import 'package:flutter/material.dart';

class QuizPage extends StatefulWidget {
  final String lessonId;

  QuizPage({required this.lessonId});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  bool isSubmitted = false;
  int correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    print("Received lessonId: ${widget.lessonId}");
  }

  void loadQuestions() {
    if (widget.lessonId == '1') {
      questions = [
        {
          'question': 'Phân thức đại số là gì?',
          'answers': [
            'Tỉ số của hai đa thức',
            'Tổng của hai đa thức',
            'Hiệu của hai đa thức',
            'Tích của hai đa thức'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
        {
          'question': 'Điều kiện để một phân thức đại số xác định là gì?',
          'answers': [
            'Mẫu số phải khác 0',
            'Tử số phải khác 0',
            'Tử số và mẫu số phải bằng nhau',
            'Tử số phải lớn hơn mẫu số'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
        {
          'question': 'Khi rút gọn phân thức đại số, ta thực hiện:',
          'answers': [
            'Phân tích tử và mẫu thành nhân tử và tìm ước chung',
            'Cộng tử số với mẫu số',
            'Nhân tử số với mẫu số',
            'Chia tử số cho mẫu số'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
        {
          'question': 'Để quy đồng mẫu số các phân thức, ta cần:',
          'answers': [
            'Tìm bội chung nhỏ nhất của các mẫu số',
            'Tìm ước chung lớn nhất của các mẫu số',
            'Cộng các mẫu số lại với nhau',
            'Nhân các mẫu số với nhau'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
        {
          'question':
              'Khi cộng (hoặc trừ) các phân thức đại số có cùng mẫu số, ta:',
          'answers': [
            'Giữ nguyên mẫu và cộng (hoặc trừ) các tử số',
            'Cộng (hoặc trừ) cả tử và mẫu',
            'Nhân các tử số với nhau',
            'Chia các tử số cho nhau'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
      ];
    } else if (widget.lessonId == '2') {
      questions = [
        {
          'question': 'Khi nhân hai phân thức đại số, ta thực hiện:',
          'answers': [
            'Nhân tử với tử, mẫu với mẫu',
            'Nhân tử với mẫu chéo nhau',
            'Cộng tử với tử, mẫu với mẫu',
            'Trừ tử với tử, mẫu với mẫu'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
        {
          'question': 'Khi chia hai phân thức đại số, ta:',
          'answers': [
            'Nhân phân thức thứ nhất với phân thức nghịch đảo của phân thức thứ hai',
            'Chia trực tiếp tử cho tử, mẫu cho mẫu',
            'Cộng các phân thức lại với nhau',
            'Trừ các phân thức với nhau'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
        {
          'question': 'Nghịch đảo của một phân thức là:',
          'answers': [
            'Phân thức mới có tử số là mẫu số cũ và mẫu số là tử số cũ',
            'Phân thức mới có cùng tử và mẫu',
            'Tổng của tử và mẫu cũ',
            'Hiệu của tử và mẫu cũ'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
        {
          'question': 'Để tính giá trị của một phân thức đại số, ta cần:',
          'answers': [
            'Thế giá trị của biến vào và tính toán theo quy tắc số học',
            'Chỉ thế giá trị vào tử số',
            'Chỉ thế giá trị vào mẫu số',
            'Cộng tử số với mẫu số'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
        {
          'question': 'Phân thức bằng 0 khi nào?',
          'answers': [
            'Khi tử số bằng 0 và mẫu số khác 0',
            'Khi mẫu số bằng 0',
            'Khi tử số bằng mẫu số',
            'Khi tử số lớn hơn mẫu số'
          ],
          'correctAnswer': 0,
          'selectedAnswer': -1,
        },
      ];
    }
  }

  void calculateScore() {
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
        title: Text('Bài tập'),
        backgroundColor: Colors.blue[800],
      ),
      body: Column(
        children: [
          if (isSubmitted)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kết quả: $correctAnswers/${questions.length} câu đúng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final isAnswered = question['selectedAnswer'] != -1;
                final isCorrect = isSubmitted &&
                    question['selectedAnswer'] == question['correctAnswer'];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSubmitted
                          ? (isCorrect ? Colors.green : Colors.red)
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
                          'Câu ${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          question['question'],
                          style: TextStyle(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: question['answers'].length,
                            itemBuilder: (context, answerIndex) {
                              final isSelected =
                                  question['selectedAnswer'] == answerIndex;
                              final isCorrectAnswer =
                                  question['correctAnswer'] == answerIndex;

                              Color? backgroundColor;
                              if (isSubmitted) {
                                if (isCorrectAnswer) {
                                  backgroundColor = Colors.green[100];
                                } else if (isSelected && !isCorrectAnswer) {
                                  backgroundColor = Colors.red[100];
                                }
                              } else if (isSelected) {
                                backgroundColor = Colors.blue[100];
                              }

                              return InkWell(
                                onTap: isSubmitted
                                    ? null
                                    : () {
                                        setState(() {
                                          question['selectedAnswer'] =
                                              answerIndex;
                                        });
                                      },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    question['answers'][answerIndex],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected
                                          ? Colors.blue[900]
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (!isSubmitted)
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isSubmitted = true;
                    calculateScore();
                  });
                },
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSubmitted = true;
                        calculateScore();
                      });
                    },
                    child: Text(
                      'Nộp bài',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ),
            ),
          if (isSubmitted)
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    isSubmitted = false;
                    for (var question in questions) {
                      question['selectedAnswer'] = -1;
                    }
                  });
                },
                child: Text(
                  'Làm lại',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
