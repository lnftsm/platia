class Campaign {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final CampaignType type;
  final double? discountPercentage;
  final double? discountAmount;
  final String? promoCode;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> applicablePackages; // package IDs
  final int? usageLimit;
  final int currentUsage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Campaign({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.type,
    this.discountPercentage,
    this.discountAmount,
    this.promoCode,
    required this.startDate,
    required this.endDate,
    this.applicablePackages = const [],
    this.usageLimit,
    this.currentUsage = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      type: CampaignType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      discountPercentage: json['discountPercentage']?.toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      promoCode: json['promoCode'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      applicablePackages: List<String>.from(json['applicablePackages'] ?? []),
      usageLimit: json['usageLimit'],
      currentUsage: json['currentUsage'] ?? 0,
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
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'discountPercentage': discountPercentage,
      'discountAmount': discountAmount,
      'promoCode': promoCode,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'applicablePackages': applicablePackages,
      'usageLimit': usageLimit,
      'currentUsage': currentUsage,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == null || currentUsage < usageLimit!);
  }

  double calculateDiscount(double originalPrice) {
    if (!isValid) return 0;

    if (discountPercentage != null) {
      return originalPrice * (discountPercentage! / 100);
    } else if (discountAmount != null) {
      return discountAmount!;
    }
    return 0;
  }
}

enum CampaignType { percentage, fixedAmount, firstTime, seasonal }
