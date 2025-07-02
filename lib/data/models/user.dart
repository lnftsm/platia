import 'package:platia/data/models/user_role.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final String? profileImageUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final String? createdByAdminId;
  final bool isActive;
  final bool kvkkConsent;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.birthDate,
    this.gender,
    this.profileImageUrl,
    this.role = UserRole.member, // ← Default role
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.createdByAdminId,
    this.isActive = true,
    this.kvkkConsent = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      gender: json['gender'],
      profileImageUrl: json['profileImageUrl'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == (json['role'] ?? 'member'),
        orElse: () => UserRole.member,
      ), // ← NEW
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null, // ← NEW
      createdByAdminId: json['createdByAdminId'], // ← NEW
      isActive: json['isActive'] ?? true,
      kvkkConsent: json['kvkkConsent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate?.toIso8601String(),
      'gender': gender,
      'profileImageUrl': profileImageUrl,
      'role': role.toString().split('.').last, // ← NEW
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(), // ← NEW
      'createdByAdminId': createdByAdminId, // ← NEW
      'isActive': isActive,
      'kvkkConsent': kvkkConsent,
    };
  }

  String get fullName => '$firstName $lastName';

  // Role-based getters
  bool get isMember => role == UserRole.member;
  bool get isTrainer => role == UserRole.trainer;
  bool get isAdmin => role == UserRole.admin;
  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isStaff => role.isStaff;

  // Permission helpers
  bool get canManageUsers => role.canManageUsers;
  bool get canManageClasses => role.canManageClasses;
  bool get canViewReports => role.canViewReports;
  bool get canManagePayments => role.canManagePayments;
}
