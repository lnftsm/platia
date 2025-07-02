class Attendance {
  final String id;
  final String userId;
  final String scheduleId;
  final String reservationId;
  final DateTime checkedInAt;
  final DateTime? checkedOutAt;
  final AttendanceStatus status;
  final String? notes;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.userId,
    required this.scheduleId,
    required this.reservationId,
    required this.checkedInAt,
    this.checkedOutAt,
    this.status = AttendanceStatus.present,
    this.notes,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      userId: json['userId'],
      scheduleId: json['scheduleId'],
      reservationId: json['reservationId'],
      checkedInAt: DateTime.parse(json['checkedInAt']),
      checkedOutAt: json['checkedOutAt'] != null
          ? DateTime.parse(json['checkedOutAt'])
          : null,
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scheduleId': scheduleId,
      'reservationId': reservationId,
      'checkedInAt': checkedInAt.toIso8601String(),
      'checkedOutAt': checkedOutAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Duration? get duration {
    if (checkedOutAt != null) {
      return checkedOutAt!.difference(checkedInAt);
    }
    return null;
  }
}

enum AttendanceStatus { present, late, leftEarly, noShow }
