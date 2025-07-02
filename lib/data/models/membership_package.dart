class MembershipPackage {
  final String id;
  final String name;
  final String description;
  final double price;
  final int? validityDays;
  final int? classCount;
  final MembershipType type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MembershipPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.validityDays,
    this.classCount,
    required this.type,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MembershipPackage.fromJson(Map<String, dynamic> json) {
    return MembershipPackage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      validityDays: json['validityDays'],
      classCount: json['classCount'],
      type: MembershipType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'validityDays': validityDays,
      'classCount': classCount,
      'type': type.toString().split('.').last,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum MembershipType { unlimited, classPackage, monthly, yearly }
