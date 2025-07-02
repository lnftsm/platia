class Reservation {
  final String id;
  final String userId;
  final String scheduleId;
  final ReservationStatus status;
  final DateTime reservedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool attended;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reservation({
    required this.id,
    required this.userId,
    required this.scheduleId,
    this.status = ReservationStatus.confirmed,
    required this.reservedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.attended = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      userId: json['userId'],
      scheduleId: json['scheduleId'],
      status: ReservationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      reservedAt: DateTime.parse(json['reservedAt']),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'])
          : null,
      cancellationReason: json['cancellationReason'],
      attended: json['attended'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'scheduleId': scheduleId,
      'status': status.toString().split('.').last,
      'reservedAt': reservedAt.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'attended': attended,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum ReservationStatus { confirmed, cancelled, waitlisted, noShow }
