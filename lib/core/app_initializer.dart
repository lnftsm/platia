import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:platia/constants/app_colors.dart';
import 'package:platia/config/routes/app_routes.dart';
import 'package:platia/providers/auth_provider.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Minimum loading time for smooth UX
    // This is to ensure the splash screen is visible for at least 1.5 seconds
    // This is a common practice to avoid flickering on app start
    // Minimum yükleme süresi, kullanıcı deneyimini iyileştirmek için
    // Bu, splash ekranının en az 1.5 saniye boyunca görünür olmasını sağlamak içindir
    // Bu, uygulama başlangıcında titreme olmamasını sağlamak için yaygın bir uygulamadır
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Check onboarding status
    // Onboarding durumunu kontrol et
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    // Route based on auth state and onboarding status
    // Auth durumu ve onboarding durumuna göre yönlendirme yap
    _handleNavigation(authProvider.status, hasSeenOnboarding);

    // Listen for future auth state changes
    // Gelecekteki auth durumu değişikliklerini dinle
    authProvider.addListener(() {
      if (mounted) {
        _handleAuthStateChange(authProvider.status, hasSeenOnboarding);
      }
    });
  }

  void _handleNavigation(AuthStatus authStatus, bool hasSeenOnboarding) {
    // Navigate based on auth status and onboarding completion
    // Auth durumu ve onboarding tamamlanmasına göre yönlendirme yap
    switch (authStatus) {
      // If initial, do nothing and wait for auth state change
      // Başlangıçta, hiçbir şey yapma ve auth durumu değişikliğini bekle
      case AuthStatus.initial:
        break;

      // If authenticated, navigate to home
      // Kimlik doğrulaması yapılmışsa, ana sayfaya yönlendir
      case AuthStatus.authenticated:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;

      // If unauthenticated, navigate to auth or splash based on onboarding status
      // Kimlik doğrulaması yapılmamışsa, onboarding durumuna göre auth veya splash yönlendir
      // If has seen onboarding, go to auth page
      // Onboarding'i görmüşse, auth sayfasına git
      case AuthStatus.unauthenticated:
        if (hasSeenOnboarding) {
          Navigator.pushReplacementNamed(context, AppRoutes.auth);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.splash);
        }
        break;

      // If loading, do nothing and wait for auth state change
      // Yükleniyorsa, hiçbir şey yapma ve auth durumu değişikliğini bekle
      // This is to ensure the splash screen remains visible during loading
      // Bu, yükleme sırasında splash ekranının görünür kalmasını sağlamak içindir
      case AuthStatus.loading:
        break;
    }
  }

  void _handleAuthStateChange(AuthStatus authStatus, bool hasSeenOnboarding) {
    switch (authStatus) {
      case AuthStatus.authenticated:
        if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.home,
            (route) => false,
          );
        }
        break;

      case AuthStatus.unauthenticated:
        if (ModalRoute.of(context)?.settings.name != AppRoutes.auth &&
            ModalRoute.of(context)?.settings.name != AppRoutes.login &&
            ModalRoute.of(context)?.settings.name != AppRoutes.register) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.auth,
            (route) => false,
          );
        }
        break;

      case AuthStatus.initial:
      case AuthStatus.loading:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // child: Image.asset(
                  //   'assets/images/platia_logo.png',
                  //   fit: BoxFit.cover,
                  // ),
                  child: const Icon(
                    Icons.self_improvement,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 24),

                // App name
                const Text(
                  'Platia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),

                // Status text
                Text(
                  _getStatusText(authProvider.status),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(AuthStatus status) {
    switch (status) {
      case AuthStatus.initial:
        return 'Başlatılıyor...';
      case AuthStatus.loading:
        return 'Yükleniyor...';
      case AuthStatus.authenticated:
        return 'Hoş geldiniz!';
      case AuthStatus.unauthenticated:
        return 'Giriş yapın...';
    }
  }
}
