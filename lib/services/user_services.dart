import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserServices {

  static final String baseUrl = "http://127.0.0.1:8000/api";
  static final uid = FirebaseAuth.instance.currentUser?.uid;

  static Future<List<UserModel>> getRecommendedUsers() async {
    final response = await http.get(Uri.parse("$baseUrl/users/suggested/$uid"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => UserModel.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load users");
    }
  }

  static Future<UserModel> getThisUser() async {
    final response = await http.get(Uri.parse("$baseUrl/users/$uid"));
    if (response.statusCode == 200) {
      // Decode the JSON body into a Map
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      // Construct and return the UserModel
      return UserModel.fromJson(json);
    } else {
      throw Exception("Failed to load user");
    }
  }

  static Future<UserModel> getOtherUser(String uid) async {
    final response = await http.get(Uri.parse("$baseUrl/users/$uid"));
    if (response.statusCode == 200) {
      // Decode the JSON body into a Map
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      // Construct and return the UserModel
      return UserModel.fromJson(json);
    } else {
      throw Exception("Failed to load user");
    }
  }

}