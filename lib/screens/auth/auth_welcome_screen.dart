import 'package:flutter/material.dart';
import 'package:platia/l10n/app_localizations.dart';
import 'package:platia/constants/app_colors.dart';
import 'package:platia/config/routes/app_routes.dart';
import 'package:platia/utils/screen_utils.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenHeight -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.isSmallScreen(context) ? 24 : 32,
                vertical: 20,
              ),
              child: Column(
                children: [
                  // Top spacing - adaptive
                  SizedBox(height: isSmallScreen ? 30 : 50),

                  // Logo and Branding Section
                  _buildBrandingSection(l10n, isSmallScreen),

                  // Flexible spacing
                  SizedBox(height: isSmallScreen ? 30 : 50),

                  // Welcome Section
                  _buildWelcomeSection(l10n, isSmallScreen),

                  // Flexible spacing
                  SizedBox(height: isSmallScreen ? 50 : 70),

                  // Action Buttons Section
                  _buildActionButtons(context, l10n),

                  // Bottom spacing
                  SizedBox(height: isSmallScreen ? 20 : 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection(AppLocalizations l10n, bool isSmallScreen) {
    return Column(
      children: [
        // App Logo - adaptive size
        Container(
          width: isSmallScreen ? 100 : 120,
          height: isSmallScreen ? 100 : 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 30),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Image.asset(
            'assets/images/platia_logo.png', // Replace with your actual logo path
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),

        // App Name - adaptive size
        Text(
          l10n.appName,
          style: TextStyle(
            fontSize: isSmallScreen ? 36 : 42,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFamily: 'Poppins',
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        // Tagline - adaptive size
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            l10n.appTagline,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              color: AppColors.textSecondary,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(AppLocalizations l10n, bool isSmallScreen) {
    return Column(
      children: [
        Text(
          _getGreeting(l10n),
          style: TextStyle(
            fontSize: isSmallScreen ? 28 : 32,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'Poppins',
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            _getWelcomeMessage(l10n),
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: AppColors.textSecondary,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w300,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return Column(
      children: [
        // Login Button (Primary)
        SizedBox(
          width: double.infinity,
          height: isSmallScreen ? 50 : 56,
          child: ElevatedButton(
            onPressed: () => _navigateToLogin(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 28),
              ),
            ),
            child: Text(
              l10n.login,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        // Register Button (Secondary)
        SizedBox(
          width: double.infinity,
          height: isSmallScreen ? 50 : 56,
          child: OutlinedButton(
            onPressed: () => _navigateToRegister(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 28),
              ),
            ),
            child: Text(
              l10n.register,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 20 : 32),

        // "Don't have account" text
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              l10n.dontHaveAccount,
              style: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _navigateToRegister(context),
              child: Text(
                l10n.signUp,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    return l10n.welcome;
  }

  String _getWelcomeMessage(AppLocalizations l10n) {
    final currentHour = DateTime.now().hour;

    if (currentHour < 12) {
      return l10n.goodMorning;
    } else if (currentHour < 17) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.login);
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.register);
  }
}
