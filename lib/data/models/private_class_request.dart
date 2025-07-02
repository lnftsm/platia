class PrivateClassRequest {
  final String id;
  final String userId;
  final String? instructorId;
  final DateTime requestedDate;
  final String requestedTime;
  final String? notes;
  final double? price;
  final PrivateClassStatus status;
  final String? adminNotes;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  PrivateClassRequest({
    required this.id,
    required this.userId,
    this.instructorId,
    required this.requestedDate,
    required this.requestedTime,
    this.notes,
    this.price,
    this.status = PrivateClassStatus.pending,
    this.adminNotes,
    this.approvedAt,
    this.rejectedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PrivateClassRequest.fromJson(Map<String, dynamic> json) {
    return PrivateClassRequest(
      id: json['id'],
      userId: json['userId'],
      instructorId: json['instructorId'],
      requestedDate: DateTime.parse(json['requestedDate']),
      requestedTime: json['requestedTime'],
      notes: json['notes'],
      price: json['price']?.toDouble(),
      status: PrivateClassStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      adminNotes: json['adminNotes'],
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      rejectedAt: json['rejectedAt'] != null
          ? DateTime.parse(json['rejectedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'instructorId': instructorId,
      'requestedDate': requestedDate.toIso8601String(),
      'requestedTime': requestedTime,
      'notes': notes,
      'price': price,
      'status': status.toString().split('.').last,
      'adminNotes': adminNotes,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectedAt': rejectedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum PrivateClassStatus { pending, approved, rejected, completed, cancelled }
