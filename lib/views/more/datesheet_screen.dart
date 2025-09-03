import 'package:flutter/material.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';

class DatesheetScreen extends StatefulWidget {
  const DatesheetScreen({super.key});

  @override
  State<DatesheetScreen> createState() => _DatesheetScreenState();
}

class _DatesheetScreenState extends State<DatesheetScreen> {
  bool _isFirstExpanded = false;
  bool _isSecondExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Datesheet'),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Recent Datesheet Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Datesheet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // First Datesheet Entry (Collapsed)
                    _buildDatesheetCard(
                      title: 'Periodic Test Datesheet',
                      ptmDate: 'PTM: 25 Dec 2025',
                      description:
                          'Datesheet for this Unit Test Examination from 1 Dec to 19 Dec.',
                      postedDate: '27 Nov 2025',
                      isExpanded: _isFirstExpanded,
                      onToggle: () {
                        setState(() {
                          _isFirstExpanded = !_isFirstExpanded;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Second Datesheet Entry (Expanded)
                    _buildDatesheetCard(
                      title: 'Unit Test Datesheet',
                      ptmDate: 'PTM: 21 Oct 2025',
                      description:
                          'Datesheet for this Unit Test Examination from 6 Oct to 15 Oct.',
                      postedDate: '2 Oct 2025',
                      isExpanded: _isSecondExpanded,
                      onToggle: () {
                        setState(() {
                          _isSecondExpanded = !_isSecondExpanded;
                        });
                      },
                      expandedContent: _buildExpandedContent(),
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

  Widget _buildDatesheetCard({
    required String title,
    required String ptmDate,
    required String description,
    required String postedDate,
    required bool isExpanded,
    required VoidCallback onToggle,
    Widget? expandedContent,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon Circle
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.accentOrange,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'UT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ptmDate,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                postedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Row(
                  children: [
                    Text(
                      isExpanded ? 'View Less' : 'View More',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.accentOrange,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Expanded Content
          if (isExpanded && expandedContent != null) ...[
            const SizedBox(height: 16),
            expandedContent,
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        _buildTimelineItem(
          date: '6 Oct',
          subject: 'Hindi',
          time: '9:00 to 12:00',
          room: 'Room No. 35',
          day: 'Monday',
        ),
        const SizedBox(height: 8),
        _buildTimelineItem(
          date: '8 Oct',
          subject: 'Mathematics',
          time: '9:00 to 12:00',
          room: 'Room No. 5',
          day: 'Wednesday',
        ),
        const SizedBox(height: 8),
        _buildTimelineItem(
          date: '10 Oct',
          subject: 'English',
          time: '9:00 to 12:00',
          room: 'Room No. 35',
          day: 'Friday',
        ),
        const SizedBox(height: 8),
        _buildTimelineItem(
          date: '13 Oct',
          subject: 'E.V.S',
          time: '9:00 to 12:00',
          room: 'Room No. 95',
          day: 'Monday',
        ),
        const SizedBox(height: 8),
        _buildTimelineItem(
          date: '14 Oct',
          subject: 'G.K',
          time: '9:00 to 12:00',
          room: 'Room No. 65',
          day: 'Tuesday',
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String subject,
    required String time,
    required String room,
    required String day,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Date
          Container(
            width: 60,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Subject Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$time, $room, $day',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
