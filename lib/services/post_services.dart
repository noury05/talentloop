import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostServices {

  static final String baseUrl = "http://127.0.0.1:8000/api";
  static final uid = FirebaseAuth.instance.currentUser?.uid;

  static Future<List<Post>> getSuggestedPosts() async {
    final response = await http.get(
        Uri.parse('$baseUrl/posts/others/$uid')
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load suggested posts');
  }

  static Future<List<Post>> getPostsBySkill(String? skillId) async {
    final response = await http.get(Uri.parse("$baseUrl/posts/skill/$skillId"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load posts for skill $skillId");
    }
    final decoded = jsonDecode(response.body);
    List<dynamic> rawList;
    if (decoded is List) {
      // API returned a JSON array
      rawList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      // API returned a JSON object: turn its values into a List
      rawList = decoded.values.toList();
    } else {
      // totally unexpected format
      return [];
    }
    return rawList
      .map((e) => Post.fromJson(e as Map<String, dynamic>))
      .toList();
  }

  static Future<List<Post>> getUserPosts() async {
    final response = await http.get(Uri.parse("$baseUrl/posts/user/all/$uid"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load user posts");
    }
    final decoded = jsonDecode(response.body);
    List<dynamic> rawList;
    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      rawList = decoded.values.toList();
    } else {
      return [];
    }
    return rawList
        .cast<Map<String, dynamic>>()
        .map((m) => Post.fromJson(m))
        .toList();
  }

  static Future<List<Post>> getOtherUserPosts(String userId) async {
    final response = await http.get(Uri.parse("$baseUrl/posts/user/all/$userId"));
    if (response.statusCode != 200) {
      throw Exception("Failed to load user posts");
    }
    final decoded = jsonDecode(response.body);
    List<dynamic> rawList;
    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map<String, dynamic>) {
      rawList = decoded.values.toList();
    } else {
      return [];
    }
    return rawList
        .cast<Map<String, dynamic>>()
        .map((m) => Post.fromJson(m))
        .toList();
  }

  static Future<void> deletePost(String postId) async {
    final uri = Uri.parse('$baseUrl/posts/$postId');
    final response = await http.delete(uri);

    if (response.statusCode == 200 || response.statusCode == 204) {
      // success — nothing to return
      return;
    } else {
      // throw with server message if available
      String msg;
      try {
        final decoded = jsonDecode(response.body);
        msg = decoded['message'] ?? response.body;
      } catch (_) {
        msg = response.body;
      }
      throw Exception('Failed to delete post: $msg');
    }
  }

  static Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    final uri  = Uri.parse('$baseUrl/posts/$postId');
    final body = jsonEncode(data);

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    String msg;
    try {
      final decoded = jsonDecode(response.body);
      msg = decoded['message'] ?? response.body;
    } catch (_) {
      msg = response.body;
    }
    throw Exception('Failed to update post: $msg');
  }

}