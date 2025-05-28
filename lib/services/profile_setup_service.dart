import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ProfileSetupService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/users';

  static Future<void> updateUserProfile({
    int? avatarIndex,
    String? country,
    String? state,
    String? city,
    String? bio,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in.");
    }

    final Map<String, dynamic> updates = {};

    if (avatarIndex != null) {
      updates['avatar'] = 'assets/avatars/$avatarIndex.jpg';
    }

    // Build location properly
    if ((country != null && country.trim().isNotEmpty) ||
        (state != null && state.trim().isNotEmpty) ||
        (city != null && city.trim().isNotEmpty)) {
      final locationParts = [
        if (country != null && country.trim().isNotEmpty) country.trim(),
        if (state != null && state.trim().isNotEmpty) state.trim(),
        if (city != null && city.trim().isNotEmpty) city.trim(),
      ];
      final location = locationParts.join(', ');
      updates['location'] = location;
    }

    if (bio != null && bio.trim().isNotEmpty) {
      updates['bio'] = bio.trim();
    }

    if (updates.isEmpty) {
      throw Exception("No data to update.");
    }

    updates['updated_at'] = DateTime.now().toIso8601String();

    // Fetch Firebase ID token
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken == null) {
      throw Exception("No valid Firebase ID token found.");
    }

    // Send HTTP request to Laravel API
    final response = await http.put(
      Uri.parse('$baseUrl/$uid'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

}
