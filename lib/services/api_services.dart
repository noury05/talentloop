import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import '../models/search_result.dart';
import '../models/user_model.dart';

class ApiServices {

  static final String baseUrl = "http://127.0.0.1:8000/api";
  static final uid = FirebaseAuth.instance.currentUser?.uid;

  static Future<SearchResult> search(String query) async {
    final uri = Uri.parse("$baseUrl/search").replace(queryParameters: {
      'query': query,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception("Search failed: ${response.statusCode}");
    }
    final Map<String, dynamic> decoded = jsonDecode(response.body);
    // —— POSTS ——
    final postsRaw = decoded['posts'];
    List<Post> posts = [];
    if (postsRaw is List) {
      // The backend returned an array of post‑objects
      posts = postsRaw
          .cast<Map<String, dynamic>>()
          .map((json) => Post.fromJson(json))
          .toList();
    } else if (postsRaw is Map<String, dynamic>) {
      // Firebase‑style map of id→data
      posts = postsRaw.entries
          .map((e) => Post.fromJson({
        ...e.value as Map<String, dynamic>,
        'post_id': e.key,
      }))
          .toList();
    }
    // —— USERS ——
    final usersRaw = decoded['users'];
    List<UserModel> users = [];
    if (usersRaw is List) {
      users = usersRaw
          .cast<Map<String, dynamic>>()
          .map((json) => UserModel.fromJson(json))
          .toList();
    } else if (usersRaw is Map<String, dynamic>) {
      users = usersRaw.entries
          .map((e) => UserModel.fromJson({
        ...e.value as Map<String, dynamic>,
        'uid': e.key,
      }))
          .toList();
    }
    return SearchResult(posts: posts, users: users);
  }

  static Future<void> addReport({
    required String reportedUserId,
    required String reason,
  }) async {
    final uri = Uri.parse('$baseUrl/reports');

    final body = jsonEncode({
      'reported_by_id': uid,
      'reported_user_id': reportedUserId,
      'reason': reason,
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      String errorMsg;
      try {
        final decoded = jsonDecode(response.body);
        errorMsg = decoded['message'] ?? response.body;
      } catch (_) {
        errorMsg = response.body;
      }
      throw Exception('Failed to add report: $errorMsg');
    }
  }




}
