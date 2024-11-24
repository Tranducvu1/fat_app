import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/event.dart';
import 'package:fat_app/view/widgets/navigation/custom_app_bar.dart';
import 'package:fat_app/view/widgets/navigation/custom_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/view/widgets/search_bar.dart';
import 'package:fat_app/view/widgets/subject_chips.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:file_picker/file_picker.dart';

class ClassSchedulePage extends StatefulWidget {
  const ClassSchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _ClassSchedulePage();
}

class _ClassSchedulePage extends State<ClassSchedulePage> {
  String username = '';
  final FirebaseStorage _storage = FirebaseStorage.instance;

  int currentIndex = 1;
  final List<String> subjects = [
    'Chemistry',
    'Physics',
    'Math',
    'Geography',
    'History',
  ];

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<PlatformFile> _selectedFiles = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get();

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

  Future<String?> uploadFile(PlatformFile file) async {
    try {
      final ref = _storage.ref().child('uploads/${file.name}');
      final uploadTask = ref.putFile(File(file.path!));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<void> _pickFiles() async {
    try {
      setState(() {
        isLoading = true;
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.files);
        });
      }
    } catch (e) {
      print('Error picking files: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> downloadFile(String fileName, String downloadUrl) async {
    try {
      print('Download URL: $downloadUrl');

      return true;
    } catch (e) {
      print('Error downloading file: $e');
      return false;
    }
  }

  Future<void> _loadEvents() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('events')
            .get();

        Map<DateTime, List<Event>> newEvents = {};

        for (var doc in snapshot.docs) {
          final event = Event.fromMap(doc.data());
          final date = DateTime(
            event.startTime.year,
            event.startTime.month,
            event.startTime.day,
          );

          if (newEvents[date] == null) newEvents[date] = [];
          newEvents[date]!.add(event);
        }

        setState(() {
          _events = newEvents;
        });
      }
    } catch (e) {
      print('Error loading events: $e');
    }
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showAddEventDialog(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (_selectedDay != null) _buildEventList(_selectedDay!),
        ],
      ),
    );
  }

  Widget _buildEventList(DateTime day) {
    final events = _events[day] ?? [];

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No events for this day'),
            ),
          ...events.map((event) => _buildEventCard(event)).toList(),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(event.description),
        trailing: Text(
          '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - '
          '${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Future<void> _showAddEventDialog(DateTime selectedDay) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) {
                        setState(() => _startTime = time);
                      }
                    },
                    child: const Text('Start Time'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) {
                        setState(() => _endTime = time);
                      }
                    },
                    child: const Text('End Time'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _saveEvent(selectedDay),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEvent(DateTime selectedDay) async {
    if (_titleController.text.isEmpty) return;

    final startDateTime = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      _endTime.hour,
      _endTime.minute,
    );

    final newEvent = Event(
      title: _titleController.text,
      description: _descriptionController.text,
      startTime: startDateTime,
      endTime: endDateTime,
    );

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .collection('events')
            .add(newEvent.toMap());

        final date = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
        );

        setState(() {
          if (_events[date] == null) _events[date] = [];
          _events[date]!.add(newEvent);
        });
      }
    } catch (e) {
      print('Error saving event: $e');
    }

    _titleController.clear();
    _descriptionController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        // Changed to CustomTeacherAppBar
        username: username,
        onAvatarTap: () =>
            Navigator.of(context).pushNamed('/updateinformation'),
        onNotificationTap: () {},
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SearchBarWidget(
                    onSearch: (query) {
                      print("Search query: $query");
                    },
                  ),
                  const SizedBox(height: 16.0),
                  SubjectChipsWidget(subjects: subjects),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildCalendar(), // Added calendar widget
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[300]!, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tran Duc Vu! Keep up the great work! 🌟',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Classes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildClassCard(
                'Mathematics',
                'Mr. John Smith',
                '18:30 - 21:00',
                'Wednesday',
                Colors.blue[100]!,
                Icons.functions,
              ),
              _buildClassCard(
                'Physics',
                'Dr. Sarah Wilson',
                '14:00 - 16:30',
                'Monday',
                Colors.purple[100]!,
                Icons.science,
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          _navigateToPage(index);
        },
      ),
    );
  }

  Widget _buildClassCard(String subject, String teacher, String time,
      String day, Color backgroundColor, IconData subjectIcon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [backgroundColor, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: backgroundColor.withOpacity(0.3),
              child: Icon(subjectIcon, color: backgroundColor.withOpacity(0.8)),
            ),
            title: Text(
              subject,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              '$time • $day',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          teacher,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: [
                              Tab(text: 'Assignments'),
                              Tab(text: 'Documents'),
                              Tab(text: 'Comments'),
                            ],
                          ),
                          Container(
                            height: 100,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: TabBarView(
                              children: [
                                _buildEmptyState(
                                  'No assignments yet',
                                  Icons.assignment,
                                ),
                                Column(
                                  children: [
                                    Expanded(
                                      child: _selectedFiles.isEmpty
                                          ? GestureDetector(
                                              onTap: _pickFiles,
                                              child: _buildEmptyState(
                                                'Tap to upload documents',
                                                Icons.upload_file,
                                              ),
                                            )
                                          : ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: _selectedFiles.length,
                                              itemBuilder: (context, index) {
                                                final file =
                                                    _selectedFiles[index];
                                                return ListTile(
                                                  leading: GestureDetector(
                                                    onTap: _pickFiles,
                                                    child: const Icon(Icons
                                                        .insert_drive_file),
                                                  ),
                                                  title: Text(file.name),
                                                  subtitle: Text(
                                                      '${(file.size / 1024).toStringAsFixed(2)} KB'),
                                                  trailing: IconButton(
                                                    icon: const Icon(
                                                        Icons.download),
                                                    onPressed: () async {
                                                      final downloadUrl =
                                                          await uploadFile(
                                                              file);
                                                      if (downloadUrl != null) {
                                                        final success =
                                                            await downloadFile(
                                                                file.name,
                                                                downloadUrl);
                                                        if (success) {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'File downloaded successfully!')),
                                                            );
                                                          }
                                                        } else {
                                                          if (context.mounted) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Failed to download file')),
                                                            );
                                                          }
                                                        }
                                                      }
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                                _buildEmptyState(
                                  'No comments yet',
                                  Icons.chat_bubble_outline,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    final routes = [
      '/interactlearning',
      '/classschedule',
      '/course',
      '/inbox',
      '/findtutor',
    ];
    if (index >= 0 && index < routes.length) {
      Navigator.of(context).pushNamed(routes[index]);
    }
  }
}
