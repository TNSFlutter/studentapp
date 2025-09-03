import 'package:flutter/material.dart';

import '../../widgets/bottom_navigation.dart';
import '../fees/fee_screen.dart';
import '../homework/homework_screen.dart';
import '../message/message_screen.dart';
import '../more/more_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> selectedStudent;

  const DashboardScreen({super.key, required this.selectedStudent});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentNavIndex = 2; // Home is selected by default (index 2)

  // List of screens for tab navigation
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const FeeScreen(showBackButton: false),
      const HomeworkScreen(), // Homework screen
      HomeScreen(
        selectedStudent: widget.selectedStudent,
      ), // Home/Dashboard content
      const MessageScreen(showBackButton: false), // Message screen
      const MoreScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentNavIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });
        },
      ),
    );
  }
}
