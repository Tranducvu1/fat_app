import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Base service class to handle common Firestore operations and error handling
abstract class BaseFirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BaseFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Protected getter for child classes
  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;

  /// Generic error handler with logging
  Future<T> handleError<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    try {
      return await operation();
    } catch (e) {
      print('Failed to $operationName: $e');
      throw Exception('Failed to $operationName: $e');
    }
  }

  /// Generic stream error handler
  Stream<T> handleStreamError<T>(
    Stream<T> stream,
    String operationName,
  ) {
    return stream.handleError((error) {
      print('Failed to $operationName: $error');
      throw Exception('Failed to $operationName: $error');
    });
  }
}
