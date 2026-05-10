import 'package:flutter/material.dart';

import '../routes/app_routes.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  // Basic navigation methods
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToReplacement(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> navigateToAndRemoveUntil(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  static void goBack() {
    if (navigator!.canPop()) {
      navigator!.pop();
    }
  }

  static void goBackWithResult(dynamic result) {
    if (navigator!.canPop()) {
      navigator!.pop(result);
    }
  }

  // Specific navigation methods for common flows
  static Future<dynamic> navigateToLogin() {
    return navigateToAndRemoveUntil(AppRoutes.login);
  }

  static Future<dynamic> navigateToDashboard() {
    return navigateToAndRemoveUntil(AppRoutes.dashboard);
  }
}
