import 'package:flutter/material.dart';
import 'package:fat_app/Model/Courses.dart';

// Stateless widget to display a course card with details
class CourseCard extends StatelessWidget {
  final Course
      course; // Course object containing course details (subject, description, etc.)
  final bool
      isRegistered; // Boolean to indicate if the user is registered for the course
  final VoidCallback onTap; // Callback function to handle the tap event

  // Constructor to initialize the course, registration status, and tap handler
  const CourseCard({
    Key? key,
    required this.course, // Required course object
    required this.isRegistered, // Required registration status
    required this.onTap, // Required tap event handler
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // GestureDetector to detect taps on the card
    return GestureDetector(
      onTap:
          onTap, // Trigger the provided onTap callback when the card is tapped
      child: Card(
        elevation: 4, // Set elevation to give the card a shadow
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10), // Rounded corners for the card
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the content inside the column
          children: [
            // Course subject displayed in bold with larger font size
            Text(
              course.subject,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // Add spacing between subject and description
            // Course description displayed with smaller font size and centered text
            Text(
              course.description,
              textAlign: TextAlign.center, // Center the text
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
                height:
                    10), // Add spacing between description and registration status
            // Display registration status (either 'Registered' or 'Register')
            Text(
              isRegistered
                  ? 'Registered'
                  : 'Register', // Text changes based on registration status
              style: TextStyle(
                color: isRegistered
                    ? Colors.green
                    : Colors.blue, // Green if registered, blue if not
                fontSize: 16,
                fontWeight: FontWeight.bold, // Bold text style
              ),
            ),
          ],
        ),
      ),
    );
  }
}
