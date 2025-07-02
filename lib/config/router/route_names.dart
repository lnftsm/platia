class RouteNames {
  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Member Routes
  static const String memberHome = '/member/home';
  static const String classes = '/member/classes';
  static const String classDetail = '/member/class/:id';
  static const String classFilter = '/member/classes/filter';
  static const String profile = '/member/profile';
  static const String editProfile = '/member/profile/edit';
  static const String settings = '/member/settings';
  static const String membership = '/member/membership';
  static const String membershipPackages = '/member/membership/packages';
  static const String paymentHistory = '/member/payments';
  static const String myReservations = '/member/reservations';
  static const String attendanceHistory = '/member/attendance';
  static const String announcements = '/member/announcements';
  static const String announcementDetail = '/member/announcement/:id';
  static const String faq = '/member/faq';
  static const String messages = '/member/messages';
  static const String chat = '/member/chat/:id';
  static const String notifications = '/member/notifications';

  // Admin Routes
  static const String adminHome = '/admin/home';
  static const String userManagement = '/admin/users';
  static const String userDetail = '/admin/user/:id';
  static const String userEdit = '/admin/user/:id/edit';
  static const String classManagement = '/admin/classes';
  static const String scheduleManagement = '/admin/schedules';
  static const String instructorManagement = '/admin/instructors';
  static const String studioManagement = '/admin/studios';
  static const String membershipManagement = '/admin/memberships';
  static const String paymentManagement = '/admin/payments';
  static const String financialReports = '/admin/reports';
  static const String announcementManagement = '/admin/announcements';
  static const String campaignManagement = '/admin/campaigns';
  static const String notificationSender = '/admin/notifications/send';
}
