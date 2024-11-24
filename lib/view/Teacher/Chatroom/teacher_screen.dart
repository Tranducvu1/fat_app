import 'package:fat_app/Model/lesson.dart';
import 'package:fat_app/service/lesson_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TeacherScreen extends StatefulWidget {
  final int lessonId; // The ID of the lesson to be fetched

  const TeacherScreen({
    Key? key,
    required this.lessonId,
  }) : super(key: key);

  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final TextEditingController _messageController = TextEditingController();
  late YoutubePlayerController _youtubeController;
  final LessonService _lessonService = LessonService();
  Lesson? lesson; // Holds the fetched lesson data
  double _volume = 100; // Volume control for the video player

  @override
  void initState() {
    super.initState();
    _initializeYoutubeController();
    _fetchLessonData();

    // Force landscape orientation for this screen
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
    );
  }

  /// Initializes the YouTube player controller
  void _initializeYoutubeController() {
    _youtubeController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
  }

  /// Fetches lesson data from the service and updates the state
  Future<void> _fetchLessonData() async {
    try {
      final fetchedLesson =
          await _lessonService.getLessonByLessonId(widget.lessonId);

      setState(() {
        lesson = fetchedLesson;
      });

      if (lesson != null && lesson!.video.isNotEmpty) {
        _loadVideo();
      } else {
        debugPrint('Lesson video is empty or lesson is null');
      }
    } catch (e) {
      debugPrint('Error fetching lesson: $e');
      _showErrorSnackbar('Error loading lesson: $e');
    }
  }

  /// Loads the video into the YouTube player
  void _loadVideo() {
    if (lesson != null && lesson!.video.isNotEmpty) {
      _youtubeController.loadVideoById(videoId: lesson!.video);
    } else {
      debugPrint("No valid video ID to load.");
    }
  }

  /// Shows a snackbar with the specified error message
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Displays the settings modal for volume control
  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
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
                    _youtubeController.setVolume(newVolume.round());
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
  void dispose() {
    _messageController.dispose();
    _youtubeController.close();

    // Reset orientation to portrait mode when exiting the screen
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _youtubeController,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1.0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pushNamed('/listlecture');
              },
            ),
            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Mrs Thanh",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const Icon(Icons.people, color: Colors.black),
                const SizedBox(width: 5),
                const Text(
                  "30",
                  style: TextStyle(color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.black),
                  onPressed: _showSettings,
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Video player area
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: player,
                ),
              ),
              // Message input area
              _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  /// Builds the message input area below the video
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 10.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              debugPrint("Tin nhắn: ${_messageController.text}");
              _messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
