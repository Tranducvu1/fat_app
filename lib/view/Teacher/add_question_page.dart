import 'package:fat_app/Model/question.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AddQuestionPage extends StatefulWidget {
  final String lessonId;

  const AddQuestionPage({Key? key, required this.lessonId}) : super(key: key);

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  int _selectedCorrectAnswer = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final question = Question(
        id: const Uuid().v4(),
        question: _questionController.text,
        answers: _answerControllers.map((c) => c.text).toList(),
        correctAnswer: _selectedCorrectAnswer,
        lessonId: widget.lessonId,
        createdAt: Timestamp.fromDate(DateTime.now()),
        createdBy: FirebaseAuth.instance.currentUser!.uid,
      );

      await FirebaseFirestore.instance
          .collection('questions')
          .doc(question.id)
          .set(question.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Câu hỏi đã được thêm thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _questionController.clear();
    for (var controller in _answerControllers) {
      controller.clear();
    }
    setState(() => _selectedCorrectAnswer = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Câu Hỏi Mới'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _questionController,
                          decoration: InputDecoration(
                            labelText: 'Câu hỏi',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          maxLines: 3,
                          validator: (value) => value?.isEmpty == true
                              ? 'Vui lòng nhập câu hỏi'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Các câu trả lời',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate(
                          4,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Radio<int>(
                                  value: index,
                                  groupValue: _selectedCorrectAnswer,
                                  onChanged: (value) {
                                    setState(
                                        () => _selectedCorrectAnswer = value!);
                                  },
                                ),
                                Expanded(
                                  child: TextFormField(
                                    controller: _answerControllers[index],
                                    decoration: InputDecoration(
                                      labelText: 'Câu trả lời ${index + 1}',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                    ),
                                    validator: (value) => value?.isEmpty == true
                                        ? 'Vui lòng nhập câu trả lời'
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Lưu Câu Hỏi',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
