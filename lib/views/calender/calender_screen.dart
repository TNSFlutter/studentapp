import 'package:flutter/material.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime(2024, 1, 17);
  DateTime _focusedDate = DateTime(2024, 1, 17);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Holiday Calendar'),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        number: '11',
                        label: 'Present',
                        backgroundColor: AppColors.accentOrange,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        number: '03',
                        label: 'Absent',
                        backgroundColor: Colors.white,
                        textColor: AppColors.statusRed,
                        numberColor: AppColors.statusRed,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        number: '03',
                        label: 'Leave',
                        backgroundColor: Colors.white,
                        textColor: Colors.grey,
                        numberColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Month Navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _focusedDate = DateTime(
                                    _focusedDate.year,
                                    _focusedDate.month - 1,
                                  );
                                });
                              },
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text(
                              '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _focusedDate = DateTime(
                                    _focusedDate.year,
                                    _focusedDate.month + 1,
                                  );
                                });
                              },
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Days of Week Header
                        Row(
                          children: const [
                            Expanded(
                              child: Center(
                                child: Text(
                                  'SUN',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'MON',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'TUE',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'WED',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'THU',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'FRI',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'SAT',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Calendar Grid
                        _buildCalendarGrid(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Upcoming Events Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upcoming Events',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildEventItem(
                      month: 'JAN',
                      day: '13',
                      title: 'Lohri',
                      subtitle: 'Festival of Harvest',
                      type: 'Holiday',
                      date: '23 Jan 2025',
                      typeColor: AppColors.accentOrange,
                    ),
                    const SizedBox(height: 12),
                    _buildEventItem(
                      month: 'JAN',
                      day: '25',
                      title: 'Sports Meet',
                      subtitle: 'Function at School',
                      type: 'Event',
                      date: '20 Jan 2025',
                      typeColor: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildEventItem(
                      month: 'JAN',
                      day: '26',
                      title: 'Republic Day',
                      subtitle: 'Celebrated due to',
                      type: 'Holiday',
                      date: '18 Jan 2025',
                      typeColor: AppColors.accentOrange,
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

  Widget _buildSummaryCard({
    required String number,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? numberColor,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: backgroundColor,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: numberColor ?? textColor,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    );
    final firstWeekday =
        firstDayOfMonth.weekday % 7; // Convert to 0-6 (Sunday = 0)
    final totalDays = lastDayOfMonth.day;

    List<Widget> calendarDays = [];

    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstWeekday; i++) {
      calendarDays.add(const Expanded(child: SizedBox()));
    }

    // Add all days of the month
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final isSelected =
          day == _selectedDate.day && _focusedDate.month == _selectedDate.month;
      final isEventDay = [13, 25, 26].contains(day);

      Color dayColor = Colors.grey;
      if ([1, 2, 3, 7, 8, 9, 10, 14, 15, 16].contains(day)) {
        dayColor = Colors.green;
      } else if ([4, 11, 12].contains(day)) {
        dayColor = Colors.red;
      } else if (day == 5) {
        dayColor = Colors.blue;
      }

      calendarDays.add(
        Expanded(
          child: Container(
            height: 40,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentOrange : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    color: isSelected ? Colors.white : dayColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isEventDay)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.accentOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // Create rows of 7 days each
    List<Widget> calendarRows = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      final rowDays = calendarDays.skip(i).take(7).toList();
      // Pad the last row if needed
      while (rowDays.length < 7) {
        rowDays.add(const Expanded(child: SizedBox()));
      }
      calendarRows.add(Row(children: rowDays));
    }

    return Column(children: calendarRows);
  }

  Widget _buildEventItem({
    required String month,
    required String day,
    required String title,
    required String subtitle,
    required String type,
    required String date,
    required Color typeColor,
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
          // Date Badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Type and Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: typeColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
