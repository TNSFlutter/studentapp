import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studentapp/constants/app_colors.dart';
import 'package:studentapp/helpers/themes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppTheme', () {
    test(
      'defines light and dark Material 3 themes with shared brand colors',
      () {
        expect(AppTheme.lightTheme.brightness, Brightness.light);
        expect(AppTheme.darkTheme.brightness, Brightness.dark);

        expect(AppTheme.lightTheme.useMaterial3, isTrue);
        expect(AppTheme.darkTheme.useMaterial3, isTrue);

        expect(AppTheme.lightTheme.colorScheme.primary, AppColors.primaryBlue);
        expect(AppTheme.darkTheme.colorScheme.primary, AppColors.primaryBlue);
        expect(
          AppTheme.lightTheme.colorScheme.secondary,
          AppColors.accentOrange,
        );
        expect(
          AppTheme.darkTheme.colorScheme.secondary,
          AppColors.accentOrange,
        );

        expect(
          AppTheme.lightTheme.scaffoldBackgroundColor,
          isNot(equals(AppTheme.darkTheme.scaffoldBackgroundColor)),
        );
        expect(
          AppTheme.lightTheme.cardTheme.color,
          isNot(equals(AppTheme.darkTheme.cardTheme.color)),
        );
      },
    );
  });
}
