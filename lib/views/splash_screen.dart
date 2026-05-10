import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../helpers/themes.dart';
import '../routes/app_routes.dart';
import '../services/in_app_update_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLoginStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkLoginStatus() async {
    await InAppUpdateService.tryImmediateUpdateIfNeeded();

    // Wait for a minimum splash duration for better UX
    await Future.delayed(const Duration(milliseconds: 2000));

    try {
      // Get the AuthController instance
      final authController = Get.find<AuthController>();

      // Wait for the controller to finish checking login status
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user is logged in
      if (authController.isLoggedIn.value) {
        // User is logged in, navigate to select student screen
        Get.offAllNamed(AppRoutes.selectStudent);
      } else {
        // User is not logged in, navigate to welcome screen
        Get.offAllNamed(AppRoutes.welcome);
      }
    } catch (e) {
      // If there's any error, navigate to welcome screen as fallback
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? <Color>[
            AppTheme.darkScaffold,
            Color.alphaBlend(
              AppColors.accentOrange.withValues(alpha: 0.16),
              AppTheme.darkSurface,
            ),
            AppTheme.darkSurface,
          ]
        : <Color>[
            const Color(0xFFEFF6FF),
            const Color(0xFFFFF7ED),
            scheme.surface,
          ];

    final titleStyleColor = isDark ? Colors.white : scheme.primary;
    final subtitleColor =
        isDark ? const Color(0xFFFFF3E0) : AppColors.accentOrange;
    final progressColor =
        isDark ? Colors.white : AppColors.accentOrange;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkScaffold : scheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Image.asset(
                        'assets/images/big_logo.png',
                        height: 120,
                        width: 120,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // App name with animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        Text(
                          'XScholar ERP',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: titleStyleColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Parents App',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),

              // Loading indicator
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                        strokeWidth: 3,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
