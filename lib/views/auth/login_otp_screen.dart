import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/app_navigation.dart';
import '../select_student/select_student_screen.dart';

/// Passwordless login: send OTP → verify → same token storage as password login.
class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key, this.initialPhone = ''});

  final String initialPhone;

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  static const Color _headingBlue = Color(0xFF15245C);
  static const Color _labelGray = Color(0xFF4B5563);
  static const Color _hintGray = Color(0xFF9CA3AF);
  static const Color _fieldBorder = Color(0xFFE5E7EB);

  static const int _otpDigits = 6;
  static const int _resendCooldownSeconds = 60;

  late final AuthController _authController;
  late final TextEditingController _phoneController;
  final _otpController = TextEditingController();
  final _otpFocus = FocusNode();

  bool _otpSent = false;
  bool _sending = false;
  bool _resendBusy = false;
  bool _verifying = false;
  Timer? _resendTimer;
  int _resendSeconds = 0;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _otpFocus.addListener(() => setState(() {}));
    final digits = widget.initialPhone.replaceAll(RegExp(r'\D'), '');
    final ten = digits.length >= 10 ? digits.substring(digits.length - 10) : digits;
    _phoneController = TextEditingController(text: ten);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = _resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        t.cancel();
        setState(() => _resendSeconds = 0);
        return;
      }
      setState(() => _resendSeconds--);
    });
  }

  String get _phone10 {
    final d = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (d.length >= 10) return d.substring(d.length - 10);
    return d;
  }

  String _formatCountdown(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Same API as initial send: `POST auth/login-otp/send`.
  Future<void> _sendOtp() async {
    if (_sending) return;
    if (_phone10.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit mobile number')),
      );
      return;
    }
    setState(() => _sending = true);
    final ok = await _authController.sendLoginOtp(_phone10);
    if (!mounted) return;
    setState(() {
      _sending = false;
      if (ok) {
        _otpSent = true;
        _otpController.clear();
        _startResendCooldown();
      }
    });
    if (ok) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _otpFocus.requestFocus();
      });
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || _resendBusy) return;
    setState(() => _resendBusy = true);
    final ok = await _authController.sendLoginOtp(_phone10);
    if (!mounted) return;
    setState(() => _resendBusy = false);
    if (ok) {
      _otpController.clear();
      _startResendCooldown();
      _otpFocus.requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_verifying) return;
    final otp = _otpController.text.trim();
    final needDigits = _otpDigits;
    if (otp.length != needDigits) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter the $needDigits digit OTP sent to your phone',
          ),
        ),
      );
      return;
    }
    setState(() => _verifying = true);
    final ok = await _authController.verifyLoginOtp(
      phone: _phone10,
      otp: otp,
    );
    if (!mounted) return;
    setState(() => _verifying = false);
    if (!ok) return;

    _authController.takePendingLoginSuccessMessage();
    await AppNavigation.pushReplacement(context, const SelectStudentScreen());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phoneForSubtitle = _phone10;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: _headingBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login with OTP',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _headingBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _otpSent
                      ? 'Enter the code we sent to +91 $phoneForSubtitle.'
                      : 'We will send a one-time code to your registered mobile number.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _hintGray,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _fieldBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 56,
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              const Text(
                                '+91',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF374151),
                                ),
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
                                child: TextField(
                                  controller: _phoneController,
                                  enabled: !_otpSent,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF1F2937),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '10-digit mobile number',
                                    filled: false,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(right: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_otpSent) ...[
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: _fieldBorder,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ONE-TIME PASSWORD',
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accentOrange.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightOrangeColor2,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _otpFocus.hasFocus
                                          ? AppColors.accentOrange
                                          : AppColors.accentOrange.withValues(
                                              alpha: 0.28,
                                            ),
                                      width: _otpFocus.hasFocus ? 2 : 1,
                                    ),
                                    boxShadow: _otpFocus.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: AppColors.accentOrange
                                                  .withValues(alpha: 0.18),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.03,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: TextField(
                                    controller: _otpController,
                                    focusNode: _otpFocus,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                        _otpDigits,
                                      ),
                                    ],
                                    style: TextStyle(
                                      fontSize: 24,
                                      letterSpacing: 10,
                                      fontWeight: FontWeight.w800,
                                      color: _headingBlue,
                                      height: 1.2,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '0 0 0 0 0 0',
                                      hintStyle: TextStyle(
                                        fontSize: 22,
                                        letterSpacing: 8,
                                        fontWeight: FontWeight.w600,
                                        color: _hintGray.withValues(alpha: 0.45),
                                      ),
                                      filled: false,
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    onSubmitted: (_) => _verify(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_otpSent)
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0x40F97316),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _sending
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Send OTP',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                if (_otpSent) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accentOrange.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 22,
                          color: _resendSeconds > 0
                              ? _hintGray
                              : AppColors.accentOrange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _resendSeconds > 0
                                ? 'Resend code in ${_formatCountdown(_resendSeconds)}'
                                : 'You can request a new code now.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _resendSeconds > 0
                                  ? _labelGray
                                  : _headingBlue,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resendSeconds > 0 || _resendBusy
                          ? null
                          : _resendOtp,
                      child: _resendBusy
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.accentOrange,
                              ),
                            )
                          : Text(
                              'Resend OTP',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: _resendSeconds > 0
                                    ? _hintGray
                                    : AppColors.accentOrange,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: const Color(0x40F97316),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _verifying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Verify & continue',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: Text(
                      'Use password instead',
                      style: TextStyle(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
