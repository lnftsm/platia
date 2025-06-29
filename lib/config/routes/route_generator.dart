import 'package:flutter/material.dart';
import 'package:platia/constants/app_colors.dart';
import 'package:platia/l10n/app_localizations.dart';
import 'package:platia/screens/auth/auth_welcome_screen.dart';
import 'package:platia/screens/auth/forgot_password_screen.dart';
import 'package:platia/screens/auth/login_screen.dart';
import 'package:platia/screens/auth/register_screen.dart';
import 'package:platia/screens/home/home_screen.dart';
import 'package:platia/screens/onboarding_screen.dart';
import 'package:platia/screens/splash_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Onboarding flow
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      // Authentication flow
      case AppRoutes.auth:
        return MaterialPageRoute(
          builder: (_) => const AuthWelcomeScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );

      // Main app routes
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Profile'),
          settings: settings,
        );

      case AppRoutes.classes:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Classes'),
          settings: settings,
        );

      case AppRoutes.bookings:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Bookings'),
          settings: settings,
        );

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Settings'),
          settings: settings,
        );

      case AppRoutes.notifications:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: 'Notifications'),
          settings: settings,
        );

      // Default case
      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (context) => ErrorScreen(routeName: routeName),
      settings: RouteSettings(name: '/error'),
    );
  }
}

// ===== ERROR SCREEN =====
class ErrorScreen extends StatelessWidget {
  final String? routeName;

  const ErrorScreen({super.key, this.routeName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.error),
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 32),

              // Error Title
              Text(
                l10n.pageNotFound,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error Description
              Text(
                l10n.pageNotFoundDescription,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              // Route Info (for debugging)
              if (routeName != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Route: $routeName',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Action Buttons
              Column(
                children: [
                  // Go Home Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.home,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: Text(l10n.goHome),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Go Back Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.auth,
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.back),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== PLACEHOLDER SCREEN =====
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              Text(
                '$title Screen',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Geri',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
