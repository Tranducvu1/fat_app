import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Stateless widget to display a list of the most popular courses
class PopularCoursesWidget extends StatelessWidget {
  final Stream<List<DocumentSnapshot>>?
      popularCoursesStream; // Stream to listen to popular courses
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance for querying user data

  // Constructor to initialize the popular courses stream
  PopularCoursesWidget({Key? key, required this.popularCoursesStream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Flat card without shadow
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)), // Rounded corners
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align children to the start
          children: [
            // Header row with an icon and a title
            Row(
              children: [
                Icon(Icons.star,
                    color: Colors.amber[700]), // Icon for "popular"
                const SizedBox(width: 8),
                // Title text
                Text(
                  "Most Popular Courses",
                  style: TextStyle(
                    fontSize: 18, // Font size for the title
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.blue[700], // Blue color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Space below the title
            // StreamBuilder to listen to the popularCoursesStream
            StreamBuilder<List<DocumentSnapshot>>(
              stream: popularCoursesStream, // Listening to the stream
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error: ${snapshot.error}')); // Display error message
                }

                if (!snapshot.hasData) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Display loading indicator
                }

                // Extract the list of course documents from the stream
                final courses = snapshot.data!;
                return Column(
                  // Map each course document to a UI component
                  children: courses.map((courseDoc) {
                    final course = courseDoc.data()
                        as Map<String, dynamic>; // Convert document to a map
                    final courseId = courseDoc.id; // Get course ID

                    // Container to represent each course
                    return Container(
                      margin: const EdgeInsets.only(
                          bottom: 12), // Margin between courses
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue[50]!, // Light blue gradient
                            Colors.blue[100]!,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(12), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.grey.withOpacity(0.1), // Subtle shadow
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.all(16), // Padding inside the tile
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.white, // White avatar background
                          radius: 25,
                          child: Icon(Icons.school,
                              color: Colors.blue[700], size: 24), // School icon
                        ),
                        title: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start, // Align text to start
                          children: [
                            // Display course subject
                            Text(
                              course['subject'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight
                                    .bold, // Bold text for the subject
                                fontSize: 16, // Font size
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Display course teacher
                            Text(
                              'Teacher: ${course['teacher'] ?? ''}',
                              style: TextStyle(
                                color: Colors
                                    .grey[700], // Grey color for teacher text
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        // Subtitle to display the number of students enrolled
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection(
                                    'Users') // Firestore collection for users
                                .where('registeredCourses',
                                    arrayContains:
                                        courseId) // Query for students enrolled in the course
                                .snapshots(),
                            builder: (context, userSnapshot) {
                              // Count the number of students enrolled
                              final studentCount = userSnapshot.hasData
                                  ? userSnapshot.data!.docs.length
                                  : 0;
                              // Display the count inside a styled container
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[700]!.withOpacity(
                                      0.1), // Light blue background
                                  borderRadius: BorderRadius.circular(
                                      20), // Rounded edges
                                ),
                                child: Text(
                                  '$studentCount Students Enrolled', // Display student count
                                  style: TextStyle(
                                    color: Colors.blue[700], // Blue text color
                                    fontWeight:
                                        FontWeight.w500, // Medium weight
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.blue[700],
                            size: 16), // Arrow icon for navigation
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
