import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../select_student/select_student_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.backgroundLight),
        child: Stack(
          children: [
            // Background pattern with educational doodles
            Positioned.fill(
              bottom: 400,
              left: 0,
              right: 0,
              top: 0,
              child: Image.asset(
                'assets/images/background_without_bg.png',
                opacity: const AlwaysStoppedAnimation<double>(0.4),
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
                height: 500,
              ),
            ),
            Positioned.fill(
              bottom: -10,
              left: 0,
              right: 0,
              top: 550,
              child: Image.asset(
                'assets/images/background_without_bg.png',
                opacity: const AlwaysStoppedAnimation<double>(0.4),
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width,
                height: 500,
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo and branding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/big_logo.png',
                        height: 80,
                        width: 80,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'XScholar ERP',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const Text(
                            'Parents App',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  // Login card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Card(
                        elevation: 8,
                        shadowColor: AppColors.shadowBlack.withValues(
                          alpha: 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Welcome message
                              const Text(
                                'Welcome Back, Parents!',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 40),
                              // Phone number field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.inputFieldLightBlue,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: 'Phone number',
                                    hintStyle: const TextStyle(
                                      color: AppColors.textDarkGrey,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.person,
                                      color: AppColors.textDarkGrey,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Password field
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.inputFieldLightBlue,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: const TextStyle(
                                      color: AppColors.textDarkGrey,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: AppColors.textDarkGrey,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: AppColors.textDarkGrey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              // Login button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: Implement actual login logic
                                    // For now, navigate to select student screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SelectStudentScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentOrange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Footer
                  const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Powered by ',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDarkGrey,
                          ),
                        ),
                        Text(
                          'LevNext',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDarkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the background doodles (same as welcome screen)
class DoodleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.doodleLightGrey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw various educational doodles
    _drawGraduationCap(canvas, paint, size.width * 0.1, size.height * 0.15);
    _drawGlobe(canvas, paint, size.width * 0.85, size.height * 0.2);
    _drawRocket(canvas, paint, size.width * 0.15, size.height * 0.3);
    _drawSmartphone(canvas, paint, size.width * 0.8, size.height * 0.35);
    _drawRobot(canvas, paint, size.width * 0.05, size.height * 0.5);
    _drawSoccerBall(canvas, paint, size.width * 0.9, size.height * 0.55);
    _drawMusicalNotes(canvas, paint, size.width * 0.2, size.height * 0.65);
    _drawTestTubes(canvas, paint, size.width * 0.75, size.height * 0.7);
    _drawApple(canvas, paint, size.width * 0.1, size.height * 0.8);
    _drawLightbulb(canvas, paint, size.width * 0.85, size.height * 0.85);
    _drawSpeechBubbles(canvas, paint, size.width * 0.3, size.height * 0.9);
    _drawStars(canvas, paint, size.width * 0.7, size.height * 0.25);
    _drawLetters(canvas, paint, size.width * 0.4, size.height * 0.4);
    _drawArrows(canvas, paint, size.width * 0.6, size.height * 0.75);
  }

  void _drawGraduationCap(Canvas canvas, Paint paint, double x, double y) {
    // Square base
    canvas.drawRect(Rect.fromLTWH(x, y, 20, 20), paint);
    // Tassel
    canvas.drawLine(Offset(x + 10, y), Offset(x + 10, y - 15), paint);
    canvas.drawCircle(Offset(x + 10, y - 15), 3, paint);
  }

  void _drawGlobe(Canvas canvas, Paint paint, double x, double y) {
    canvas.drawCircle(Offset(x, y), 15, paint);
    // Meridians
    canvas.drawLine(Offset(x - 15, y), Offset(x + 15, y), paint);
    canvas.drawLine(Offset(x, y - 15), Offset(x, y + 15), paint);
  }

  void _drawRocket(Canvas canvas, Paint paint, double x, double y) {
    // Body
    canvas.drawRect(Rect.fromLTWH(x, y, 12, 20), paint);
    // Nose cone
    final path = Path()
      ..moveTo(x + 6, y)
      ..lineTo(x, y - 8)
      ..lineTo(x + 12, y - 8)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawSmartphone(Canvas canvas, Paint paint, double x, double y) {
    canvas.drawRect(Rect.fromLTWH(x, y, 18, 25), paint);
    // Screen
    canvas.drawRect(Rect.fromLTWH(x + 2, y + 2, 14, 21), paint);
  }

  void _drawRobot(Canvas canvas, Paint paint, double x, double y) {
    // Head
    canvas.drawRect(Rect.fromLTWH(x, y, 20, 20), paint);
    // Eyes
    canvas.drawCircle(Offset(x + 6, y + 6), 2, paint);
    canvas.drawCircle(Offset(x + 14, y + 6), 2, paint);
    // Body
    canvas.drawRect(Rect.fromLTWH(x + 5, y + 20, 10, 15), paint);
  }

  void _drawSoccerBall(Canvas canvas, Paint paint, double x, double y) {
    canvas.drawCircle(Offset(x, y), 12, paint);
    // Pattern lines
    canvas.drawLine(Offset(x - 12, y), Offset(x + 12, y), paint);
    canvas.drawLine(Offset(x, y - 12), Offset(x, y + 12), paint);
  }

  void _drawMusicalNotes(Canvas canvas, Paint paint, double x, double y) {
    // Note head
    canvas.drawCircle(Offset(x, y), 3, paint);
    // Stem
    canvas.drawLine(Offset(x + 3, y), Offset(x + 3, y - 12), paint);
    // Flag
    final path = Path()
      ..moveTo(x + 3, y - 12)
      ..quadraticBezierTo(x + 8, y - 12, x + 8, y - 8)
      ..quadraticBezierTo(x + 8, y - 4, x + 3, y - 4);
    canvas.drawPath(path, paint);
  }

  void _drawTestTubes(Canvas canvas, Paint paint, double x, double y) {
    // Tube 1
    canvas.drawRect(Rect.fromLTWH(x, y, 8, 20), paint);
    // Tube 2
    canvas.drawRect(Rect.fromLTWH(x + 12, y, 8, 20), paint);
  }

  void _drawApple(Canvas canvas, Paint paint, double x, double y) {
    // Apple body
    canvas.drawCircle(Offset(x, y), 10, paint);
    // Stem
    canvas.drawLine(Offset(x, y - 10), Offset(x, y - 15), paint);
    // Leaf
    final path = Path()
      ..moveTo(x, y - 15)
      ..quadraticBezierTo(x + 5, y - 18, x + 8, y - 15);
    canvas.drawPath(path, paint);
  }

  void _drawLightbulb(Canvas canvas, Paint paint, double x, double y) {
    // Bulb
    canvas.drawCircle(Offset(x, y), 12, paint);
    // Base
    canvas.drawRect(Rect.fromLTWH(x - 8, y + 12, 16, 8), paint);
    // Filament
    canvas.drawLine(Offset(x - 8, y), Offset(x + 8, y), paint);
    canvas.drawLine(Offset(x, y - 8), Offset(x, y + 8), paint);
  }

  void _drawSpeechBubbles(Canvas canvas, Paint paint, double x, double y) {
    // Main bubble
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 20, 15),
        const Radius.circular(8),
      ),
      paint,
    );
    // Tail
    final path = Path()
      ..moveTo(x + 5, y + 15)
      ..lineTo(x + 8, y + 20)
      ..lineTo(x + 11, y + 15);
    canvas.drawPath(path, paint);
  }

  void _drawStars(Canvas canvas, Paint paint, double x, double y) {
    for (int i = 0; i < 3; i++) {
      final starX = x + i * 8;
      final starY = y + i * 5;
      _drawStar(canvas, paint, starX, starY, 4);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double x, double y, double size) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * 3.14159 / 5;
      final outerX = x + size * cos(angle);
      final outerY = y + size * sin(angle);
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }

      final innerAngle = angle + 3.14159 / 5;
      final innerX = x + size * 0.5 * cos(innerAngle);
      final innerY = y + size * 0.5 * sin(innerAngle);
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLetters(Canvas canvas, Paint paint, double x, double y) {
    // Letter A
    final pathA = Path()
      ..moveTo(x, y + 15)
      ..lineTo(x + 8, y)
      ..lineTo(x + 16, y + 15)
      ..moveTo(x + 3, y + 10)
      ..lineTo(x + 13, y + 10);
    canvas.drawPath(pathA, paint);

    // ABC text
    canvas.drawLine(Offset(x + 20, y + 8), Offset(x + 28, y + 8), paint);
    canvas.drawLine(Offset(x + 20, y + 12), Offset(x + 28, y + 12), paint);
  }

  void _drawArrows(Canvas canvas, Paint paint, double x, double y) {
    // Right arrow
    final rightArrow = Path()
      ..moveTo(x, y)
      ..lineTo(x + 12, y)
      ..lineTo(x + 8, y - 4)
      ..moveTo(x + 12, y)
      ..lineTo(x + 8, y + 4);
    canvas.drawPath(rightArrow, paint);

    // Left arrow
    final leftArrow = Path()
      ..moveTo(x + 20, y)
      ..lineTo(x + 8, y)
      ..lineTo(x + 12, y - 4)
      ..moveTo(x + 8, y)
      ..lineTo(x + 12, y + 4);
    canvas.drawPath(leftArrow, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
