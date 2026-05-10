import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:studentapp/controllers/student_controller.dart';
import 'package:studentapp/controllers/student_profile_controller.dart';
import 'package:studentapp/l10n/app_translations.dart';
import 'package:studentapp/views/fees/fee_screen.dart';
import 'package:studentapp/views/message/message_screen.dart';
import 'package:studentapp/views/profile/profile_screen.dart';

/// Avoids real HTTP during widget tests (binding returns HTTP 400 for clients).
class _TestStudentProfileController extends StudentProfileController {
  _TestStudentProfileController() : super();

  @override
  Future<void> refreshProfile() async {
    isLoading.value = false;
    loadError.value = '';
  }
}

class _TestStudentController extends StudentController {
  @override
  Future<void> fetchStudents() async {}
}

void main() {
  tearDown(Get.reset);

  Widget profileApp() {
    return GetMaterialApp(
      translations: AppTranslations(),
      locale: const Locale('en'),
      home: ProfileScreen(
        selectedStudent: {
          'name': 'Test Student',
          'class': 'Class 1-A',
          'rollNumber': '1',
        },
      ),
    );
  }

  testWidgets('ProfileScreen builds', (tester) async {
    Get.put<StudentProfileController>(_TestStudentProfileController());
    Get.put<StudentController>(_TestStudentController());

    await tester.pumpWidget(profileApp());
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
  });

  testWidgets('fee stat opens fee screen', (tester) async {
    Get.put<StudentProfileController>(_TestStudentProfileController());
    Get.put<StudentController>(_TestStudentController());

    await tester.pumpWidget(profileApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('See Fee tab'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(FeeScreen), findsOneWidget);
  });

  testWidgets('messages stat opens notifications screen', (tester) async {
    Get.put<StudentProfileController>(_TestStudentProfileController());
    Get.put<StudentController>(_TestStudentController());

    await tester.pumpWidget(profileApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Messages'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(MessageScreen), findsOneWidget);
  });
}
