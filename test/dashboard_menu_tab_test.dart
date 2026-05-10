import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:studentapp/helpers/app_feature_guide.dart';
import 'package:studentapp/l10n/app_translations.dart';
import 'package:studentapp/views/dashboard/dashboard_screen.dart';
import 'package:studentapp/views/more/more_screen.dart';
import 'package:studentapp/views/profile/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dashboard index 4 shows Menu screen', (tester) async {
    AppFeatureGuide.debugCompletionOverride = true;
    addTearDown(() => AppFeatureGuide.debugCompletionOverride = null);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en'),
        home: const DashboardScreen(
          initialNavIndex: 4,
          selectedStudent: {
            'name': 'Aarav Sharma',
            'class': '5-A',
            'rollNumber': '7',
            'academicYear': '2025-2026',
            'photo': '',
            'schoolName': 'XScholar School',
            'classStudentId': 20,
            'attendanceToday': 'Present',
            'admissionNo': 'ADM-10',
          },
        ),
      ),
    );

    expect(find.byType(MoreScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.textContaining(', Aarav Sharma'), findsOneWidget);
    expect(
      find.text('Class 5-A | Roll No: 7 | Adm No: ADM-10'),
      findsOneWidget,
    );
  });
}
