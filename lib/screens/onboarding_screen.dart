import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platia/l10n/app_localizations.dart';
import 'package:platia/constants/app_colors.dart';
import 'package:platia/config/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<OnboardingPage> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _initializePages();
  }

  void _initializePages() {
    final l10n = AppLocalizations.of(context)!;

    _pages = [
      OnboardingPage(
        title: l10n.onboardingYogaTitle,
        subtitle: l10n.onboardingYogaSubtitle,
        description: l10n.onboardingYogaDescription,
        icon: Icons.self_improvement,
        color: AppColors.yogaGreen,
        backgroundColor: AppColors.yogaBackground,
      ),
      OnboardingPage(
        title: l10n.onboardingPilatesTitle,
        subtitle: l10n.onboardingPilatesSubtitle,
        description: l10n.onboardingPilatesDescription,
        icon: Icons.fitness_center,
        color: AppColors.pilatesPurple,
        backgroundColor: AppColors.pilatesBackground,
      ),
      OnboardingPage(
        title: l10n.onboardingWellnessTitle,
        subtitle: l10n.onboardingWellnessSubtitle,
        description: l10n.onboardingWellnessDescription,
        icon: Icons.spa,
        color: AppColors.wellnessOrange,
        backgroundColor: AppColors.wellnessBackground,
      ),
      OnboardingPage(
        title: l10n.onboardingStartTitle,
        subtitle: l10n.onboardingStartSubtitle,
        description: l10n.onboardingStartDescription,
        icon: Icons.rocket_launch,
        color: AppColors.journeyBlue,
        backgroundColor: AppColors.journeyBackground,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _navigateToAuth(),
                  child: Text(
                    l10n.skip,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Page indicators and navigation
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            l10n.back,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      // Next/Get Started button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _navigateToAuth();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pages[_currentPage].color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? l10n.getStarted
                              : l10n.next,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [page.backgroundColor, Colors.white],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animated container
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: page.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(75),
                      border: Border.all(
                        color: page.color.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(page.icon, size: 70, color: page.color),
                  ),
                );
              },
            ),
            const SizedBox(height: 50),
            // Title
            Text(
              page.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: page.color,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Subtitle
            Text(
              page.subtitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Description
            Text(
              page.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToAuth() async {
    // Mark onboarding as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    // Navigate to authentication screen
    Navigator.pushReplacementNamed(context, AppRoutes.auth);
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}
