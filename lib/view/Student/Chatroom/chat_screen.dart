import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;

  ChatRoom({
    required this.chatRoomId,
    required this.otherUserName,
    required Map<String, dynamic> userMap,
  });

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showMap = false;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc =
            await _firestore.collection('Users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            username = doc.get('username') as String? ?? '';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('GPS is disabled. Enable it to share location.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _showMap = true;
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  Future<void> _shareLocation() async {
    if (_currentPosition != null) {
      final locationUrl =
          'https://www.google.com/maps?q=${_currentPosition!.latitude},${_currentPosition!.longitude}';

      // Message data for location message
      final locationMessage = {
        "sendby": username,
        "message": locationUrl,
        "type": "location",
        "time": FieldValue.serverTimestamp(),
      };

      // Last message info to update chatroom
      final lastMessageInfo = {
        "last_message": "Shared location", // Or could use locationUrl
        "last_message_time": FieldValue.serverTimestamp(),
      };

      try {
        // Start a batch write
        WriteBatch batch = _firestore.batch();

        // Add location message
        DocumentReference messageRef = _firestore
            .collection('chatrooms')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc();
        batch.set(messageRef, locationMessage);

        // Update last message info in chatroom
        DocumentReference chatroomRef =
            _firestore.collection('chatrooms').doc(widget.chatRoomId);
        batch.update(chatroomRef, lastMessageInfo);

        // Commit the batch
        await batch.commit();

        setState(() {
          _showMap = false;
        });
      } catch (e) {
        debugPrint("Error sharing location: $e");
      }
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      // Lưu tin nhắn vào subcollection chats
      Map<String, dynamic> messages = {
        "sendby": username,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      // Cập nhật last_message và last_message_time trong document chatroom
      Map<String, dynamic> lastMessageInfo = {
        "last_message": _message.text,
        "last_message_time": FieldValue.serverTimestamp(),
      };

      try {
        // Bắt đầu một batch write
        WriteBatch batch = _firestore.batch();

        // Thêm tin nhắn mới
        DocumentReference messageRef = _firestore
            .collection('chatrooms')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc();
        batch.set(messageRef, messages);

        // Cập nhật thông tin last message
        DocumentReference chatroomRef =
            _firestore.collection('chatrooms').doc(widget.chatRoomId);
        batch.update(chatroomRef, lastMessageInfo);

        // bactch excute commit
        await batch.commit();

        _message.clear();
      } catch (e) {
        print("Error sending message: $e");
      }
    } else {
      print("Enter Some Text");
    }
  }

  Widget _buildMap() {
    if (_currentPosition == null && _markers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _markers.isNotEmpty
                ? _markers.first.position
                : LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15,
          ),
          markers: _markers,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _shareLocation,
            child: const Icon(Icons.send),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                _showMap = false;
              });
            },
            child: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the widget code remains the same
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text("${widget.otherUserName}"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chatrooms')
                      .doc(widget.chatRoomId)
                      .collection('chats')
                      .orderBy("time", descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No messages yet"));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        return buildMessage(size, map);
                      },
                    );
                  },
                ),
              ),
              if (!_showMap)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _message,
                          decoration: InputDecoration(
                            hintText: "Send a message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: _getCurrentLocation,
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: onSendMessage,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (_showMap)
            Positioned.fill(
              child: _buildMap(),
            ),
        ],
      ),
    );
  }

  Widget buildMessage(Size size, Map<String, dynamic> map) {
    String formattedTime = "Unknown time";
    if (map['time'] != null) {
      Timestamp timestamp = map['time'] as Timestamp;
      DateTime dateTime = timestamp.toDate();
      formattedTime = DateFormat("HH:mm").format(dateTime);
    }

    bool isMe = map['sendby'] == username;

    return Container(
      width: size.width,
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: isMe ? Colors.blue : Colors.grey[300],
            ),
            child: Text(
              map['message'],
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 10, left: 10),
            child: Text(
              formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
