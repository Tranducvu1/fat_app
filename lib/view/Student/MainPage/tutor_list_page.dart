import 'package:fat_app/Model/UserModel.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/Model/tutorData.dart';
import 'package:fat_app/view/Student/MainPage/tutor_detail_page.dart';

import 'package:fat_app/view/widgets/navigation/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorListPage extends StatefulWidget {
  const TutorListPage({super.key});

  @override
  State<TutorListPage> createState() => _TutorListPageState();
}

class _TutorListPageState extends State<TutorListPage> {
  List<TutorData> tutors = [];
  String searchQuery = "";
  bool isLoading = false;
  String selectedFilter = 'All';
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTutors();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchTutors() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot queryResult;

      // query courses
      if (selectedFilter != 'All') {
        queryResult = await FirebaseFirestore.instance
            .collection('Courses')
            .where('subject', isEqualTo: selectedFilter)
            .get();
      } else {
        queryResult =
            await FirebaseFirestore.instance.collection('Courses').get();
      }

      // get creatorIds
      final creatorIds = queryResult.docs
          .map((doc) => doc['creatorId'] ?? '')
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final usersSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where(FieldPath.documentId, whereIn: creatorIds)
          .get();

      final userMap = {
        for (var userDoc in usersSnapshot.docs)
          userDoc.id: UserModel.fromMap(userDoc.data() as Map<String, dynamic>)
      };

      // process courses
      List<TutorData> loadedTutors = [];
      for (var courseDoc in queryResult.docs) {
        try {
          Course course = Course.fromDocumentSnapshot(courseDoc);
          final user = userMap[course.creatorId];

          if (user != null) {
            // filter courses by search query
            final matchesQuery = searchQuery.isEmpty ||
                course.subject
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                user.position
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()) ||
                course.teacher
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase());

            if (matchesQuery) {
              loadedTutors.add(TutorData(course: course, user: user));
            }
          }
        } catch (e) {
          print('Error processing course or user: $e');
          continue;
        }
      }
      // update state
      if (!mounted) return;

      setState(() {
        tutors = loadedTutors;
        isLoading = false;
      });
    } catch (e) {
      print('Error in fetchTutors: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading tutors: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<void> fetchTutors() async {
  //   if (!mounted) return;

  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     QuerySnapshot queryResult;

  //     if (selectedFilter != 'All') {
  //       queryResult = await FirebaseFirestore.instance
  //           .collection('Courses')
  //           .where('subject', isEqualTo: selectedFilter)
  //           .get();
  //     } else {
  //       queryResult =
  //           await FirebaseFirestore.instance.collection('Courses').get();
  //     }

  //     List<TutorData> loadedTutors = [];

  //     for (var doc in queryResult.docs) {
  //       // Kiểm tra search query
  //       if (searchQuery.isNotEmpty) {
  //         final subject = (doc['subject'] ?? '').toString().toLowerCase();
  //         final teacher = (doc['teacher'] ?? '').toString().toLowerCase();
  //         if (!subject.contains(searchQuery.toLowerCase()) &&
  //             !teacher.contains(searchQuery.toLowerCase())) {
  //           continue;
  //         }
  //       }

  //       try {
  //         Course course = Course.fromDocumentSnapshot(doc);

  //         // Kiểm tra creatorId
  //         if (course.creatorId != null && course.creatorId.isNotEmpty) {
  //           try {
  //             DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //                 .collection('Users')
  //                 .doc(course.creatorId)
  //                 .get();

  //             if (userDoc.exists && userDoc.data() != null) {
  //               UserModel user =
  //                   UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
  //               loadedTutors.add(TutorData(course: course, user: user));
  //             }
  //           } catch (userError) {
  //             print('Error fetching user data: $userError');
  //             continue;
  //           }
  //         }
  //       } catch (courseError) {
  //         print('Error processing course data: $courseError');
  //         continue;
  //       }
  //     }

  //     if (!mounted) return;

  //     setState(() {
  //       tutors = loadedTutors;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print('Error in fetchTutors: $e');
  //     if (!mounted) return;

  //     setState(() {
  //       isLoading = false;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error loading tutors: ${e.toString()}'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchTutors,
                child: _buildTutorList(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 4,
        onTap: _navigateToPage,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Your Tutor',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Discover the perfect mentor for you',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green[50],
            child: Icon(Icons.person, color: Colors.green[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search by subject or teacher name',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        searchQuery = "";
                      });
                      fetchTutors();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
            fetchTutors();
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      'All',
      'Math',
      'Science',
      'Chemistry',
      'English',
      'Physic'
    ];
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedFilter = filter;
                });
                fetchTutors();
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.green[100],
              checkmarkColor: Colors.green[700],
              labelStyle: TextStyle(
                color: isSelected ? Colors.green[700] : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTutorList() {
    if (isLoading) {
      return _buildLoadingShimmer();
    }

    if (tutors.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: tutors.length,
      itemBuilder: (context, index) {
        final tutorData = tutors[index];
        return _buildTutorCard(tutorData);
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (_, __) => Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(height: 160),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tutors found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard(TutorData tutorData) {
    final course = tutorData.course;
    final user = tutorData.user;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TutorDetailPage(
              course: course,
              user: user,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'tutor-${course.creatorId}',
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.green[50],
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: user.profileImage ??
                              "https://example.com/default-avatar.png",
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.green[700],
                          ),
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.teacher,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.position,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.phoneNumber,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      Icons.subject,
                      course.subject,
                      'Subject',
                    ),
                    _buildInfoItem(
                      Icons.access_time,
                      '${course.startDate} - ${course.endDate}',
                      'Time',
                    ),
                    _buildInfoItem(
                      Icons.location_on,
                      '5 km',
                      'Distance',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                course.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[700], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _navigateToPage(int index) {
    final routes = [
      '/interactlearning',
      '/classschedule',
      '/course',
      '/chat',
      '/findatutor'
    ];

    if (index >= 0 && index < routes.length) {
      Navigator.of(context).pushNamed(routes[index]);
    }
  }
}
