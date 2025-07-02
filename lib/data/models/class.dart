import 'package:platia/data/models/studio.dart';

class Class {
  // Renamed from PilatesClass
  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final int maxCapacity;
  final ClassDifficulty
  difficulty; // supported difficulties: beginner, intermediate, advanced
  final ClassType type; // supported class types: yoga, pilates, meditation
  final ClassCategory
  category; // supported categories: yoga, pilates, meditation
  final StudioType
  requiredStudioType; // supported studio types: yoga, pilates, meditation
  final List<String> equipmentRequired;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Class({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.maxCapacity,
    required this.difficulty,
    required this.type,
    required this.category,
    required this.requiredStudioType,
    this.equipmentRequired = const [],
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      durationMinutes: json['durationMinutes'],
      maxCapacity: json['maxCapacity'],
      difficulty: ClassDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == json['difficulty'],
      ),
      type: ClassType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      category: ClassCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      requiredStudioType: StudioType.values.firstWhere(
        (e) => e.toString().split('.').last == json['requiredStudioType'],
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
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'requiredStudioType': requiredStudioType.toString().split('.').last,
      'equipmentRequired': equipmentRequired,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get isPilates => category == ClassCategory.pilates;
  bool get isYoga => category == ClassCategory.yoga;
  bool get isMeditation => category == ClassCategory.meditation;
}

enum ClassType {
  // Pilates
  pilatesMat,
  pilatesReformer,
  pilatesChair,
  pilatesCadillac,
  pilatesBarrel,

  // Yoga
  hathaYoga,
  vinyasaYoga,
  ashtangaYoga,
  yinYoga,
  restorative,
  hotYoga,
  powerYoga,
  kundalini,

  // Wellness & Meditation
  meditation,
  breathwork,
  mindfulness,

  // Workshops & Specialized
  workshop,
  retreat,
  privateSession,
}

enum ClassCategory { pilates, yoga, meditation, workshop, wellness }

enum ClassDifficulty { beginner, intermediate, advanced }
