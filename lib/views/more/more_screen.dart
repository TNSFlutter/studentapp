import 'package:flutter/material.dart';
import 'package:studentapp/views/test/class_test_screen.dart';
import 'package:studentapp/views/test/exam_result_screen.dart';

import '../../constants/app_colors.dart';
import '../calender/calender_screen.dart';
import '../fees/fee_screen.dart';
import '../homework/homework_screen.dart';
import '../message/message_screen.dart';
import '../notice_borad/notice_board_screen.dart';
import '../timetable/timetable_screen.dart';
import '../track/track_bus_screen.dart';
import 'datesheet_screen.dart';
import 'event_gallery_screen.dart';
import 'gate_pass_screen.dart';
import 'live_class_screen.dart';
import 'syllabus_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    final List<_MoreItem> items = [
      _MoreItem(icon: Icons.attach_money, title: 'Fee'),
      _MoreItem(icon: Icons.person_2_rounded, title: 'Attendance'),
      _MoreItem(icon: Icons.book_rounded, title: 'Homework'),
      _MoreItem(icon: Icons.notifications, title: 'Notification'),
      _MoreItem(icon: Icons.pie_chart, title: 'Results'),
      _MoreItem(icon: Icons.assignment_turned_in, title: 'Class Test'),
      _MoreItem(icon: Icons.access_time, title: 'Timetable'),
      _MoreItem(icon: Icons.event_note, title: 'Datesheet'),
      _MoreItem(icon: Icons.menu_book, title: 'Syllabus'),
      _MoreItem(icon: Icons.video_call, title: 'Live Class'),
      _MoreItem(icon: Icons.calendar_month, title: 'Holiday Calendar'),
      _MoreItem(icon: Icons.directions_bus, title: 'Track Bus'),
      _MoreItem(icon: Icons.photo_library, title: 'Events Gallery'),
      _MoreItem(icon: Icons.notifications_active, title: 'Notice Board'),
      _MoreItem(icon: Icons.qr_code, title: 'Gate Pass'),
      _MoreItem(icon: Icons.translate, title: 'Change Language'),
      // _MoreItem(icon: Icons.support, title: 'Help & Support'),
      _MoreItem(icon: Icons.logout, title: 'Sign Out'),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardWhite,
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
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          _buildRow(items[i]),
                          if (i != items.length - 1)
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFEAEAEA),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA44F), AppColors.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.cardWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: AppColors.accentOrange),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, Himanshi Mehra',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cardWhite,
                  ),
                ),
                Text(
                  'Class 5-B | Roll No: 3 | Adm No: 5478',
                  style: TextStyle(fontSize: 13, color: AppColors.cardWhite),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardWhite.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.notifications, color: AppColors.cardWhite),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(_MoreItem item) {
    return InkWell(
      onTap: () {
        if (item.title == 'Fee') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FeeScreen(showBackButton: true),
            ),
          );
        } else if (item.title == 'Track Bus') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TrackBusScreen()),
          );
        } else if (item.title == 'Holiday Calendar') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalendarScreen()),
          );
        } else if (item.title == 'Homework') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomeworkScreen()),
          );
        } else if (item.title == 'Notification') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MessageScreen(showBackButton: true),
            ),
          );
        } else if (item.title == 'Class Test') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClassTestScreen()),
          );
        } else if (item.title == 'Results') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExamResultScreen()),
          );
        } else if (item.title == 'Timetable') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TimetableScreen()),
          );
        } else if (item.title == 'Datesheet') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DatesheetScreen()),
          );
        } else if (item.title == 'Syllabus') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SyllabusScreen()),
          );
        } else if (item.title == 'Live Class') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LiveClassScreen()),
          );
        } else if (item.title == 'Events Gallery') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EventGalleryScreen()),
          );
        } else if (item.title == 'Notice Board') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoticeBoardScreen()),
          );
        } else if (item.title == 'Gate Pass') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GatePassScreen()),
          );
        } else if (item.title == 'Sign Out') {
          _showLogoutDialog();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(item.icon, color: AppColors.textBlack, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textBlack,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textBlack,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                const Text(
                  'Are you sure, Do you want to logout?',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Yes Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _performLogout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.accentOrange,
                          side: const BorderSide(
                            color: AppColors.accentOrange,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Yes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Cancel Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _performLogout() {
    // Here you would implement the actual logout logic
    // For example: clear user data, navigate to login screen, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully!'),
        backgroundColor: AppColors.accentOrange,
      ),
    );

    // Example: Navigate to login screen
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => const LoginScreen()),
    //   (route) => false,
    // );
  }
}

class _MoreItem {
  final IconData icon;
  final String title;

  const _MoreItem({required this.icon, required this.title});
}
