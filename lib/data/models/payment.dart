class Payment {
  final String id;
  final String userId;
  final String? membershipId;
  final String? privateClassId;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? transactionId;
  final String? description;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.userId,
    this.membershipId,
    this.privateClassId,
    required this.amount,
    this.currency = 'TRY',
    required this.method,
    this.status = PaymentStatus.pending,
    this.transactionId,
    this.description,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      userId: json['userId'],
      membershipId: json['membershipId'],
      privateClassId: json['privateClassId'],
      amount: json['amount'].toDouble(),
      currency: json['currency'] ?? 'TRY',
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['method'],
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      transactionId: json['transactionId'],
      description: json['description'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'membershipId': membershipId,
      'privateClassId': privateClassId,
      'amount': amount,
      'currency': currency,
      'method': method.toString().split('.').last,
      'status': status.toString().split('.').last,
      'transactionId': transactionId,
      'description': description,
      'paidAt': paidAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum PaymentMethod { creditCard, bankTransfer, cash, iyzico, paytr }

enum PaymentStatus { pending, completed, failed, refunded, cancelled }
