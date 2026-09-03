import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      icon: Icons.shield_rounded,
      title: 'Grandmaster Aesthetic',
      subtitle: 'Experience tournament-grade chess with fluid vector pieces, curated board themes, and millisecond digital clocks.',
      badge: 'PREMIUM CHESS',
    ),
    const OnboardingSlide(
      icon: Icons.psychology_rounded,
      title: 'Advanced AI Sparring',
      subtitle: 'Test your tactical mastery against precision AI engines tuned from novice to International Grandmaster Elo ratings.',
      badge: 'TACTICAL DEPTH',
    ),
    const OnboardingSlide(
      icon: Icons.public_rounded,
      title: 'Global Rated Arena',
      subtitle: 'Climb the worldwide leaderboards, compete in Bullet, Blitz, and Rapid, and analyze every game with move-by-move evaluation.',
      badge: 'WORLDWIDE ELO',
    ),
  ];

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const HomeScreen(),
        transitionsBuilder: (context, anim1, anim2, child) =>
            FadeTransition(opacity: anim1, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Top Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'SKIP',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMutedDark,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Page Carousel
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _slides.length,
                  itemBuilder: (context, idx) {
                    final slide = _slides[idx];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Luxury Emblem Card
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.goldAccent.withValues(alpha: 0.25),
                                AppColors.darkSurface,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.goldAccent.withValues(alpha: 0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldAccent.withValues(alpha: 0.2),
                                blurRadius: 32,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            slide.icon,
                            size: 64,
                            color: AppColors.goldAccent,
                          ),
                        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 36),

                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.goldAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.goldAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            slide.badge,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.goldLight,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondaryDark,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.goldAccent
                          : AppColors.darkBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Bottom Actions
              Row(
                children: [
                  if (_currentPage > 0) ...[
                    IconButton.outlined(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _finishOnboarding();
                        }
                      },
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'Get Started'
                            : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                child: Text(
                  'Have an account? Sign In',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.goldAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });
}
