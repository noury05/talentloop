
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final http.Client _client = http.Client();

  /// Registers a user using Firebase Authentication and communicates with Laravel backend.
  Future<String> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // 1. Firebase registration.
    final userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    // 2. Set the display name.
    await userCredential.user?.updateDisplayName(fullName);

    // 3. Get Firebase token.
    final idToken = await userCredential.user!.getIdToken();

    // 4. Call your Laravel endpoint.
    final response = await _client.post(
      Uri.parse('http://127.0.0.1:8000/api/firebase-login'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'firebase_uid': userCredential.user!.uid,
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return 'success';
    } else {
      throw Exception('Laravel registration failed: ${response.body}');
    }
  }


  /// Logs in a user using Firebase Authentication and communicates with Laravel backend.
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final idToken = await userCredential.user!.getIdToken();

      final response = await _client.post(
        Uri.parse('http://127.0.0.1:8000/api/firebase-login'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'firebase_uid': userCredential.user!.uid,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return 'success';
      } else if (response.statusCode == 401) {
        return 'Invalid credentials or user not registered in the backend.';
      } else {
        return 'Server error: ${response.statusCode}\n${response.body}';
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        default:
          return 'Authentication error: ${e.message}';
      }
    } catch (e) {
      return 'Unexpected error: ${e.toString()}';
    }
  }

}
