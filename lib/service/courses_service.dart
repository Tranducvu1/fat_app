// lib/services/course_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('Courses');

  Future<void> addChapterToCourse(String creatorId, int chapterId) async {
    try {
      // Query the course based on the creatorId
      var querySnapshot = await coursesCollection
          .where('creatorId', isEqualTo: creatorId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("No course found for the given creatorId: $creatorId");
      }

      // Loop through all matching courses (in case there are multiple)
      for (var doc in querySnapshot.docs) {
        print('Adding chapter $chapterId to course ${doc.id}');

        // Update the chapterIds array in the course document
        await doc.reference.update({
          'chapterId': FieldValue.arrayUnion(
              [chapterId.toString()]) // Convert to string if necessary
        });
      }

      print('Chapter added successfully!');
    } catch (e) {
      print('Failed to update course: $e');
      throw Exception('Failed to update course: $e');
    }
  }

  Future<void> saveCourse(Course course) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Create a new course ID
        String courseId = _firestore.collection('Courses').doc().id;
        // Save the course data to Firestore
        await _firestore
            .collection('Courses')
            .doc(courseId)
            .set(course.toJson());

        print('Course ID: ${course.id}');
        await _firestore.collection('Users').doc(user.uid).update({
          'createdCourses': FieldValue.arrayUnion([courseId]),
        });

        DocumentSnapshot userDoc =
            await _firestore.collection('Users').doc(user.uid).get();
        List<dynamic> createdCourses = userDoc.get('createdCourses');
        print('Created Courses: $createdCourses');
      } catch (e) {
        throw Exception('Failed to add course: $e');
      }
    } else {
      throw Exception('No authenticated user found');
    }
  }
}
