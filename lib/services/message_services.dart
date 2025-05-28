import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class MessageServices {
  static final String baseUrl = "http://127.0.0.1:8000/api";
  static final uid = FirebaseAuth.instance.currentUser?.uid;

  // Fetch messages for a specific exchange ID
  static Future<List<Message>> getMessages(String exchangeId) async {
    final uri = Uri.parse('$baseUrl/messages/exchange/$exchangeId');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch messages');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Message.fromJson(json)).toList();
  }

  // Send a new message
  static Future<void> sendMessage({
    required String exchangeId,
    required String receiverId,
    required String message,
  }) async {
    final uri = Uri.parse('$baseUrl/messages');
    final body = jsonEncode({
      'exchange_id': exchangeId,
      'sender_id': MessageServices.uid,
      'receiver_id': receiverId,
      'message': message,
      'status': 'received',
    });
    print(body);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  // Update message status
  static Future<void> updateMessageStatus(String messageId, String status) async {
    final uri = Uri.parse('$baseUrl/messages/$messageId');
    final body = jsonEncode({'status': status});
    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update message status: ${response.body}');
    }
  }

  // Delete a message
  static Future<void> deleteMessage(String messageId) async {
    final uri = Uri.parse('$baseUrl/messages/$messageId');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete message: ${response.body}');
    }
  }

  // Get all messages for the current user (optional feature)
  static Future<List<Message>> getUserMessages() async {
    final uri = Uri.parse('$baseUrl/messages/user/$uid');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user messages');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded.isEmpty) {
      return [];
    }
    return decoded.entries
        .map((entry) => Message.fromJson(entry.value))
        .toList();
  }

  static Future<Message?> getLastMessage(String exchangeId) async {
    final uri = Uri.parse('$baseUrl/messages/last/$exchangeId');
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch last message');
    }
    if (response.body == "null") return null; // No message found
    final data = jsonDecode(response.body);
    return Message.fromJson(data,); // optional: supply ID if needed
  }

  static Future<int> getUnreadReceivedMessageCount(String exchangeId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final uri = Uri.parse('$baseUrl/messages/unread/count/$uid/$exchangeId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch unread message count');
    }

    final data = jsonDecode(response.body);
    return data['unread_received_count'] ?? 0;
  }

}
