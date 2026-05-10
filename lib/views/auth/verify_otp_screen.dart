import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/app_navigation.dart';
import '../../controllers/auth_controller.dart';
import 'auth_flow_widgets.dart';
import 'change_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyOtpScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _otpLength = 6;
  late final AuthController _authController;
  final List<TextEditingController> _otpControllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );
  Timer? _timer;
  int _remainingSeconds = 60;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  String _otpValue() => _otpControllers.map((c) => c.text).join();

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
      return;
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  /// Display line like reference: "+91 98765 43210"
  String _headerPhoneSubtitle() {
    final digits = widget.phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      final last10 = digits.substring(digits.length - 10);
      return '+91 ${last10.substring(0, 5)} ${last10.substring(5)}';
    }
    return '+91 ${widget.phoneNumber.trim()}';
  }

  Future<void> _verifyOtp() async {
    final otp = _otpValue();
    if (otp.length != _otpLength) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter 6-digit OTP')));
      return;
    }

    final ok = await _authController.verifyForgotPasswordOtp(
      phoneNumber: widget.phoneNumber,
      otp: otp,
    );
    if (!mounted || !ok) return;

    AppNavigation.pushReplacement(
      context,
      ChangePasswordScreen(phoneNumber: widget.phoneNumber, otp: otp),
    );
  }

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0) return;
    final ok = await _authController.resendForgotPasswordOtp(
      widget.phoneNumber,
    );
    if (!mounted || !ok) return;
    setState(() {});
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final mm = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final horizontalPad = 22.0;
    final maxW = MediaQuery.sizeOf(context).width - horizontalPad * 2;
    final gap = 8.0;
    final otpWidth = ((maxW - gap * (_otpLength - 1)) / _otpLength).clamp(
      40.0,
      54.0,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthFlowOrangeHeader(
            title: 'Verify OTP',
            subtitle:
                'Enter the 6-digit code sent to ${_headerPhoneSubtitle()}',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPad,
                28,
                horizontalPad,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      _otpLength,
                      (index) => Container(
                        width: otpWidth,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2D3440),
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) => _onOtpChanged(value, index),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: kAuthFlowOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              'Expires in ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$mm:$ss',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: kAuthFlowOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Didn't receive? ",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                (_authController.isLoading.value ||
                                    _remainingSeconds > 0)
                                ? null
                                : _resendOtp,
                            child: Text(
                              'Resend',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _remainingSeconds > 0
                                    ? Colors.grey.shade400
                                    : kAuthFlowOrange,
                                decoration: TextDecoration.underline,
                                decorationColor: _remainingSeconds > 0
                                    ? Colors.grey.shade400
                                    : kAuthFlowOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _authController.isLoading.value
                            ? null
                            : _verifyOtp,
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
                                'Verify OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Wrong number? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            color: kAuthFlowOrange,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),
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
}
