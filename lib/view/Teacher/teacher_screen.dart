import 'package:fat_app/Model/lesson.dart';
import 'package:fat_app/service/lesson_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:ui' as ui;

class TeacherScreen extends StatefulWidget {
  final int lessonId;

  const TeacherScreen({
    Key? key,
    required this.lessonId,
  }) : super(key: key);

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final TextEditingController _messageController = TextEditingController();
  late YoutubePlayerController _controller;
  final LessonService _lessonService = LessonService();
  Lesson? lesson;
  double _volume = 100;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
    _fetchLessonData();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  Future<void> _fetchLessonData() async {
    try {
      final fetchedLesson =
          await _lessonService.getLessonByLessonId(widget.lessonId);

      setState(() {
        lesson = fetchedLesson;
      });
      if (lesson != null && lesson!.video.isNotEmpty) {
        print('Lesson video: ${lesson!.video}');
        _loadVideo();
      } else {
        print('Lesson video is empty or lesson is null');
      }
    } catch (e) {
      print('Error fetching lesson: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading lesson: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _loadVideo() {
    if (lesson != null && lesson!.video.isNotEmpty) {
      String videoId = lesson!.video;
      print('VideoId before loading: $videoId');

      _controller.loadVideoById(
        videoId: videoId,
      );
    } else {
      print("No valid video ID to load.");
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _controller.close();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.dispose();
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cài đặt âm lượng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _volume,
                min: 0,
                max: 100,
                onChanged: (newVolume) {
                  setState(() {
                    _volume = newVolume;
                    _controller.setVolume(newVolume.round());
                  });
                },
              ),
              Text('Âm lượng: ${_volume.round()}%'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1.0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pushNamed('/listlecture');
              },
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    "Mrs Thanh",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Icon(Icons.people, color: Colors.black),
                SizedBox(width: 5),
                Text(
                  "30",
                  style: TextStyle(color: Colors.black),
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: Colors.black),
                  onPressed: _showSettings,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: player,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Nhập tin nhắn...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10.0),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        print("Tin nhắn: ${_messageController.text}");
                        _messageController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
