import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseScreen extends StatelessWidget {
  static const String routeName = '/CourseScreen';

  // Method to delete a document from Firestore
  void deleteCourse(String courseId) {
    FirebaseFirestore.instance.collection('Courses').doc(courseId).delete();
  }

  // Method to navigate to the edit screen or open a dialog
  void editCourse(BuildContext context, DocumentSnapshot course) {
    // Open a dialog or navigate to the course detail edit screen here
    // Example: Navigator.pushNamed(context, EditCourseScreen.routeName, arguments: course);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Courses'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Courses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No courses available.'));
          }

          var courses = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Table(
                border: TableBorder.all(),
                columnWidths: {
                  0: FlexColumnWidth(0.5), // Column "Course ID"
                  1: FlexColumnWidth(2), // Column "Teacher"
                  2: FlexColumnWidth(2), // Column "Duration"
                  3: FlexColumnWidth(1), // Column "Edit"
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                  6: FlexColumnWidth(1), // Column "Delete"
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Course Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Teacher',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Price',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Display data from Firebase
                  ...courses.map((course) {
                    var data = course.data() as Map<String, dynamic>;
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            // Add Center widget to align text in the middle
                            child: Text(
                              data['id']?.toString() ?? 'N/A',
                              textAlign: TextAlign
                                  .center, // Align text horizontally in the center
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(data['subject'] ?? 'N/A'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(data['teacher'] ?? 'N/A'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(data['price']?.toString() ?? 'N/A'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(data['description'] ?? 'N/A'),
                        ),
                        // Edit button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => editCourse(context, course),
                          ),
                        ),
                        // Delete button
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              deleteCourse(course.id);
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
