import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_navigation.dart';
import '../../controllers/auth_controller.dart';
import 'auth_flow_widgets.dart';
import 'password_reset_success_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;

  const ChangePasswordScreen({
    super.key,
    required this.phoneNumber,
    required this.otp,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  late final AuthController _authController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String _passwordError = '';
  String _confirmError = '';

  static bool _ruleMin8(String p) => p.length >= 8;
  static bool _ruleUpper(String p) => RegExp(r'[A-Z]').hasMatch(p);
  static bool _ruleSpecial(String p) =>
      RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-\[\]/\\`~;+=]''').hasMatch(p);

  int _filledStrengthBars(String p) {
    final rules = [
      _ruleMin8(p),
      _ruleUpper(p),
      RegExp(r'[0-9]').hasMatch(p),
      _ruleSpecial(p),
    ];
    return rules.where((ok) => ok).length.clamp(0, 4);
  }

  String _strengthLabel(int bars) {
    if (_newPasswordController.text.isEmpty) return '';
    if (bars <= 1) return 'Weak strength';
    if (bars == 2) return 'Fair strength';
    if (bars == 3) return 'Good strength';
    return 'Strong password';
  }

  late final VoidCallback _fieldsListener;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _fieldsListener = () => setState(() {});
    _newPasswordController.addListener(_fieldsListener);
    _confirmPasswordController.addListener(_fieldsListener);
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_fieldsListener);
    _confirmPasswordController.removeListener(_fieldsListener);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _requirementRow(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 18,
            color: met ? const Color(0xFF22C55E) : const Color(0xFFD1D5DB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: met ? const Color(0xFF374151) : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pass = _newPasswordController.text;
    final bars = _filledStrengthBars(pass);
    final strengthCaption = _strengthLabel(bars);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthFlowOrangeHeader(
            title: 'Set Password',
            subtitle: 'Create a strong password to secure your account.',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'New Password',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _passwordError.isNotEmpty
                            ? AppColors.statusRed
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFFB0B5BE),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: const Color(0xFFB0B5BE),
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 4,
                        ),
                      ),
                    ),
                  ),
                  if (pass.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(4, (i) {
                        final filled = i < bars;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: filled
                                    ? kAuthFlowOrange
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (strengthCaption.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        strengthCaption,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kAuthFlowOrange,
                        ),
                      ),
                    ],
                  ],
                  if (_passwordError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        _passwordError,
                        style: const TextStyle(
                          color: AppColors.statusRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 18),
                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _confirmError.isNotEmpty
                            ? AppColors.statusRed
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFFB0B5BE),
                        ),
                        suffixIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_confirmPasswordController.text.isNotEmpty) ...[
                              Icon(
                                _newPasswordController.text ==
                                        _confirmPasswordController.text
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_outlined,
                                color:
                                    _newPasswordController.text ==
                                        _confirmPasswordController.text
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFD1D5DB),
                                size: 22,
                              ),
                              const SizedBox(width: 4),
                            ],
                            IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFFB0B5BE),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ],
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minHeight: 48,
                          minWidth: 48,
                        ),
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 4,
                        ),
                      ),
                    ),
                  ),
                  if (_confirmError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        _confirmError,
                        style: const TextStyle(
                          color: AppColors.statusRed,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password checklist',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _requirementRow(
                          'At least 8 characters',
                          _ruleMin8(pass),
                        ),
                        _requirementRow(
                          'One uppercase letter',
                          _ruleUpper(pass),
                        ),
                        _requirementRow(
                          'One special character',
                          _ruleSpecial(pass),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading.value
                            ? null
                            : _handleResetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _authController.isLoading.value
                              ? const Color(0xFFB8BDC7)
                              : kAuthFlowOrange,
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: kAuthFlowOrange.withValues(alpha: 0.45),
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
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        children: const [
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final pass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    setState(() {
      _passwordError = '';
      _confirmError = '';
    });

    if (pass.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    if (confirm != pass) {
      setState(() => _confirmError = 'Password does not match');
      return;
    }

    final ok = await _authController.resetPasswordWithOtp(
      phone: widget.phoneNumber,
      otp: widget.otp,
      newPassword: pass,
    );
    if (!mounted || !ok) return;

    AppNavigation.pushAndRemoveUntil(
      context,
      const PasswordResetSuccessScreen(),
      (route) => false,
    );
  }
}
