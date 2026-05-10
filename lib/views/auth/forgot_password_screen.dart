import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_navigation.dart';
import '../../controllers/auth_controller.dart';
import 'auth_flow_widgets.dart';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final AuthController _authController;
  final TextEditingController _phoneController = TextEditingController();
  String _phoneError = '';

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() => _phoneError = 'Please enter a valid phone number');
      return;
    }
    setState(() => _phoneError = '');

    final ok = await _authController.sendForgotPasswordOtp(phone);
    if (!mounted || !ok) return;

    AppNavigation.push<void>(context, VerifyOtpScreen(phoneNumber: phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthFlowOrangeHeader(
            title: 'Forgot Password?',
            subtitle:
                'No worries! Enter your registered mobile number to reset it.',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8D6),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFCFA8),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 42,
                        color: kAuthFlowOrange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "We'll send a 6-digit OTP to your registered mobile number",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFF8C93A2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Registered Mobile Number',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _phoneError.isNotEmpty
                            ? AppColors.statusRed
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        const Text(
                          '+91',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade400,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 1,
                          height: 22,
                          color: const Color(0xFFE5E7EB),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                            decoration: const InputDecoration(
                              hintText: '98765 43210',
                              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                  if (_phoneError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        _phoneError,
                        style: const TextStyle(
                          color: AppColors.statusRed,
                          fontSize: 12,
                        ),
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
                            : _submit,
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
                                'Send Reset OTP',
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
                        'Remember your password? ',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: kAuthFlowOrange,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
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
