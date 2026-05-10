import 'package:flutter/material.dart';
import 'package:studentapp/helpers/app_navigation.dart';
import 'package:studentapp/views/auth/login_screen.dart';
import 'package:studentapp/views/dashboard/dashboard_screen.dart';
import 'package:studentapp/views/select_student/select_student_screen.dart';
import 'package:studentapp/views/welcome_screen.dart';

class AppRoutes {
  // Route names
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String selectStudent = '/select-student';
  static const String dashboard = '/dashboard';

  // Route generation
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return AppNavigation.pageRoute((_) => const WelcomeScreen(), settings: settings);

      case login:
        return AppNavigation.pageRoute((_) => const LoginScreen(), settings: settings);

      case selectStudent:
        return AppNavigation.pageRoute((_) => const SelectStudentScreen(), settings: settings);

      case dashboard:
        return AppNavigation.pageRoute(
          (_) => const DashboardScreen(selectedStudent: {}),
          settings: settings,
        );

      default:
        return AppNavigation.pageRoute(
          (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
          settings: settings,
        );
    }
  }
}
