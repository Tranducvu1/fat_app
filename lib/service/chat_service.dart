import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = Uuid();

  Future<void> sendTextMessage(String chatRoomId, String message) async {
    if (message.isNotEmpty) {
      Map<String, dynamic> messageData = {
        "sendby": _auth.currentUser!.displayName,
        "message": message,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messageData);
    } else {
      print("Message cannot be empty");
    }
  }

  Future<void> uploadImage(String chatRoomId, File imageFile) async {
    String fileName = _uuid.v1();
    int status = 1;

    // Create a placeholder entry for the image
    await _firestore
        .collection('chatroom')
        .doc(chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": _auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    try {
      // Upload image to Firebase Storage
      var ref =
          FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");
      var uploadTask = await ref.putFile(imageFile);
      String imageUrl = await uploadTask.ref.getDownloadURL();

      // Update Firestore with the image URL
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .update({
        "message": imageUrl,
      });
    } catch (error) {
      await _firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    }

    if (status == 0) {
      print("Error uploading image");
    }
  }

  Future<void> pickAndUploadImage(String chatRoomId) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await uploadImage(chatRoomId, imageFile);
    }
  }
}
