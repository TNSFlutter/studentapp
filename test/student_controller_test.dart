import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:studentapp/controllers/student_controller.dart';
import 'package:studentapp/models/student_models.dart';

void main() {
  group('StudentController.dashboardMapForSelectedStudent', () {
    test('includes attendance status for the selected student', () {
      final controller = StudentController();
      controller.students.assignAll([
        Student(
          studentId: 10,
          isSelected: true,
          classStudentId: 20,
          student: 'Aarav Sharma',
          dob: '2015-01-01',
          classSection: '5-A',
          rollNo: 7,
          admissionNo: 'ADM-10',
          admissionDate: '2020-04-01',
          schoolName: 'XScholar School',
          session: '2025-2026',
          isActive: true,
          attendanceToday: 'Present',
          pendingFee: 0,
          homeworkDueCount: 0,
          notificationsNewCount: 0,
        ),
      ]);
      controller.selectedStudentIndex.value = 0;

      final map = controller.dashboardMapForSelectedStudent();

      expect(map['attendanceToday'], 'Present');
    });
  });
}
