class Studio {
  final String id;
  final String name;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? phoneNumber;
  final String? email;
  final List<String> imageUrls;
  final StudioType
  type; // Supported types: yoga, pilates, meditation, multi-purpose
  final List<String>
  availableEquipment; // Equipment available in the studio (e.g., mats, weights, etc.)
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Studio({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.email,
    this.imageUrls = const [],
    required this.type, // ← NEW
    this.availableEquipment = const [], // ← NEW
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      type: StudioType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      availableEquipment: List<String>.from(json['availableEquipment'] ?? []),
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
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'email': email,
      'imageUrls': imageUrls,
      'type': type.toString().split('.').last,
      'availableEquipment': availableEquipment,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get canHostPilates =>
      type == StudioType.pilatesStudio || type == StudioType.multiPurpose;
  bool get canHostYoga =>
      type == StudioType.yogaStudio || type == StudioType.multiPurpose;
  bool get canHostMeditation =>
      type == StudioType.meditationRoom || type == StudioType.multiPurpose;
}

enum StudioType {
  pilatesStudio, // Reformer machines, specialized equipment
  yogaStudio, // Open space, mats, blocks, bolsters
  meditationRoom, // Quiet, cushions, minimal equipment
  multiPurpose, // Flexible space for both
  outdoor, // For outdoor classes
}
