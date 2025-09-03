import 'package:flutter/material.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';

class ExamResultScreen extends StatelessWidget {
  const ExamResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Exam Results'),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
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

                    // Term-I Test Card
                    _buildExamResultCard(
                      testName: 'Term-I',
                      totalMarks: '177/290',
                      percentage: '44.3%',
                      timestamp: '09 Nov 2025, 4:45 PM',
                      subjects: [
                        {
                          'name': 'English',
                          'maxMarks': '80',
                          'obtainedMarks': 'AB',
                        },
                        {
                          'name': 'Hindi',
                          'maxMarks': '80',
                          'obtainedMarks': '56',
                        },
                        {
                          'name': 'Mathametics',
                          'maxMarks': '80',
                          'obtainedMarks': '76',
                        },
                        {
                          'name': 'EVS',
                          'maxMarks': '50',
                          'obtainedMarks': '45',
                        },
                      ],
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

                    // Unit Test Card
                    _buildExamResultCard(
                      testName: 'Unit Test',
                      totalMarks: '177/290',
                      percentage: '44.3%',
                      timestamp: '03 Sept 2025, 8:05 AM',
                      subjects: [
                        {
                          'name': 'English',
                          'maxMarks': '80',
                          'obtainedMarks': 'AB',
                        },
                        {
                          'name': 'Hindi',
                          'maxMarks': '80',
                          'obtainedMarks': '56',
                        },
                        {
                          'name': 'Mathametics',
                          'maxMarks': '80',
                          'obtainedMarks': '76',
                        },
                        {
                          'name': 'EVS',
                          'maxMarks': '50',
                          'obtainedMarks': '45',
                        },
                      ],
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

  Widget _buildExamResultCard({
    required String testName,
    required String totalMarks,
    required String percentage,
    required String timestamp,
    required List<Map<String, String>> subjects,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Icon and Test Name
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.accentOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                testName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary Row
          Row(
            children: [
              Text(
                'Total- $totalMarks',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 20),
              Text(
                'Percentage- $percentage',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Marks Table
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Subject',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Max Marks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Obtained Marks',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Rows
                ...subjects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subject = entry.value;
                  final isLast = index == subjects.length - 1;

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: isLast
                            ? BorderSide.none
                            : BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            subject['name']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            subject['maxMarks']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            subject['obtainedMarks']!,
                            style: TextStyle(
                              fontSize: 14,
                              color: subject['obtainedMarks'] == 'AB'
                                  ? Colors.red
                                  : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
    );
  }
}
