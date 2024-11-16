import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fat_app/service/user_service.dart';
import 'package:fat_app/view/updateInformationPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fat_app/Model/UserModel.dart' as AppUser;
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserService extends Mock implements UserService {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late FakeFirebaseFirestore fakeFirestore;
  late MockUserService mockUserService;
  late MockImagePicker mockImagePicker;
  late MockFirebaseStorage mockStorage;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    fakeFirestore = FakeFirebaseFirestore();
    mockUserService = MockUserService();
    mockImagePicker = MockImagePicker();
    mockStorage = MockFirebaseStorage();

    // Setup mock behavior
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');
  });

  Future<void> setupUserData() async {
    await fakeFirestore.collection('Users').doc('test-user-id').set({
      'username': 'Test User',
      'userClass': 'Class A',
      'position': 'Ward 1, District 1, Đà Nẵng, 123 Street',
      'profileImage': 'https://example.com/image.jpg'
    });
  }

  testWidgets('UpdateInformationPage loads and displays user data',
      (WidgetTester tester) async {
    await setupUserData();

    await tester.pumpWidget(MaterialApp(
      home: UpdateInformationPage(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Class A'), findsOneWidget);
  });

  testWidgets('Form validation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: UpdateInformationPage(),
    ));

    // Try to submit empty form
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your first name'), findsOneWidget);
    expect(find.text('Please enter your class'), findsOneWidget);
  });

  testWidgets('District selection updates ward dropdown',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: UpdateInformationPage(),
    ));
    await tester.pumpAndSettle();

    // Open district dropdown
    await tester.tap(find.text('Select District'));
    await tester.pumpAndSettle();

    // Select a district
    await tester.tap(find.text('Hải Châu').last);
    await tester.pumpAndSettle();

    // Verify ward dropdown is now visible
    expect(find.text('Select Ward'), findsOneWidget);
  });

  testWidgets('Image picker functionality works', (WidgetTester tester) async {
    when(() => mockImagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        )).thenAnswer((invocation) async => XFile('test_image.jpg'));

    await tester.pumpWidget(MaterialApp(
      home: UpdateInformationPage(),
    ));
    await tester.pumpAndSettle();

    // Tap the camera icon
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    // Verify image was uploaded
  });

  testWidgets('Form submission works with valid data',
      (WidgetTester tester) async {
    when(() => mockUserService.checkUserExits('test-user-id'))
        .thenAnswer((_) async => true);
    when(() =>
            mockUserService.updateUser(any<String>(), any<AppUser.UserModel>()))
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(MaterialApp(
      home: UpdateInformationPage(),
    ));
    await tester.pumpAndSettle();

    // Fill in the form
    await tester.enterText(find.byType(TextFormField).first, 'New Username');
    await tester.enterText(find.byType(TextFormField).at(1), 'New Class');

    // Select district and ward
    await tester.tap(find.text('Select District'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hải Châu').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select Ward'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hòa Cường Bắc').last);
    await tester.pumpAndSettle();

    // Enter address
    await tester.enterText(find.byType(TextFormField).last, '123 New Street');

    // Submit form
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify user service was called
    verify(() =>
            mockUserService.updateUser(any<String>(), any<AppUser.UserModel>()))
        .called(1);
    expect(find.text('Information updated successfully'), findsOneWidget);
  });

  testWidgets('Error handling during image upload',
      (WidgetTester tester) async {
    when(() => mockStorage.ref().child(any<String>()))
        .thenThrow(Exception('Upload failed'));

    await tester.pumpWidget(MaterialApp(
      home: UpdateInformationPage(),
    ));
    await tester.pumpAndSettle();

    // Try to upload image
    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pumpAndSettle();

    expect(find.text('Error uploading image'), findsOneWidget);
  });

  // test('UserInformation model creation works correctly', () {
  //   final userInfo = AppUser.UserInformation(
  //       userName: 'Test User',
  //       userClass: 'Class A',
  //       position: 'Ward 1, District 1, Đà Nẵng, 123 Street',
  //       profileImage: 'https://example.com/image.jpg');

  //   expect(userInfo.userName, 'Test User');
  //   expect(userInfo.userClass, 'Class A');
  //   expect(userInfo.position, 'Ward 1, District 1, Đà Nẵng, 123 Street');
  //   expect(userInfo.profileImage, 'https://example.com/image.jpg');
  // });
}
