import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String teacher;
  final String startDate;
  final String endDate;
  final double price;
  final String subject;
  final String description;
  final String creatorId;
  final Timestamp createdAt;
  final List<String> chapterId;

  Course({
    required this.id,
    required this.teacher,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.subject,
    required this.description,
    required this.creatorId,
    required this.createdAt,
    required this.chapterId,
  });

  // Convert Firestore document data into Course object
  factory Course.fromDocumentSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      teacher: data['teacher'] ?? 'Unknown Teacher',
      startDate: data['startDate'] ?? 'N/A',
      endDate: data['endDate'] ?? 'N/A',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      subject: data['subject'] ?? 'No subject',
      description: data['description'] ?? 'No description',
      creatorId: data['creatorId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      chapterId: List<String>.from(data['chapterId'] ?? []),
    );
  }

  // Convert Course object into Firestore document format
  Map<String, dynamic> toJson() {
    return {
      'teacher': teacher,
      'startDate': startDate,
      'endDate': endDate,
      'price': price,
      'subject': subject,
      'description': description,
      'creatorId': creatorId,
      'createdAt': createdAt,
      'chapterId': chapterId,
    };
  }
}
