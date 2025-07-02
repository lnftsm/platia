class AppSettings {
  final String id;
  final String language;
  final String theme;
  final bool pushNotifications;
  final bool classReminders;
  final bool membershipReminders;
  final bool announcementNotifications;
  final int reminderMinutes;
  final DateTime updatedAt;

  AppSettings({
    required this.id,
    this.language = 'tr',
    this.theme = 'light',
    this.pushNotifications = true,
    this.classReminders = true,
    this.membershipReminders = true,
    this.announcementNotifications = true,
    this.reminderMinutes = 60,
    required this.updatedAt,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      id: json['id'],
      language: json['language'] ?? 'tr',
      theme: json['theme'] ?? 'light',
      pushNotifications: json['pushNotifications'] ?? true,
      classReminders: json['classReminders'] ?? true,
      membershipReminders: json['membershipReminders'] ?? true,
      announcementNotifications: json['announcementNotifications'] ?? true,
      reminderMinutes: json['reminderMinutes'] ?? 60,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'language': language,
      'theme': theme,
      'pushNotifications': pushNotifications,
      'classReminders': classReminders,
      'membershipReminders': membershipReminders,
      'announcementNotifications': announcementNotifications,
      'reminderMinutes': reminderMinutes,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AppSettings copyWith({
    String? language,
    String? theme,
    bool? pushNotifications,
    bool? classReminders,
    bool? membershipReminders,
    bool? announcementNotifications,
    int? reminderMinutes,
  }) {
    return AppSettings(
      id: id,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      classReminders: classReminders ?? this.classReminders,
      membershipReminders: membershipReminders ?? this.membershipReminders,
      announcementNotifications:
          announcementNotifications ?? this.announcementNotifications,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      updatedAt: DateTime.now(),
    );
  }
}
