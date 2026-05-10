import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/app_snackbar.dart';
import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/available_sessions_models.dart';
import '../models/student_models.dart';
import 'student_profile_controller.dart';

class StudentController extends GetxController {
  // Observable variables
  final RxList<Student> students = <Student>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSelectingStudent = false.obs;
  final RxInt selectedStudentIndex = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  /// Fetch students from API
  Future<void> fetchStudents() async {
    try {
      isLoading.value = true;

      final response = await NetworkManager.instance.getDio().get(
        Endpoints.getStudents,
      );

      if (response.statusCode == 200) {
        final getStudentsResponse = GetStudentsResponse.fromJson(response.data);

        if (getStudentsResponse.success) {
          students.assignAll(getStudentsResponse.data);

          // Find the selected student
          for (int i = 0; i < students.length; i++) {
            if (students[i].isSelected) {
              selectedStudentIndex.value = i;
              break;
            }
          }
        } else {
          AppSnackbar.showSnackbar(
            'Error',
            getStudentsResponse.message,
            AlertType.error,
          );
        }
      } else {
        AppSnackbar.showSnackbar(
          'Error',
          'Failed to fetch students',
          AlertType.error,
        );
      }
    } catch (e) {
      AppSnackbar.showSnackbar(
        'Error',
        'Error fetching students: ${e.toString()}',
        AlertType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Select a student on the server. Returns `true` only when the API confirms success.
  Future<bool> selectStudent(int studentId) async {
    try {
      isSelectingStudent.value = true;

      final response = await NetworkManager.instance.getDio().get(
        Endpoints.selectStudent(studentId),
      );

      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        AppSnackbar.showSnackbar(
          'Error',
          'Failed to select student',
          AlertType.error,
        );
        return false;
      }

      final SelectStudentResponse selectStudentResponse;
      try {
        final payload = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{
                'success': true,
                'message': '',
                'data': response.data,
              };
        selectStudentResponse = SelectStudentResponse.fromJson(payload);
      } catch (e) {
        AppSnackbar.showSnackbar(
          'Error',
          'Invalid response when selecting student: $e',
          AlertType.error,
        );
        return false;
      }

      final inner = selectStudentResponse.data.success;
      if (selectStudentResponse.success && inner) {
        // Do not show Get.snackbar here: the next screen replaces this route
        // immediately and causes "No Overlay widget found" with Get.snackbar.

        for (int i = 0; i < students.length; i++) {
          students[i] = Student(
            studentId: students[i].studentId,
            isSelected: students[i].studentId == studentId,
            classStudentId: students[i].classStudentId,
            student: students[i].student,
            gender: students[i].gender,
            dob: students[i].dob,
            photo: students[i].photo,
            classSectionId: students[i].classSectionId,
            classSection: students[i].classSection,
            rollNo: students[i].rollNo,
            admissionNo: students[i].admissionNo,
            admissionDate: students[i].admissionDate,
            schoolName: students[i].schoolName,
            session: students[i].session,
            initials: students[i].initials,
            isActive: students[i].isActive,
            attendanceToday: students[i].attendanceToday,
            pendingFee: students[i].pendingFee,
            homeworkDueCount: students[i].homeworkDueCount,
            notificationsNewCount: students[i].notificationsNewCount,
          );
        }

        for (int i = 0; i < students.length; i++) {
          if (students[i].studentId == studentId) {
            selectedStudentIndex.value = i;
            break;
          }
        }
        return true;
      }

      final msg = selectStudentResponse.data.message.isNotEmpty
          ? selectStudentResponse.data.message
          : (selectStudentResponse.message.isNotEmpty
                ? selectStudentResponse.message
                : 'Could not select student');
      AppSnackbar.showSnackbar('Error', msg, AlertType.error);
      return false;
    } catch (e) {
      AppSnackbar.showSnackbar(
        'Error',
        'Error selecting student: ${e.toString()}',
        AlertType.error,
      );
      return false;
    } finally {
      isSelectingStudent.value = false;
    }
  }

  /// Get the selected student
  Student? get selectedStudent {
    if (selectedStudentIndex.value >= 0 &&
        selectedStudentIndex.value < students.length) {
      return students[selectedStudentIndex.value];
    }
    return null;
  }

  /// `GET student/available-sessions` — academic sessions the API exposes for the current context.
  Future<AvailableSessionsResponse> fetchAvailableSessions() async {
    try {
      final response = await NetworkManager.instance.getDio().get(
        Endpoints.studentAvailableSessions,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return AvailableSessionsResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return AvailableSessionsResponse.failure(
        'Failed to load available sessions.',
      );
    } catch (e) {
      return AvailableSessionsResponse.failure(e.toString());
    }
  }

  /// `POST student/change-session/{class_student_id}` — switch active session for the current student.
  Future<ChangeSessionResponse> changeSession(int classStudentId) async {
    try {
      final response = await NetworkManager.instance.getDio().post(
        Endpoints.studentChangeSession(classStudentId),
      );
      if (response.statusCode == 200 && response.data is Map) {
        return ChangeSessionResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return ChangeSessionResponse.failure('Failed to change session.');
    } catch (e) {
      final msg = e is DioException
          ? ApiErrorHelper.dioOrFallback(e)
          : e.toString();
      return ChangeSessionResponse.failure(msg);
    }
  }

  /// Map passed to [DashboardScreen] / [HomeScreen] from the currently selected [Student].
  Map<String, dynamic> dashboardMapForSelectedStudent() {
    final s = selectedStudent;
    if (s == null) return {};
    return {
      'id': s.studentId,
      'name': s.student,
      'class': s.classSection ?? 'No Class',
      'rollNumber': s.rollNo?.toString() ?? 'N/A',
      'admissionNo': s.admissionNo,
      'academicYear': s.session,
      'photo': s.photo ?? '',
      'schoolName': s.schoolName,
      'classStudentId': s.classStudentId,
      'attendanceToday': s.attendanceToday,
    };
  }

  /// Refreshes student list and profile cache after session switch.
  Future<void> refreshAfterSessionChange() async {
    if (Get.isRegistered<StudentProfileController>()) {
      Get.find<StudentProfileController>().clearCache();
    }
    await fetchStudents();
  }

  /// Check if a student is present (mock logic - you can implement actual attendance logic)
  bool isStudentPresent(Student student) {
    final v = student.attendanceToday.trim().toLowerCase();
    if (v == 'present' || v == 'p') return true;
    if (v == 'absent' || v == 'a') return false;
    // Unknown/missing attendance defaults to present-style neutral handling in UI.
    return true;
  }
}
