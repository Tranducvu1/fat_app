import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  // Create from Map for Firestore
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'],
      description: map['description'],
      startTime: (map['startTime'] as Timestamp).toDate(),
      endTime: (map['endTime'] as Timestamp).toDate(),
    );
  }
}
