import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/exchange_request.dart';

class RequestServices {

  static final String baseUrl = "http://127.0.0.1:8000/api";
  static final uid = FirebaseAuth.instance.currentUser?.uid;

  static Future<void> addRequest({
    required String requestedUserId,
    required String skillId,
    required String interestId,
    String? status,
  }) async {
    final uri = Uri.parse('$baseUrl/requests');
    final body = jsonEncode({
      'requester_id': uid,
      'requested_user_id': requestedUserId,
      'skill_id': skillId,
      'interest_id': interestId,
      if (status != null) 'status': status,
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
      throw Exception('Failed to add request: $errorMsg');
    }
  }

  static Future<List<ExchangeRequest>> getMyExchangeRequests() async {
    final response = await http.get(Uri.parse('$baseUrl/requests/requester/$uid'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch sent requests');
    }
    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic> || decoded.isEmpty) {
      return [];
    }
    return decoded.entries
        .map((entry) => ExchangeRequest.fromJson(entry.value, id: entry.key))
        .toList();
  }

  static Future<List<ExchangeRequest>> getRequestsToMe() async {
    final response = await http.get(Uri.parse('$baseUrl/requests/requested/$uid'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch incoming requests');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded.isEmpty) {
      return [];
    }
    return decoded.entries
        .map((entry) => ExchangeRequest.fromJson(entry.value, id: entry.key))
        .toList();
  }

  static Future<void> deleteRequest(String requestId) async {
    final uri = Uri.parse('$baseUrl/requests/$requestId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      String errorMsg;
      try {
        final decoded = jsonDecode(response.body);
        errorMsg = decoded['message'] ?? response.body;
      } catch (_) {
        errorMsg = response.body;
      }
      throw Exception('Failed to delete request: $errorMsg');
    }
  }

  static Future<void> updateRequestStatus(
      String newStatus, ExchangeRequest request) async {
    final uri = Uri.parse('$baseUrl/requests/${request.id}');
    final body = jsonEncode({'status': newStatus});

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      // Create exchange if request is accepted
      if (newStatus == 'accepted') {
        final exchangeUri = Uri.parse('$baseUrl/exchanges');
        final exchangeBody = jsonEncode({
          'user1_id': request.requesterId,
          'user2_id': request.requestedUserId,
          'skill1_id': request.skillId,
          'skill2_id': request.interestId,
          'status': 'ongoing',
        });

        final exchangeResponse = await http.post(
          exchangeUri,
          headers: {'Content-Type': 'application/json'},
          body: exchangeBody,
        );

        if (exchangeResponse.statusCode != 200 && exchangeResponse.statusCode != 201) {
          String errorMsg;
          try {
            final decoded = jsonDecode(exchangeResponse.body);
            errorMsg = decoded['error'] ?? decoded['message'] ?? exchangeResponse.body;
          } catch (_) {
            errorMsg = exchangeResponse.body;
          }
          throw Exception('Request updated, but failed to create exchange: $errorMsg');
        }
      }
      return;
    } else {
      String errorMsg;
      try {
        final decoded = jsonDecode(response.body);
        errorMsg = decoded['message'] ?? response.body;
      } catch (_) {
        errorMsg = response.body;
      }
      throw Exception('Failed to update request: $errorMsg');
    }
  }



}