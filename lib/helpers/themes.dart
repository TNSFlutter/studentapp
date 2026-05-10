import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const Color brandOrange = AppColors.accentOrange;
  static const Color lightScaffold = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  /// Deep ink-navy page chrome (below cards / bottom nav surface).
  static const Color darkScaffold = Color(0xFF060912);
  /// Primary elevated surface for cards, sheets, bottom navigation (readable on scaffold).
  static const Color darkSurface = Color(0xFF121A2C);

  static final ThemeData lightTheme = _theme(Brightness.light);
  static final ThemeData darkTheme = _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryBlue,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primaryBlue,
          onPrimary: Colors.white,
          secondary: brandOrange,
          onSecondary: Colors.white,
          surface: isDark ? darkSurface : lightSurface,
          onSurface: isDark ? const Color(0xFFE8EAEF) : const Color(0xFF111827),
          onSurfaceVariant:
              isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
          surfaceContainerLow: isDark
              ? const Color(0xFF0B1220)
              : const Color(0xFFF1F5F9),
          surfaceContainerHigh: isDark
              ? const Color(0xFF1F2A3F)
              : const Color(0xFFEEF2F7),
          surfaceContainerHighest: isDark
              ? const Color(0xFF2A354E)
              : const Color(0xFFF8FAFC),
          outline: isDark ? const Color(0xFF4B5E78) : const Color(0xFFD1D5DB),
          outlineVariant: isDark
              ? const Color(0xFF354356)
              : const Color(0xFFE5E7EB),
          error: const Color(0xFFDC2626),
        );

    final base = ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      useMaterial3: true,
    );
    final textTheme = GoogleFonts.notoSansTextTheme(base.textTheme).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return base.copyWith(
      scaffoldBackgroundColor: isDark ? darkScaffold : lightScaffold,
      primaryColor: AppColors.primaryBlue,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: brandOrange,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.28 : 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: brandOrange,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: brandOrange, width: 1.4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? brandOrange
              : colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? brandOrange.withValues(alpha: 0.32)
              : colorScheme.surfaceContainerHighest;
        }),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: brandOrange,
        headerForegroundColor: Colors.white,
        weekdayStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        dayStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return colorScheme.onSurface;
        }),
        todayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return brandOrange;
        }),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: brandOrange),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: brandOrange),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

@Deprecated('Use AppTheme.lightTheme instead.')
ThemeData lightThemeData(BuildContext context) => AppTheme.lightTheme;

@Deprecated('Use AppColors/AppTheme instead.')
class MyColors {
  static const Color primaryColor1 = AppColors.primaryYellowColor;
}

TextStyle feesStyle = const TextStyle(
  fontSize: 14,
  color: Colors.black54,
  fontWeight: FontWeight.w700,
);
