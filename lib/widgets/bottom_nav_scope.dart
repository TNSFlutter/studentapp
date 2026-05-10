import 'package:flutter/widgets.dart';

/// Marks widget subtree rendered as a bottom-navigation root tab.
class BottomNavScope extends InheritedWidget {
  const BottomNavScope({
    super.key,
    required super.child,
    this.isBottomNavRoot = true,
  });

  final bool isBottomNavRoot;

  static bool isInBottomNavRoot(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BottomNavScope>();
    return scope?.isBottomNavRoot ?? false;
  }

  @override
  bool updateShouldNotify(BottomNavScope oldWidget) =>
      oldWidget.isBottomNavRoot != isBottomNavRoot;
}
