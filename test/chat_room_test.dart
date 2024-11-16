// import 'package:fat_app/view/Teacher/tutor_chat_rooms_page%20.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:fat_app/view/Teacher/chat_teacher_screen.dart';

// import 'updateinformation_test.dart';


// // Annotation for generating mock classes
// @GenerateMocks(
//     [FirebaseFirestore, FirebaseAuth, User, QuerySnapshot, DocumentSnapshot])
// void main() {
//   // Initialize mock objects
//   late MockFirebaseFirestore mockFirestore;
//   late MockFirebaseAuth mockAuth;
//   late MockUser mockUser;

//   setUp(() {
//     mockFirestore = MockFirebaseFirestore();
//     mockAuth = MockFirebaseAuth();
//     mockUser = MockUser();

//     // Setup mock current user
//     when(mockAuth.currentUser).thenReturn(mockUser);
//     when(mockUser.uid).thenReturn('testUserId');
//   });

//   testWidgets(
//       'TutorChatRoomsPage displays loading spinner while waiting for data',
//       (WidgetTester tester) async {
//     // Arrange: Mock Firestore stream to simulate a waiting state
//     when(mockFirestore.collection('chatrooms').snapshots())
//         .thenAnswer((_) => Stream<QuerySnapshot>.empty());

//     // Act: Build TutorChatRoomsPage
//     await tester.pumpWidget(
//       MaterialApp(
//         home: TutorChatRoomsPage(),
//       ),
//     );

//     // Assert: Check for CircularProgressIndicator
//     expect(find.byType(CircularProgressIndicator), findsOneWidget);
//   });

//   testWidgets(
//       'TutorChatRoomsPage shows "No chat rooms available" when there is no data',
//       (WidgetTester tester) async {
//     // Arrange: Mock Firestore stream with no chat room documents
//     final mockSnapshot = MockQuerySnapshot();
//     when(mockSnapshot.docs).thenReturn([]);
//     when(mockFirestore.collection('chatrooms').snapshots())
//         .thenAnswer((_) => Stream.value(mockSnapshot));

//     // Act: Build TutorChatRoomsPage
//     await tester.pumpWidget(
//       MaterialApp(
//         home: TutorChatRoomsPage(),
//       ),
//     );

//     // Assert: Check for "No chat rooms available" message
//     expect(find.text("No chat rooms available"), findsOneWidget);
//   });

//   testWidgets('TutorChatRoomsPage navigates to ChatTeacherRoom on tap',
//       (WidgetTester tester) async {
//     // Arrange: Mock Firestore data with a single chat room document
//     final mockDocumentSnapshot = MockDocumentSnapshot();
//     when(mockDocumentSnapshot.id).thenReturn('chatRoomId');
//     when(mockDocumentSnapshot.data()).thenReturn({
//       'members': ['testUserId', 'otherUser']
//     });

//     final mockSnapshot = MockQuerySnapshot();
//     when(mockSnapshot.docs).thenReturn([mockDocumentSnapshot]);
//     when(mockFirestore.collection('chatrooms').snapshots())
//         .thenAnswer((_) => Stream.value(mockSnapshot));

//     // Act: Build TutorChatRoomsPage
//     await tester.pumpWidget(
//       MaterialApp(
//         home: TutorChatRoomsPage(),
//       ),
//     );

//     // Assert: Check if the chat room card is displayed
//     expect(find.text('otherUser'), findsOneWidget);

//     // Act: Tap on the chat room card
//     await tester.tap(find.text('otherUser'));
//     await tester.pumpAndSettle();

//     // Assert: Check if navigation to ChatTeacherRoom occurred
//     expect(find.byType(ChatTeacherRoom), findsOneWidget);
//   });
// }
