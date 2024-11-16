import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String question;
  final List<String> answers;
  final int correctAnswer;
  final String lessonId;
  final Timestamp createdAt;
  final String createdBy;
  final bool isActive;

  Question({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.lessonId,
    required this.createdAt,
    required this.createdBy,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answers': answers,
      'correctAnswer': correctAnswer,
      'lessonId': lessonId,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map, {String? docId}) {
    return Question(
      id: docId ?? map['id'] ?? '',
      question: map['question'] ?? '',
      answers: List<String>.from(map['answers'] ?? []),
      correctAnswer: map['correctAnswer']?.toInt() ?? 0,
      lessonId: map['lessonId'] ?? '',
      createdAt: map['createdAt'] ?? Timestamp.now(),
      createdBy: map['createdBy'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }

  Question copyWith({
    String? id,
    String? question,
    List<String>? answers,
    int? correctAnswer,
    String? lessonId,
    Timestamp? createdAt,
    String? createdBy,
    bool? isActive,
  }) {
    return Question(
      id: id ?? this.id,
      question: question ?? this.question,
      answers: answers ?? this.answers,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      lessonId: lessonId ?? this.lessonId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }
}

// models/quiz_result.dart
class QuizResult {
  final String id;
  final String userId;
  final String lessonId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  QuizResult({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lessonId': lessonId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      lessonId: map['lessonId'] ?? '',
      score: map['score']?.toInt() ?? 0,
      totalQuestions: map['totalQuestions']?.toInt() ?? 0,
      completedAt: DateTime.parse(map['completedAt']),
    );
  }
}
