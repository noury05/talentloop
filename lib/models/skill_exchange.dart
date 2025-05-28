class SkillExchange {
  final String id;
  late final String status;
  final DateTime createdAt;
  final DateTime? updatedAt; // nullable
  late final int sessionNeeded;
  final String otherUserId;
  final String yourSkillId;
  final String otherSkillId;
  late final int possibleSessionsNeeded;
  late final int sessionsDone;

  SkillExchange({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.sessionNeeded,
    required this.otherUserId,
    required this.yourSkillId,
    required this.otherSkillId,
    required this.possibleSessionsNeeded,
    required this.sessionsDone
  });

  factory SkillExchange.fromJson(Map<String, dynamic> json) {
    return SkillExchange(
      id: (json['exchange_id'] ?? '').toString(), // handle int -> String
      status: (json['status'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      sessionNeeded: json['sessions_needed'] != null
          ? int.tryParse(json['sessions_needed'].toString()) ?? 0
          : 0,
      sessionsDone: json['sessions_done'] != null
          ? int.tryParse(json['sessions_done'].toString()) ?? 0
          : 0,
      possibleSessionsNeeded: json['possible_sessions_needed'] != null
          ? int.tryParse(json['possible_sessions_needed'].toString()) ?? 0
          : 0,
      otherUserId: (json['other_user_id'] ?? '').toString(),
      yourSkillId: (json['your_skill_id'] ?? '').toString(),
      otherSkillId: (json['other_skill_id'] ?? '').toString(),
    );
  }
}
