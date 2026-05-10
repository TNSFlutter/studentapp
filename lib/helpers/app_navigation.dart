import 'package:flutter/cupertino.dart';

/// Cupertino-style route with slightly longer timings and a softer barrier curve
/// than defaults, so pushes and replacements feel less abrupt.
class _AppCupertinoPageRoute<T> extends PageRoute<T> with CupertinoRouteTransitionMixin<T> {
  _AppCupertinoPageRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog = false,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    super.requestFocus,
    bool maintainStateSetting = true,
  }) : _maintainState = maintainStateSetting;

  final WidgetBuilder builder;
  final bool _maintainState;

  /// A bit longer than stock Cupertino so the outgoing screen eases away visibly.
  static const Duration _forward = Duration(milliseconds: 520);
  static const Duration _reverse = Duration(milliseconds: 420);

  @override
  Duration get transitionDuration => _forward;

  @override
  Duration get reverseTransitionDuration => _reverse;

  @override
  Curve get barrierCurve => Curves.easeOutCubic;

  @override
  String? get title => null;

  @override
  bool get maintainState => _maintainState;

  @override
  Widget buildContent(BuildContext context) => builder(context);

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      fullscreenDialog ? null : CupertinoPageTransition.delegatedTransition;
}

/// Central stack navigation using a Cupertino-style route for consistent
/// horizontal transitions and the interactive pop gesture on iOS.
class AppNavigation {
  AppNavigation._();

  static PageRoute<T> pageRoute<T>(
    Widget Function(BuildContext context) builder, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return _AppCupertinoPageRoute<T>(
      settings: settings,
      builder: builder,
      fullscreenDialog: fullscreenDialog,
    );
  }

  static Future<T?> push<T>(BuildContext context, Widget page, {RouteSettings? settings}) {
    return Navigator.of(context).push<T>(
      pageRoute<T>((_) => page, settings: settings),
    );
  }

  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    TO? result,
    RouteSettings? settings,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      pageRoute<T>((_) => page, settings: settings),
      result: result,
    );
  }

  /// Fade + slight upward slide — smoother handoff from select-student → dashboard.
  static PageRoute<T> pageRouteSmoothEnter<T>(
    Widget Function(BuildContext context) builder, {
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 460),
      reverseTransitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final fade = Tween<double>(begin: 0, end: 1).animate(curved);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.07),
          end: Offset.zero,
        ).animate(curved);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  static Future<T?> pushReplacementSmooth<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    TO? result,
    RouteSettings? settings,
  }) {
    return Navigator.of(context).pushReplacement<T, TO>(
      pageRouteSmoothEnter<T>((_) => page, settings: settings),
      result: result,
    );
  }

  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
    bool Function(Route<dynamic> route) predicate, {
    RouteSettings? settings,
  }) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      pageRoute<T>((_) => page, settings: settings),
      predicate,
    );
  }
}
