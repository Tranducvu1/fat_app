import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String chatRoomId;
  final String creatorId;
  final List<String> members;
  final Timestamp createdAt;

  ChatRoom({
    required this.chatRoomId,
    required this.creatorId,
    required this.members,
    required this.createdAt,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> data) {
    return ChatRoom(
      chatRoomId: data['chatRoomId'],
      creatorId: data['creatorId'],
      members: List<String>.from(data['members']),
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatRoomId': chatRoomId,
      'creatorId': creatorId,
      'members': members,
      'createdAt': createdAt,
    };
  }
}
