class Waitlist {
  final String id;
  final String userId;
  final String scheduleId;
  final int position;
  final DateTime joinedAt;
  final WaitlistStatus status;
  final DateTime? notifiedAt;
  final DateTime? responseDeadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Waitlist({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.position,
    required this.joinedAt,
    this.status = WaitlistStatus.waiting,
    this.notifiedAt,
    this.responseDeadline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Waitlist.fromJson(Map<String, dynamic> json) {
    return Waitlist(
      id: json['id'],
      userId: json['userId'],
      scheduleId: json['scheduleId'],
      position: json['position'],
      joinedAt: DateTime.parse(json['joinedAt']),
      status: WaitlistStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      notifiedAt: json['notifiedAt'] != null
          ? DateTime.parse(json['notifiedAt'])
          : null,
      responseDeadline: json['responseDeadline'] != null
          ? DateTime.parse(json['responseDeadline'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scheduleId': scheduleId,
      'position': position,
      'joinedAt': joinedAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'notifiedAt': notifiedAt?.toIso8601String(),
      'responseDeadline': responseDeadline?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum WaitlistStatus { waiting, notified, confirmed, expired, cancelled }
