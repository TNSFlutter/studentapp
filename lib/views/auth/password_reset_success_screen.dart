import 'package:flutter/material.dart';

import '../../helpers/app_navigation.dart';
import 'auth_flow_widgets.dart';
import 'login_screen.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthFlowOrangeHeader(
            showBack: false,
            title: 'Password Reset!',
            subtitle: 'Your password has been updated.',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 96,
                      width: 96,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8FAEE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xFF22C55E),
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Center(
                    child: Text(
                      'All done!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your password has been successfully reset. You can now log in with your new password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACCOUNT SECURED',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lock_rounded,
                              size: 20,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Password updated successfully',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              size: 20,
                              color: Colors.blue.shade600,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'All other sessions logged out',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        AppNavigation.pushAndRemoveUntil(
                          context,
                          const LoginScreen(),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAuthFlowOrange,
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shadowColor: kAuthFlowOrange.withValues(alpha: 0.45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Back to Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
}
