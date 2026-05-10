import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Shared theme-aware colors for screens that previously hard-coded light hex values.
abstract final class ThemeAdaptive {
  ThemeAdaptive._();

  static Color pageBackground(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  /// Warm cream in light mode; subtle orange tint on [ColorScheme.surface] in dark mode.
  static Color warmPageBackground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (Theme.of(context).brightness == Brightness.dark) {
      return Color.alphaBlend(
        AppColors.accentOrange.withValues(alpha: 0.10),
        scheme.surface,
      );
    }
    return const Color(0xFFFFF7ED);
  }

  static Color cardShadow(
    BuildContext context, {
    double lightAlpha = 0.06,
    double darkAlpha = 0.32,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Colors.black.withValues(alpha: isDark ? darkAlpha : lightAlpha);
  }

  /// Pastel fills (calendar cells, legends): keep hue in light; blend on surface in dark.
  ///
  /// [darkBlendBase] defaults to [ColorScheme.surfaceContainerHighest]; use
  /// [surfaceContainerHigh] for nested tiles on cards so tints read clearly.
  /// [darkMix] controls saturation on dark surfaces (higher = stronger hue).
  static Color softTint(
    BuildContext context,
    Color lightPastel, {
    double darkMix = 0.42,
    Color? darkBlendBase,
  }) {
    if (Theme.of(context).brightness != Brightness.dark) return lightPastel;
    final scheme = Theme.of(context).colorScheme;
    final base = darkBlendBase ?? scheme.surfaceContainerHighest;
    return Color.alphaBlend(lightPastel.withValues(alpha: darkMix), base);
  }

  /// Neutral chips, icon tile backgrounds, and quick-action squares — subtle in
  /// dark theme (matches “Attendance unknown” style); light grey in light theme.
  static Color neutralFill(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (Theme.of(context).brightness != Brightness.dark) {
      return Colors.grey.shade100;
    }
    final base = scheme.surfaceContainerHigh;
    return Color.alphaBlend(
      AppColors.accentOrange.withValues(alpha: 0.12),
      base,
    );
  }

  static Color neutralFillStrong(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHigh
        : Colors.grey.shade200;
  }
}
