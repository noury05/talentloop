class Message {
  final String messageId;
  final String exchangeId;
  final String senderId;
  final String receiverId;
  final String message;
  late String status;
  final DateTime? createdAt;

  Message({
    required this.messageId,
    required this.exchangeId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json,) {
    return Message(
      messageId:   json['id'] as String? ?? '',
      exchangeId:  json['exchange_id'] as String? ?? '',
      senderId:    json['sender_id'] as String? ?? '',
      receiverId:  json['receiver_id'] as String? ?? '',
      message:     json['message'] as String? ?? '',
      status:      json['status'] as String? ?? 'pending',
      createdAt:   (json['created_at'] != null && json['created_at'].toString().isNotEmpty)
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id':   messageId,
      'exchange_id':  exchangeId,
      'sender_id':    senderId,
      'receiver_id':  receiverId,
      'message':      message,
      'status':       status,
      'created_at':   createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => toJson().toString();
}
