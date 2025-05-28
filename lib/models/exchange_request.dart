class ExchangeRequest {
  final String id;
  final String skillId;
  final String interestId;
  final String requestedUserId;
  final String requesterId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExchangeRequest({
    required this.id,
    required this.skillId,
    required this.interestId,
    required this.requestedUserId,
    required this.requesterId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExchangeRequest.fromJson(Map<String, dynamic> json, {required String id}) {
    return ExchangeRequest(
      id: id,
      skillId: (json['skill_id'] ?? '').toString(),
      interestId: (json['interest_id'] ?? '').toString(),
      requestedUserId: (json['requested_user_id'] ?? '').toString(),
      requesterId: (json['requester_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }
}
