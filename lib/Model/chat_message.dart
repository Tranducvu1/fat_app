import 'package:cloud_firestore/cloud_firestore.dart';

// ChatMessage model
class ChatMessage {
  final String sendBy;
  final String message;
  final String type;
  final Timestamp time;

  ChatMessage({
    required this.sendBy,
    required this.message,
    required this.type,
    required this.time,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      sendBy: data['sendby'],
      message: data['message'],
      type: data['type'],
      time: data['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sendby': sendBy,
      'message': message,
      'type': type,
      'time': time,
    };
  }
}
