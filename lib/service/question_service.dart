import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package for accessing Cloud Firestore
import 'package:fat_app/Model/question.dart'; // Import the Question model to map data to/from Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication for getting the current user's ID
import 'package:uuid/uuid.dart'; // UUID package to generate unique IDs for new questions

class QuestionService {
  // Method to add a new question to the database and associate it with a lesson
  Future<void> addQuestion(String lessonId, String questionText,
      List<String> answers, int correctAnswer) async {
    // Create a new question object with the provided details
    final question = Question(
      id: const Uuid().v4(), // Generate a unique ID for the question
      question: questionText, // The question text provided by the user
      answers: answers, // List of possible answers
      correctAnswer:
          correctAnswer, // The index of the correct answer in the list
      createdAt: Timestamp.fromDate(
          DateTime.now()), // Timestamp when the question is created
      createdBy: FirebaseAuth.instance.currentUser!
          .uid, // The ID of the user who created the question
    );

    try {
      // Add the question to the 'questions' collection in Firestore
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(question.id) // Use the unique question ID as the document ID
          .set(question
              .toMap()); // Map the question object to a Firestore document

      print("Lesson ID: $lessonId");

      // Query the 'lesson' collection to find the lesson document that matches the provided lessonId
      final lessonQuerySnapshot = await FirebaseFirestore.instance
          .collection('lesson')
          .where('lesson_ID',
              isEqualTo: int.parse(
                  lessonId)) // Compare 'lesson_ID' field with lessonId
          .get();

      if (lessonQuerySnapshot.docs.isNotEmpty) {
        // If at least one lesson document is found that matches the lessonId
        final lessonDocRef = lessonQuerySnapshot.docs.first
            .reference; // Get the reference to the first matching lesson document

        // Update the 'Question_ID' field of the lesson document by adding the new question's ID
        await lessonDocRef.update({
          'Question_ID': FieldValue.arrayUnion([
            question.id
          ]), // Add the question ID to the array of Question_IDs
        });

        // Fetch the updated lesson document to verify the update
        final updatedLessonDoc = await lessonDocRef.get();
        print("After update, Lesson data: ${updatedLessonDoc.data()}");
      } else {
        // If no matching lesson document is found, throw an error
        throw Exception('No lesson found with this ID!');
      }
    } catch (e) {
      // Re-throw any caught exceptions
      rethrow;
    }
  }
}
