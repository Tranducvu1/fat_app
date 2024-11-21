import 'package:fat_app/Model/courses.dart';
import 'package:fat_app/view/Teacher/Courses/add_courses_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fat_app/service/courses_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockCourseService extends Mock implements CourseService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

void main() {
  group('AddCoursesScreen', () {
    late MockCourseService mockCourseService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;

    setUp(() {
      mockCourseService = MockCourseService();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();

      // Setup FirebaseAuth mock
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('test_user_id');
    });

    testWidgets('should display form fields and submit successfully',
        (WidgetTester tester) async {
      // Build the AddCoursesScreen widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AddCoursesScreen(),
        ),
      ));

      // Verify that the form fields are present
      expect(find.byType(TextFormField), findsNWidgets(6)); // 6 text fields
      expect(find.byType(ElevatedButton),
          findsNWidgets(2)); // Cancel and Submit buttons

      // Enter valid data into form fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Math');
      await tester.enterText(find.byType(TextFormField).at(1), '2024-01-01');
      await tester.enterText(find.byType(TextFormField).at(2), '2024-12-31');
      await tester.enterText(find.byType(TextFormField).at(3), 'Mr. Teacher');
      await tester.enterText(find.byType(TextFormField).at(4), '100');
      await tester.enterText(
          find.byType(TextFormField).at(5), 'A description of the course.');

      // Submit the form
      await tester.tap(find.byType(ElevatedButton).at(1)); // Submit button
      await tester.pumpAndSettle();

      // Verify that the course is saved
      verify(() => mockCourseService.saveCourse(any<Course>())).called(1);
    });

    testWidgets('should show error if fields are empty',
        (WidgetTester tester) async {
      // Build the AddCoursesScreen widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AddCoursesScreen(),
        ),
      ));

      // Tap the Submit button with empty fields
      await tester.tap(find.byType(ElevatedButton).at(1)); // Submit button
      await tester.pumpAndSettle();

      // Verify that the validation error message is shown
      expect(find.text('Please enter Subject'), findsOneWidget);
      expect(find.text('Please enter Start Date'), findsOneWidget);
      expect(find.text('Please enter End Date'), findsOneWidget);
      expect(find.text('Please enter Teacher'), findsOneWidget);
      expect(find.text('Please enter Price'), findsOneWidget);
      expect(find.text('Please enter Description'), findsOneWidget);
    });
  });
}
