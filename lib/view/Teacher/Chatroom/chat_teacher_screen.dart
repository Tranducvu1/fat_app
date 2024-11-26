import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatTeacherRoom extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;

  const ChatTeacherRoom({
    required this.chatRoomId,
    required this.otherUserName,
  });

  @override
  _ChatTeacherRoomState createState() => _ChatTeacherRoomState();
}

class _ChatTeacherRoomState extends State<ChatTeacherRoom> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showMap = false;
  Position? _currentPosition;

  String username = '';
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _mapController?.dispose();
    super.dispose();
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
      debugPrint('Error loading user data: $e');
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

  Future<void> _onLocationMessageTap(String url) async {
    final Uri uri = Uri.parse(url);
    if (uri.host == 'www.google.com' && uri.path == '/maps') {
      final latitude =
          double.parse(uri.queryParameters['q']?.split(',')[0] ?? '0');
      final longitude =
          double.parse(uri.queryParameters['q']?.split(',')[1] ?? '0');

      setState(() {
        _showMap = true;
        _markers = {
          Marker(
            markerId: const MarkerId('shared_location'),
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(title: "Shared Location"),
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 15,
          ),
        ),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              child: Icon(Icons.person),
              backgroundColor: Colors.blue,
            ),
            const SizedBox(width: 10),
            Text(widget.otherUserName),
          ],
        ),
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
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No messages"));
                    }
                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final messageData =
                            messages[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            if (messageData['type'] == 'location') {
                              _onLocationMessageTap(messageData['message']);
                            }
                          },
                          child: _buildMessageBubble(
                              MediaQuery.of(context).size, messageData),
                        );
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
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: "Enter message...",
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
                        icon: const Icon(Icons.send),
                        color: Colors.blue,
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

  Future<void> onSendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message cannot be empty")),
      );
      return;
    }

    final messageData = {
      "sendby": username,
      "message": _messageController.text.trim(),
      "type": "text",
      "time": FieldValue.serverTimestamp(),
    };

    // update last message info
    final lastMessageInfo = {
      "last_message": _messageController.text.trim(),
      "last_message_time": FieldValue.serverTimestamp(),
    };

    _messageController.clear();

    try {
      // start a batch write
      WriteBatch batch = _firestore.batch();

      // add message
      DocumentReference messageRef = _firestore
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc();
      batch.set(messageRef, messageData);

      //update last message info
      DocumentReference chatroomRef =
          _firestore.collection('chatrooms').doc(widget.chatRoomId);
      batch.update(chatroomRef, lastMessageInfo);

      // commit the batch
      await batch.commit();
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  Widget _buildMessageBubble(Size size, Map<String, dynamic> messageData) {
    final timestamp = messageData['time'] as Timestamp?;
    final formattedTime = timestamp != null
        ? DateFormat('HH:mm').format(timestamp.toDate())
        : 'Sending';

    final isMe = messageData['sendby'] == username;

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15),
                topRight: const Radius.circular(15),
                bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(15),
              ),
            ),
            child: Text(
              messageData['message'],
              style: TextStyle(
                fontSize: 16,
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
