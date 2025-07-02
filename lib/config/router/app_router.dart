import 'package:go_router/go_router.dart';
import 'package:platia/config/router/route_names.dart';
import 'package:platia/presentation/member/screens/auth/login_screen.dart';
import 'package:platia/presentation/member/screens/auth/register_screen.dart';
import 'package:platia/presentation/member/screens/auth/forgot_password_screen.dart';
import 'package:platia/presentation/member/screens/home/home_screen.dart';
import 'package:platia/presentation/member/screens/classes/class_schedule_screen.dart';
import 'package:platia/presentation/member/screens/classes/class_detail_screen.dart';
import 'package:platia/presentation/member/screens/profile/profile_screen.dart';
import 'package:platia/presentation/admin/screens/dashboard/admin_dashboard_screen.dart';
import 'package:platia/presentation/instructor/screens/home/instructor_home_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.login,
    routes: [
      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Member Routes
      GoRoute(
        path: RouteNames.memberHome,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.classes,
        builder: (context, state) => const ClassScheduleScreen(),
      ),
      GoRoute(
        path: RouteNames.classDetail,
        builder: (context, state) {
          final scheduleId = state.pathParameters['id']!;
          return ClassDetailScreen(scheduleId: scheduleId);
        },
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: RouteNames.adminHome,
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Instructor Routes
      GoRoute(
        path: '/instructor/home',
        builder: (context, state) => const InstructorHomeScreen(),
      ),
    ],
  );
}
