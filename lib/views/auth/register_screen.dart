import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_navigation.dart';
import 'verify_otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Stack(
          children: [
            // Background pattern with educational doodles
            // Positioned.fill(
            //   bottom: 400,
            //   left: 0,
            //   right: 0,
            //   top: 0,
            //   child: Image.asset(
            //     'assets/images/background_without_bg.png',
            //     opacity: const AlwaysStoppedAnimation<double>(0.4),
            //     fit: BoxFit.fill,
            //     width: MediaQuery.of(context).size.width,
            //     height: 500,
            //   ),
            // ),
            // Positioned.fill(
            //   bottom: -10,
            //   left: 0,
            //   right: 0,
            //   top: 550,
            //   child: Image.asset(
            //     'assets/images/background_without_bg.png',
            //     opacity: const AlwaysStoppedAnimation<double>(0.4),
            //     fit: BoxFit.fill,
            //     width: MediaQuery.of(context).size.width,
            //     height: 500,
            //   ),
            // ),

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
                  // Registration card
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
                                'Please enter your phone number to register yourself.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.textBlack,
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
                              const SizedBox(height: 40),
                              // Send OTP button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    AppNavigation.push<void>(
                                      context,
                                      VerifyOtpScreen(
                                        phoneNumber: _phoneController.text,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentOrange,
                                    foregroundColor: AppColors.cardWhite,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Send Otp',
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
