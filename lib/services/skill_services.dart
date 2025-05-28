import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/skill_exchange.dart';
import '../models/skill.dart';
import '../models/user_skill.dart';

class SkillServices {

  static final String baseUrl = "http://127.0.0.1:8000/api";
  static final uid = FirebaseAuth.instance.currentUser?.uid;

  static Future<Skill> getSkillById(String skillId) async {
    final response = await http.get(Uri.parse('$baseUrl/skills/$skillId'));
    if (response.statusCode == 200) {
      return Skill.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load skill $skillId');
  }

  static Future<void> deleteUserSkill(String skillId) async {
    final uri = Uri.parse('$baseUrl/user_skills/$uid/$skillId');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to delete skill (status ${response.statusCode})');
    }
  }

  static Future<void> deleteUserInterest(String interestId) async {
    final uri = Uri.parse('$baseUrl/user_interests/$uid/$interestId');
    final response = await http.delete(uri);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to delete interest (status ${response.statusCode})');
    }
  }

  static Future<void> updateSessionsNeeded({
    required String exchangeId,
    required int sessionsNeeded,
  }) async {
    final uri = Uri.parse('$baseUrl/exchanges/$exchangeId');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'sessions_needed': sessionsNeeded}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update sessions needed (status ${response.statusCode})');
    }
  }

  static Future<List<SkillExchange>> getUserExchanges() async {
    final response = await http.get(Uri.parse("$baseUrl/exchanges/user/$uid"));

    if (response.statusCode != 200) {
      throw Exception("Failed to load user exchanges");
    }
    final List<dynamic> decoded = jsonDecode(response.body);
    return decoded
        .map((item) => SkillExchange.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> dropExchange(String exchangeId) async {
    final uri = Uri.parse('$baseUrl/exchanges/$exchangeId');
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status: dropped'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update sessions needed (status ${response.statusCode})');
    }
  }


  static Future<List<UserSkill>> getUserSkills() async {
    final response = await http.get(
        Uri.parse("$baseUrl/user_skills/$uid/names"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load user skills");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .cast<Map<String, dynamic>>()
          .map((m) => UserSkill.fromJson(m))
          .toList();
    }
    return [];
  }

  static Future<SkillExchange> getExchangeById(String exchangeId) async {
    final response = await http.get(Uri.parse("$baseUrl/exchanges/$exchangeId"));

    if (response.statusCode != 200) {
      throw Exception("Failed to load exchange");
    }

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    print((decoded));
    return SkillExchange.fromJson(decoded);
  }

  static Future<List<UserSkill>> getOtherUserSkills(String userId) async {
    final response = await http.get(
        Uri.parse("$baseUrl/user_skills/$userId/names"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load user skills");
    }

    final decoded = jsonDecode(response.body);

    if (decoded is List) {
      return decoded
          .cast<Map<String, dynamic>>()
          .map((m) => UserSkill.fromJson(m))
          .toList();
    }
    return [];
  }

  static Future<List<Skill>> getOtherUserInterests(String userId) async {
    final response = await http.get(
        Uri.parse("$baseUrl/user_interests/$userId/names"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load user interests");
    }
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .cast<Map<String, dynamic>>()
          .map((e) => Skill.fromJson(e))
          .toList();
    }
    return [];
  }

  static Future<List<Skill>> getUserInterests() async {
    final response = await http.get(
        Uri.parse("$baseUrl/user_interests/$uid/names"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load user interests");
    }
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .cast<Map<String, dynamic>>()
          .map((e) => Skill.fromJson(e))
          .toList();
    }
    return [];
  }
}