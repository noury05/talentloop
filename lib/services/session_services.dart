import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/session.dart';

class SessionServices {
  static final String baseUrl = "http://127.0.0.1:8000/api";
  static final uid = FirebaseAuth.instance.currentUser?.uid;

  // 📥 Schedule a new session
  static Future<String> scheduleSession({
    required String exchangeId,
    required int count,
    required DateTime timeScheduled,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/schedule"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "exchange_id": exchangeId,
        "count": count,
        "time_scheduled": timeScheduled.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception("Failed to schedule session");
    }
  }

  // 📋 Get all sessions for an exchange
  static Future<List<Session>> getSessions(String exchangeId) async {
    final response = await http.get(Uri.parse("$baseUrl/sessions/$exchangeId"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Session.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch sessions");
    }
  }

  // ✅ Validate a session
  static Future<void> validateSession(String sessionId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/$sessionId/validate"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to validate session");
    }
  }

  // ✅ Mark session as completed
  static Future<void> completeSession(String sessionId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/$sessionId/complete"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to mark session as completed");
    }
  }
}
