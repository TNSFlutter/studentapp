import 'package:flutter/material.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';

class ClassTestScreen extends StatelessWidget {
  const ClassTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Class Test'),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Today's Class Test Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Class Test",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Hindi Class Test Card
                    _buildClassTestCard(
                      subject: 'Hindi Class Test',
                      testDate: '03 Nov 2024',
                      maxMarks: '20',
                      obtainedMarks: '15',
                      timestamp: '09 Nov 2025, 4:45 PM',
                    ),
                    const SizedBox(height: 12),

                    // Physics Class Test Card
                    _buildClassTestCard(
                      subject: 'Physics Class Test',
                      testDate: '08 Nov 2024',
                      maxMarks: '30',
                      obtainedMarks: '27',
                      timestamp: '09 Nov 2025, 4:45 PM',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Previous Class Test Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Previous Class Test',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // English Class Test Card
                    _buildClassTestCard(
                      subject: 'English Class Test',
                      testDate: '01 Nov 2024',
                      maxMarks: '10',
                      obtainedMarks: '6',
                      timestamp: '06 Nov 2025, 8:45 AM',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassTestCard({
    required String subject,
    required String testDate,
    required String maxMarks,
    required String obtainedMarks,
    required String timestamp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Circle
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.accentOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.checklist, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Test Date: $testDate',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 12),
                // Marks Display
                Row(
                  children: [
                    // Max Marks
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Max Marks',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          maxMarks,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    // Obtained Marks
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Obtained Marks',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          obtainedMarks,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Timestamp
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    timestamp,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
