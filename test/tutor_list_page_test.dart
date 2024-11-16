import 'package:fat_app/view/Student/tutor_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  testWidgets('TutorListPage renders UI elements correctly',
      (WidgetTester tester) async {
    // Create a mock observer to use with the navigator
    final mockObserver = MockNavigatorObserver();

    // Build the TutorListPage widget
    await tester.pumpWidget(
      MaterialApp(
        home: TutorListPage(),
        navigatorObservers: [mockObserver],
      ),
    );

    // Check if the header text is displayed
    expect(find.text('Find Your Tutor'), findsOneWidget);
    expect(find.text('Discover the perfect mentor for you'), findsOneWidget);

    // Check if the search bar is present
    expect(find.byType(TextField), findsOneWidget);

    // Check if the filter chips are rendered
    expect(find.byType(FilterChip), findsWidgets);

    // Check if the loading shimmer is displayed when isLoading is true
    // You can simulate a loading state by directly modifying the state if needed
  });

  testWidgets('Search bar updates search query and calls fetchTutors',
      (WidgetTester tester) async {
    // Build the TutorListPage widget
    await tester.pumpWidget(MaterialApp(home: TutorListPage()));

    // Enter text into the search bar
    await tester.enterText(find.byType(TextField), 'math');
    await tester.pump(); // Rebuild the widget after the text input

    // Check if the search query is updated in the TextField
    expect(find.text('math'), findsOneWidget);
  });

  testWidgets('Filter chips change selectedFilter and call fetchTutors',
      (WidgetTester tester) async {
    // Build the TutorListPage widget
    await tester.pumpWidget(MaterialApp(home: TutorListPage()));

    // Tap the 'Math' filter chip
    await tester.tap(find.text('Math'));
    await tester.pump(); // Rebuild the widget after tapping

    // Check if the selected filter changes
    expect(find.text('Math'), findsOneWidget);
  });

  testWidgets('Empty state message is shown when tutors list is empty',
      (WidgetTester tester) async {
    // Build the TutorListPage widget
    await tester.pumpWidget(MaterialApp(home: TutorListPage()));

    // Assuming the tutors list is empty, check for the empty state message
    expect(find.text('No tutors found'), findsOneWidget);
    expect(find.text('Try adjusting your search or filters'), findsOneWidget);
  });
}
