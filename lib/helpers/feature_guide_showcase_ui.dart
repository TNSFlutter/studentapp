import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants/app_colors.dart';
import 'app_feature_guide.dart';

/// Shared visuals for feature tours ([Showcase] + [ShowcaseView.register]).
abstract final class FeatureGuideShowcaseUi {
  FeatureGuideShowcaseUi._();

  static const Color spotlightTint = AppColors.accentOrange;

  /// Full-screen dim (used by [ShowcaseView.register]).
  static Color dashboardDimOverlay(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF020617) : const Color(0xFF0F172A);
  }

  /// Dim overlay for [ShowcaseView.register] when no [BuildContext] exists yet.
  static const Color registerDimOverlay = Color(0xFF0F172A);

  static double get dashboardBlur => 6;

  static double get dashboardDimOpacity => 0.48;

  static double get selectStudentBlur => 5;

  static double get selectStudentDimOpacity => 0.36;

  static EdgeInsets get tooltipPadding =>
      const EdgeInsets.fromLTRB(22, 20, 22, 18);

  static BorderRadius get tooltipRadius => BorderRadius.circular(20);

  static TextStyle dashboardTitleStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -0.35,
      color: scheme.onSurface,
    );
  }

  static TextStyle dashboardDescStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.45,
      color: scheme.onSurfaceVariant,
    );
  }

  static Color dashboardTooltipBg(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHigh
        : scheme.surface;
  }

  /// Dashboard home / bottom-nav tour step.
  static Widget dashboardShowcase({
    required BuildContext context,
    required GlobalKey showcaseKey,
    required String title,
    required String description,
    required Widget child,
  }) {
    return Showcase(
      key: showcaseKey,
      scope: AppFeatureGuide.dashboardShowcaseScope,
      title: title,
      description: description,
      tooltipBackgroundColor: dashboardTooltipBg(context),
      titleTextStyle: dashboardTitleStyle(context),
      descTextStyle: dashboardDescStyle(context),
      tooltipBorderRadius: tooltipRadius,
      tooltipPadding: tooltipPadding,
      overlayColor: spotlightTint,
      overlayOpacity: 0.12,
      targetBorderRadius: BorderRadius.circular(18),
      targetPadding: const EdgeInsets.all(6),
      toolTipMargin: 18,
      movingAnimationDuration: const Duration(milliseconds: 1600),
      child: child,
    );
  }

  /// Select-student first card step (brand-aligned with dashboard).
  static Widget selectStudentCardShowcase({
    required BuildContext context,
    required GlobalKey showcaseKey,
    required String title,
    required String description,
    required Widget child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Showcase(
      key: showcaseKey,
      scope: AppFeatureGuide.selectStudentTourScope,
      title: title,
      description: description,
      tooltipBackgroundColor: dashboardTooltipBg(context),
      titleTextStyle: dashboardTitleStyle(context),
      descTextStyle: dashboardDescStyle(context),
      tooltipBorderRadius: tooltipRadius,
      tooltipPadding: tooltipPadding,
      overlayColor: spotlightTint,
      overlayOpacity: 0.14,
      targetBorderRadius: BorderRadius.circular(16),
      targetPadding: const EdgeInsets.all(4),
      toolTipMargin: 16,
      movingAnimationDuration: const Duration(milliseconds: 1600),
      textColor: scheme.onSurface,
      child: child,
    );
  }
}
