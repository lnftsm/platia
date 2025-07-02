class AppConstants {
  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Reservation
  static const int cancellationHoursBeforeClass = 2;
  static const int waitlistResponseMinutes = 15;

  // Membership
  static const int membershipExpiryWarningDays = 7;
  static const int lowClassCountWarning = 2;

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Validation
  static const int minPasswordLength = 6;
  static const int phoneNumberLength = 10;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
}
