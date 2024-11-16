import 'package:fat_app/auth/auth_provider.dart';
import 'package:fat_app/auth/auth_user.dart';
import 'package:fat_app/auth/firebase_auth_provider.dart';
import 'package:flutter/material.dart';

class AuthServices implements AuthProvider {
  final AuthProvider provider;

  const AuthServices(this.provider);

  factory AuthServices.firebase(BuildContext context) =>
      AuthServices(FirebaseAuthProvider(context: context));

  @override
  Future<void> LogOut() => provider.LogOut();

  @override
  Future<AuthUser> createUser(
          {required String email, required String password}) =>
      provider.createUser(email: email, password: password);

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({required String email, required String password}) =>
      provider.logIn(email: email, password: password);

  @override
  Future<void> sendEmailVertification() => provider.sendEmailVertification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<void> sendPasswordReset({required String toEmail}) =>
      provider.sendPasswordReset(toEmail: toEmail);
}
