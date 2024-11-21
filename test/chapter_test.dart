import 'package:fat_app/view/Teacher/Chapter/add_chapter_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fat_app/Model/chapter.dart';
import 'package:fat_app/service/chapter_service.dart';
import 'package:fat_app/service/courses_service.dart';

class MockChapterService extends Mock implements ChapterService {}

class MockCourseService extends Mock implements CourseService {}

void main() {
  late MockChapterService mockChapterService;
  late MockCourseService mockCourseService;

  setUp(() {
    mockChapterService = MockChapterService();
    mockCourseService = MockCourseService();
  });

  testWidgets('Chapter form adds a chapter successfully',
      (WidgetTester tester) async {
    const courseId = 'course123';

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: AddChapterForm(
          courseId: courseId,
          onChapterAdded: () {},
        ),
      ),
    );

    // Enter valid chapter ID and chapter name
    await tester.enterText(find.byType(TextFormField).at(0), '101');
    await tester.enterText(find.byType(TextFormField).at(1), 'Chapter 1');

    // Tap the 'Add Chapter' button
    await tester.tap(find.text('Add Chapter'));
    await tester.pumpAndSettle();

    // Verify that the services are called
    verify(() => mockChapterService.addChapter(any<Chapter>())).called(1);
    verify(() => mockCourseService.addChapterToCourse(courseId, 101)).called(1);

    // Verify that a success message appears
    expect(find.text('Chapter added successfully'), findsOneWidget);

    // Verify that the form clears after submission
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text(''), findsNWidgets(2));
  });

  testWidgets(
      'Chapter form shows validation error when invalid data is entered',
      (WidgetTester tester) async {
    const courseId = 'course123';

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: AddChapterForm(
          courseId: courseId,
          onChapterAdded: () {},
        ),
      ),
    );

    // Tap the 'Add Chapter' button without entering text
    await tester.tap(find.text('Add Chapter'));
    await tester.pump();

    // Verify that the validation messages appear
    expect(find.text('Please enter chapter ID'), findsOneWidget);
    expect(find.text('Please enter chapter name'), findsOneWidget);
  });

  testWidgets('Chapter form shows error when service throws exception',
      (WidgetTester tester) async {
    const courseId = 'course123';

    // Mock the addChapter method to throw an exception
    when(() => mockChapterService.addChapter(any<Chapter>()))
        .thenAnswer((_) async => throw Exception('Failed to add chapter'));

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: AddChapterForm(
          courseId: courseId,
          onChapterAdded: () {},
        ),
      ),
    );

    // Enter valid chapter ID and chapter name
    await tester.enterText(find.byType(TextFormField).at(0), '101');
    await tester.enterText(find.byType(TextFormField).at(1), 'Chapter 1');

    // Tap the 'Add Chapter' button
    await tester.tap(find.text('Add Chapter'));
    await tester.pumpAndSettle();

    // Verify that an error message appears
    expect(find.text('Error adding chapter: Exception: Failed to add chapter'),
        findsOneWidget);
  });
}
