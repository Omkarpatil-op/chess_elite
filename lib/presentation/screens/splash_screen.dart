import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await ServiceLocator.init();
    if (!mounted) return;

    _navTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim1, anim2) => const HomeScreen(),
          transitionsBuilder: (context, anim1, anim2, child) =>
              FadeTransition(opacity: anim1, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Grandmaster Knight Emblem
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppColors.goldLight, AppColors.goldAccent, Color(0xFF8C6D1F)],
                  center: Alignment(-0.2, -0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldAccent.withValues(alpha: 0.35),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.shield_rounded,
                  color: Color(0xFF0A0D14),
                  size: 54,
                ),
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 28),

            // Title
            Text(
              'CHESS ELITE',
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.textPrimaryDark,
                letterSpacing: 4.0,
                fontWeight: FontWeight.w900,
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
            const SizedBox(height: 8),

            // Subtitle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.goldAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.3)),
              ),
              child: Text(
                'GRANDMASTER EDITION',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.goldLight,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            const SizedBox(height: 48),

            // Minimalist luxury loader
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldAccent),
              ),
            ).animate().fadeIn(delay: 450.ms),
          ],
        ),
      ),
    );
  }
}
