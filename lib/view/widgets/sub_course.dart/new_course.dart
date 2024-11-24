import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Stateless widget to display a list of new courses fetched from Firestore
class NewCoursesWidget extends StatelessWidget {
  final Stream<List<DocumentSnapshot>>?
      newCoursesStream; // Stream of new courses from Firestore

  // Constructor to initialize the stream of new courses
  const NewCoursesWidget({Key? key, required this.newCoursesStream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Card widget to display the new courses section
    return Card(
      elevation: 0, // No shadow for the card
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16)), // Rounded corners for the card
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align children to the start
          children: [
            // Row for the header (icon + title)
            Row(
              children: [
                // Icon to represent "new releases"
                Icon(Icons.new_releases, color: Colors.green[700]),
                const SizedBox(width: 8),
                // Title "New Courses"
                Text(
                  "New Courses",
                  style: TextStyle(
                    fontSize: 18, // Font size for title
                    fontWeight: FontWeight.bold, // Bold text style
                    color: Colors.blue[700], // Title color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16), // Add spacing below the title
            // StreamBuilder to listen to the new courses stream
            StreamBuilder<List<DocumentSnapshot>>(
              stream: newCoursesStream, // Listen to the new courses stream
              builder: (context, snapshot) {
                // If there is an error in the stream
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // If no data is available yet, show a loading indicator
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Get the list of courses from the stream
                final courses = snapshot.data!;
                // Display each course as a list item
                return Column(
                  children: courses.map((courseDoc) {
                    final course = courseDoc.data() as Map<String, dynamic>;

                    // Return a container with a gradient background for each course
                    return Container(
                      margin: const EdgeInsets.only(
                          bottom: 12), // Margin between courses
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment
                              .topLeft, // Gradient starts from top-left
                          end: Alignment
                              .bottomRight, // Gradient ends at bottom-right
                          colors: [
                            Colors.green[50]!, // Light green
                            Colors.green[100]!, // Darker green
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                            12), // Rounded corners for the container
                        boxShadow: [
                          // Shadow effect for the container
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(
                            16), // Padding inside the list tile
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.white, // White background for the avatar
                          radius: 25, // Avatar radius
                          child: Icon(Icons.auto_awesome,
                              color: Colors.green[700],
                              size: 24), // Icon for the avatar
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align the title to the start
                          children: [
                            // Row to display subject and "NEW" tag
                            Row(
                              children: [
                                Text(
                                  course['subject'] ??
                                      '', // Display course subject
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold, // Bold text style
                                    fontSize: 16, // Font size for the subject
                                  ),
                                ),
                                const SizedBox(
                                    width:
                                        8), // Spacing between subject and tag
                                // "NEW" tag to indicate the course is new
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green[
                                        700], // Green background for the tag
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white, // White text color
                                      fontSize:
                                          10, // Small font size for the tag
                                      fontWeight:
                                          FontWeight.bold, // Bold text style
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height:
                                    4), // Spacing between subject and teacher
                            Text(
                              'Teacher: ${course['teacher'] ?? ''}', // Display teacher's name
                              style: TextStyle(
                                color:
                                    Colors.grey[700], // Text color for teacher
                                fontSize: 14, // Font size for the teacher text
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            course['description'] ??
                                '', // Display course description
                            maxLines: 2, // Limit to 2 lines
                            overflow: TextOverflow
                                .ellipsis, // Add ellipsis if description is too long
                            style: TextStyle(
                              color: Colors
                                  .grey[600], // Text color for description
                              fontSize:
                                  12, // Font size for the description text
                            ),
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.green[700],
                            size: 16), // Arrow icon for trailing
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
