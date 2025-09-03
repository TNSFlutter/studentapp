import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.backgroundLight),
        child: Stack(
          children: [
            // // Background pattern with educational doodles
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

            // Image.asset(
            //   'assets/images/background_without_bg.png',
            //   fit: BoxFit.fill,
            //   width: MediaQuery.of(context).size.width,
            //   height: 500,
            // ),
            // Image.asset(
            //   'assets/images/background_without_bg.png',
            //  // fit: BoxFit.contain,
            //   width: MediaQuery.of(context).size.width,
            //   height: 400,
            // ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo and branding
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/big_logo.png',
                        height: 160,
                        width: 160,
                      ),
                      const SizedBox(height: 16),
                      Image.asset("assets/images/XScholar.png"),
                      const SizedBox(height: 16),
                      Image.asset("assets/images/ERP.png"),
                    ],
                  ),
                  const SizedBox(height: 60),
                  // Welcome message
                  const Column(
                    children: [
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 30,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'XScholar ERP',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Parents App',
                        style: TextStyle(
                          fontSize: 30,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Stay Connected, Stay Informed',
                        style: TextStyle(
                          fontSize: 20,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Register',
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
                  const Spacer(),
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
