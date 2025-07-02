import 'package:platia/data/models/class.dart';

class Instructor {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String? profileImageUrl;
  final String biography;
  final List<String>
  specializations; // Keep existing for backwards compatibility
  final List<String> certifications; // List of certifications
  final List<ClassCategory>
  specialties; // List of specialties (e.g., yoga, pilates, meditation)
  final int experienceYears;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Instructor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.profileImageUrl,
    required this.biography,
    this.specializations = const [],
    this.certifications = const [],
    this.specialties = const [],
    required this.experienceYears,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
      biography: json['biography'],
      specializations: List<String>.from(json['specializations'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      specialties:
          (json['specialties'] as List?)
              ?.map(
                (s) => ClassCategory.values.firstWhere(
                  (e) => e.toString().split('.').last == s,
                ),
              )
              .toList() ??
          [], // ← NEW
      experienceYears: json['experienceYears'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'biography': biography,
      'specializations': specializations,
      'certifications': certifications,
      'specialties': specialties
          .map((s) => s.toString().split('.').last)
          .toList(), // ← NEW
      'experienceYears': experienceYears,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';

  bool get canTeachPilates => specialties.contains(ClassCategory.pilates);
  bool get canTeachYoga => specialties.contains(ClassCategory.yoga);
  bool get canTeachMeditation => specialties.contains(ClassCategory.meditation);
}
