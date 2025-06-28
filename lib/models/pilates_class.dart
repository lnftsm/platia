class PilatesClass {
  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final int maxCapacity;
  final ClassDifficulty difficulty;
  final List<String> equipmentRequired;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PilatesClass({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.maxCapacity,
    required this.difficulty,
    this.equipmentRequired = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PilatesClass.fromJson(Map<String, dynamic> json) {
    return PilatesClass(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      durationMinutes: json['durationMinutes'],
      maxCapacity: json['maxCapacity'],
      difficulty: ClassDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      equipmentRequired: List<String>.from(json['equipmentRequired'] ?? []),
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
      'durationMinutes': durationMinutes,
      'maxCapacity': maxCapacity,
      'difficulty': difficulty.toString().split('.').last,
      'equipmentRequired': equipmentRequired,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

enum ClassDifficulty { beginner, intermediate, advanced, allLevels }
