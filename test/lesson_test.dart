import 'package:fat_app/view/Teacher/Lesson/add_lesson_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fat_app/service/chapter_service.dart';

class MockChapterService extends Mock implements ChapterService {}

void main() {
  late MockChapterService mockChapterService;

  setUp(() {
    mockChapterService = MockChapterService();
  });

  testWidgets('Lesson form adds a lesson successfully',
      (WidgetTester tester) async {
    const chapterId = 101;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: AddLessonForm(
          chapterId: chapterId,
          onLessonAdded: () {},
        ),
      ),
    );

    // Enter valid lesson details
    await tester.enterText(
        find.byType(TextFormField).at(0), '1001'); // Lesson ID
    await tester.enterText(
        find.byType(TextFormField).at(1), 'Lesson 1'); // Lesson Name
    await tester.enterText(find.byType(TextFormField).at(2),
        'Description of lesson 1'); // Description
    await tester.enterText(find.byType(TextFormField).at(3),
        'https://youtu.be/dQw4w9WgXcQ'); // Video URL

    // Tap the 'Submit' button
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify that the addLesson and addLessonIdToChapter methods were called
    verify(() => mockChapterService.addLesson(any())).called(1);
    verify(() => mockChapterService.addLessonIdToChapter(chapterId, 1001))
        .called(1);

    // Verify that a success message appears
    expect(find.text('Lesson added successfully'), findsOneWidget);

    // Verify that the form fields are cleared after submission
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.text(''), findsNWidgets(4));
  });

  testWidgets('Lesson form shows validation error when invalid data is entered',
      (WidgetTester tester) async {
    const chapterId = 101;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: AddLessonForm(
          chapterId: chapterId,
          onLessonAdded: () {},
        ),
      ),
    );

    // Tap the 'Submit' button without entering text
    await tester.tap(find.text('Submit'));
    await tester.pump();

    // Verify that validation messages appear for all fields
    expect(find.text('Please enter lesson ID'), findsOneWidget);
    expect(find.text('Please enter lesson name'), findsOneWidget);
    expect(find.text('Please enter lesson description'), findsOneWidget);
    expect(find.text('Please enter video URL'), findsOneWidget);
  });

  testWidgets('Lesson form shows error when service throws exception',
      (WidgetTester tester) async {
    const chapterId = 101;

    // Mock the addLesson method to throw an exception
    when(() => mockChapterService.addLesson(any()))
        .thenAnswer((_) async => throw Exception('Failed to add lesson'));

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: AddLessonForm(
          chapterId: chapterId,
          onLessonAdded: () {},
        ),
      ),
    );

    // Enter valid lesson details
    await tester.enterText(find.byType(TextFormField).at(0), '1001');
    await tester.enterText(find.byType(TextFormField).at(1), 'Lesson 1');
    await tester.enterText(
        find.byType(TextFormField).at(2), 'Description of lesson 1');
    await tester.enterText(
        find.byType(TextFormField).at(3), 'https://youtu.be/dQw4w9WgXcQ');

    // Tap the 'Submit' button
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify that an error message appears
    expect(find.text('Error adding lesson: Exception: Failed to add lesson'),
        findsOneWidget);
  });
}
