enum UserRole {
  // Member - Just a regular user, no special permissions
  // Üye - Sadece normal bir kullanıcı, özel izinleri yok
  member,
  // Trainer - Created by admin, can manage classes and view reports
  // Eğitmen - Admin tarafından oluşturulan, dersleri yönetebilir ve raporları görüntüleyebilir
  trainer,
  // Admin - Created by super admin, can manage users and view reports
  // Admin - Süper admin tarafından oluşturulan, kullanıcıları yönetebilir ve raporları görüntüleyebilir
  admin,
  // Super Admin - Created during development/setup, can manage everything
  // Süper Admin - Geliştirme/kurulum sırasında oluşturulan, her şeyi yönetebilir
  superAdmin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.member:
        return 'Üye';
      case UserRole.trainer:
        return 'Eğitmen';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Süper Admin';
    }
  }

  bool get canManageUsers =>
      this == UserRole.admin || this == UserRole.superAdmin;
  bool get canManageClasses =>
      this == UserRole.admin ||
      this == UserRole.superAdmin ||
      this == UserRole.trainer;
  bool get canViewReports =>
      this == UserRole.admin || this == UserRole.superAdmin;
  bool get canManagePayments =>
      this == UserRole.admin || this == UserRole.superAdmin;
  bool get isStaff =>
      this == UserRole.trainer ||
      this == UserRole.admin ||
      this == UserRole.superAdmin;
}
