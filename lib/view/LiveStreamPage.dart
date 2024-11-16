import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LiveStreamPage extends StatefulWidget {
  @override
  _LiveStreamPageState createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _addViewer();
  }

  @override
  void dispose() {
    _removeViewer();
    _commentController
        .dispose(); // Dispose the controller when the page is closed
    super.dispose();
  }

  Future<void> _addViewer() async {
    User? user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('viewers').doc(user.uid).set({
        'username': user.displayName ?? 'Anonymous',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Xóa người xem khi họ thoát livestream
  Future<void> _removeViewer() async {
    User? user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('viewers').doc(user.uid).delete();
    }
  }

  // Thêm bình luận vào Firestore
  Future<void> _addComment(String comment) async {
    User? user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('comments').add({
        'username': user.displayName ?? 'Anonymous',
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': 0,
        'dislikes': 0,
      });
    }
  }

  // UI cho trang livestream
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livestream'),
      ),
      body: Column(
        children: [
          // Phần hiển thị video livestream (giả lập)
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  'Video Livestream',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          // around like anhd dislike
          Expanded(
            flex: 2,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                // Hiển thị danh sách bình luận
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    return ListTile(
                      title: Text(document['username']),
                      subtitle: Text(document['comment']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.thumb_up),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('comments')
                                  .doc(document.id)
                                  .update({'likes': FieldValue.increment(1)});
                            },
                          ),
                          Text(document['likes'].toString()),
                          IconButton(
                            icon: Icon(Icons.thumb_down),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('comments')
                                  .doc(document.id)
                                  .update(
                                      {'dislikes': FieldValue.increment(1)});
                            },
                          ),
                          Text(document['dislikes'].toString()),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Khu vực nhập bình luận
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Enter your comment',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_commentController.text.isNotEmpty) {
                      _addComment(_commentController.text);
                      _commentController.clear();
                    }
                  },
                ),
              ),
            ),
          ),

          // Khu vực hiển thị người xem hiện tại
          StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('viewers').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return Container();
              return Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: snapshot.data!.docs.map((document) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Chip(
                        label: Text(document['username']),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
// Phần hiển thị video livestream (giả lập) là sao