import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fat_app/Model/courses.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/basefires_constant.dart';

class CourseService extends BaseFirestoreService {
  static const String _collection = 'Courses';
  static const String _usersCollection = 'Users';

  CourseService({super.firestore, super.auth});

  Future<void> addChapterToCourse(String creatorId, int chapterId) async {
    return handleError(() async {
      var querySnapshot = await firestore
          .collection(_collection)
          .where(FieldPath.documentId, isEqualTo: creatorId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("No course found for creatorId: $creatorId");
      }

      await Future.wait(querySnapshot.docs.map((doc) async {
        print('Adding chapter $chapterId to course ${doc.id}');
        return doc.reference.update({
          'chapterId': FieldValue.arrayUnion([chapterId.toString()])
        });
      }));

      print('Chapter added successfully!');
    }, 'add chapter to course');
  }

  Future<void> saveCourse(Course course) async {
    return handleError(() async {
      User? user = auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      String courseId = firestore.collection(_collection).doc().id;

      // Transaction to ensure atomicity
      await firestore.runTransaction((transaction) async {
        // Save course
        transaction.set(
          firestore.collection(_collection).doc(courseId),
          course.toJson(),
        );

        // Update user's created courses
        transaction.update(
          firestore.collection(_usersCollection).doc(user.uid),
          {
            'createdCourses': FieldValue.arrayUnion([courseId]),
          },
        );
      });

      print('Course saved successfully with ID: ${course.id}');
    }, 'save course');
  }

  Future<void> updateCourse(Course course) async {
    try {
      await firestore.collection('Courses').doc(course.id).update({
        'teacher': course.teacher,
        'startDate': course.startDate,
        'endDate': course.endDate,
        'price': course.price,
        'subject': course.subject,
        'description': course.description,
      });
    } catch (e) {
      throw Exception('Failed to update course: $e');
    }
  }
}
