import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studentapp/views/dashboard/home_screen.dart';
import 'package:studentapp/views/message/message_screen.dart';

void main() {
  testWidgets('dashboard notification icon opens notifications screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(
          selectedStudent: {
            'name': 'Aarav Sharma',
            'class': '5-A',
            'rollNumber': '7',
            'academicYear': '2025-2026',
            'photo': '',
            'schoolName': 'XScholar School',
            'classStudentId': 20,
            'attendanceToday': 'Present',
          },
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(MessageScreen), findsOneWidget);
  });
}
