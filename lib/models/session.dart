class Session {
  final String sessionId;
  final String exchangeId;
  final int count;
  final DateTime scheduledAt;
  final DateTime timeScheduled;
  final String status;
  final bool validated;

  Session({
    required this.sessionId,
    required this.exchangeId,
    required this.count,
    required this.scheduledAt,
    required this.timeScheduled,
    required this.status,
    required this.validated,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: (json['session_id'] ?? '').toString(),
      exchangeId: (json['exchange_id'] ?? '').toString(),
      count: json['count'] != null ? int.tryParse(json['count'].toString()) ?? 0 : 0,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : DateTime.now(),
      timeScheduled: json['time_scheduled'] != null
          ? DateTime.parse(json['time_scheduled'])
          : DateTime.now(),
      status: (json['status'] ?? '').toString(),
      validated: json['validated'] == true || json['validated'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'exchange_id': exchangeId,
      'count': count,
      'scheduled_at': scheduledAt.toIso8601String(),
      'time_scheduled': timeScheduled.toIso8601String(),
      'status': status,
      'validated': validated,
    };
  }
}
