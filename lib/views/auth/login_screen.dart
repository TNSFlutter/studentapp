import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/app_navigation.dart';
import '../select_student/select_student_screen.dart';
import 'forgot_password_screen.dart';
import 'login_otp_screen.dart';

/// Peach → white gradient & typography aligned with product login mockup.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  late final AuthController _authController;

  static const Color _headingBlue = Color(0xFF15245C);
  static const Color _labelGray = Color(0xFF4B5563);
  static const Color _hintGray = Color(0xFF9CA3AF);
  static const Color _fieldBorder = Color(0xFFE5E7EB);
  static const Color _lockGold = Color(0xFFD4A024);

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleLogin() async {
    _authController.usernameError.value = '';
    _authController.passwordError.value = '';

    final bool success = await _authController.login();

    if (!mounted) return;

    if (success) {
      _authController.takePendingLoginSuccessMessage();
      await AppNavigation.pushReplacement(context, const SelectStudentScreen());
    }
  }

  void _onLoginWithOtp() {
    final phone = _authController.usernameController.text.trim();
    AppNavigation.push<void>(context, LoginOtpScreen(initialPhone: phone));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF4EC), Color(0xFFFFFBF7), Colors.white],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.only(top: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _brandHeader(),
                          const SizedBox(height: 28),
                          const Text(
                            'Welcome back 👋',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 24,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: _headingBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Sign in to stay connected with your child's school activities",
                            textAlign: TextAlign.left,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              height: 1.55,
                              color: _hintGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    ClipPath(
                      clipper: _LoginTopWaveClipper(),
                      child: ColoredBox(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(22, 48, 22, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'MOBILE NUMBER',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: _labelGray,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(
                                () => Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color:
                                          _authController
                                              .usernameError
                                              .value
                                              .isNotEmpty
                                          ? AppColors.statusRed
                                          : _fieldBorder,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 14),
                                      const Text(
                                        '🇮🇳',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '+91',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF374151),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Color(0xFF9CA3AF),
                                        size: 22,
                                      ),
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        width: 1,
                                        height: 22,
                                        color: _fieldBorder,
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _authController
                                              .usernameController,
                                          keyboardType: TextInputType.phone,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF1F2937),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decoration: const InputDecoration(
                                            filled: false,
                                            hintText: 'Enter mobile number',
                                            hintStyle: TextStyle(
                                              color: _hintGray,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                              right: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Obx(
                                () =>
                                    _authController
                                        .usernameError
                                        .value
                                        .isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 4,
                                        ),
                                        child: Text(
                                          _authController.usernameError.value,
                                          style: const TextStyle(
                                            color: AppColors.statusRed,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'PASSWORD',
                                style: TextStyle(
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: _labelGray,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(
                                () => Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color:
                                          _authController
                                              .passwordError
                                              .value
                                              .isNotEmpty
                                          ? AppColors.statusRed
                                          : _fieldBorder,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 14),
                                      Icon(
                                        Icons.lock_outline_rounded,
                                        color: _lockGold,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _authController
                                              .passwordController,
                                          obscureText: !_isPasswordVisible,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.2,
                                            color: Color(0xFF1F2937),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decoration: const InputDecoration(
                                            filled: false,
                                            hintText: 'Enter password',
                                            hintStyle: TextStyle(
                                              color: _hintGray,
                                              fontWeight: FontWeight.w500,
                                              height: 1.2,
                                            ),
                                            isDense: true,
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            focusedErrorBorder:
                                                InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                            isCollapsed: true,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        visualDensity: VisualDensity.compact,
                                        splashRadius: 22,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 44,
                                          minHeight: 44,
                                        ),
                                        icon: Icon(
                                          _isPasswordVisible
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: const Color(0xFF9CA3AF),
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                  ),
                                ),
                              ),
                              Obx(
                                () =>
                                    _authController
                                        .passwordError
                                        .value
                                        .isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          left: 4,
                                        ),
                                        child: Text(
                                          _authController.passwordError.value,
                                          style: const TextStyle(
                                            color: AppColors.statusRed,
                                            fontSize: 12,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    AppNavigation.push<void>(
                                      context,
                                      const ForgotPasswordScreen(),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: AppColors.accentOrange,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _authController.isLoading.value
                                        ? null
                                        : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _authController.isLoading.value
                                          ? const Color(0xFFB8BDC7)
                                          : AppColors.accentOrange,
                                      foregroundColor: Colors.white,
                                      elevation: 4,
                                      shadowColor: const Color(0x40F97316),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _authController.isLoading.value
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton(
                                  onPressed: _onLoginWithOtp,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.accentOrange,
                                    side: const BorderSide(
                                      color: AppColors.accentOrange,
                                      width: 2,
                                    ),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.accentOrange,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Login with OTP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                              Center(
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    children: [
                                      TextSpan(text: 'Powered by '),
                                      TextSpan(
                                        text: 'LevNext',
                                        style: TextStyle(
                                          color: Color(0xFF374151),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
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
      ),
    );
  }

  /// Logo + product name (visible above the fold; matches reference header band).
  Widget _brandHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.accentOrange,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentOrange.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/images/big_logo.png',
              height: 30,
              width: 30,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'XScholar',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _headingBlue,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PARENTS APP',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Soft wave along the top edge of the white form sheet (transition from peach gradient).
class _LoginTopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    // Stronger amplitude + slightly shorter wavelength so the divider reads more “curved”.
    const base = 6.0;
    const amplitude = 22.0;
    double yAt(double x) {
      final t = (x / w) * math.pi * 2.6;
      final wave = 0.5 + 0.5 * math.sin(t);
      return base + amplitude * wave;
    }

    final path = Path()..moveTo(0, yAt(0));
    for (double x = 4; x <= w; x += 4) {
      path.lineTo(x, yAt(x));
    }
    path
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
