Map<String, dynamic> _mapFrom(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

/// Normalizes API `data` whether it is a raw list or an object wrapping a list.
List<Map<String, dynamic>> _studentListPayload(dynamic data) {
  if (data == null) return [];
  if (data is List) {
    return data.map((e) => _mapFrom(e)).toList();
  }
  if (data is Map) {
    final m = Map<String, dynamic>.from(data);
    for (final key in ['students', 'data', 'items', 'records', 'list']) {
      final inner = m[key];
      if (inner is List) {
        return inner.map((e) => _mapFrom(e)).toList();
      }
    }
  }
  return [];
}

String? _optionalPhoto(String raw) {
  final t = raw.trim();
  return t.isEmpty ? null : t;
}

String? _optionalTrimmed(dynamic v) {
  if (v == null) return null;
  final t = v.toString().trim();
  return t.isEmpty ? null : t;
}

/// Treats common API truthy forms (`true`, `1`, `"true"`) as success.
bool _apiTruthy(dynamic v, {bool ifNull = false}) {
  if (v == null) return ifNull;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase().trim();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return ifNull;
}

class GetStudentsResponse {
  final bool success;
  final String message;
  final List<Student> data;

  GetStudentsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GetStudentsResponse.fromJson(Map<String, dynamic> json) {
    final rows = _studentListPayload(json['data']);
    return GetStudentsResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: rows.map(Student.fromJson).toList(),
    );
  }
}

class Student {
  final int studentId;
  final bool isSelected;
  final int? classStudentId;
  final String student;
  final int? gender;
  final String dob;
  final String? photo;
  final int? classSectionId;
  final String? classSection;
  final int? rollNo;
  final String admissionNo;
  final String admissionDate;
  final String schoolName;
  final String session;
  final String? initials;
  final bool isActive;
  final String attendanceToday;
  final int pendingFee;
  final int homeworkDueCount;
  final int notificationsNewCount;

  Student({
    required this.studentId,
    required this.isSelected,
    this.classStudentId,
    required this.student,
    this.gender,
    required this.dob,
    this.photo,
    this.classSectionId,
    this.classSection,
    this.rollNo,
    required this.admissionNo,
    required this.admissionDate,
    required this.schoolName,
    required this.session,
    this.initials,
    required this.isActive,
    required this.attendanceToday,
    required this.pendingFee,
    required this.homeworkDueCount,
    required this.notificationsNewCount,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    bool asBool(dynamic v, [bool fallback = false]) {
      if (v == null) return fallback;
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes';
    }

    String firstStr(List<String> keys, [String fallback = '']) {
      for (final k in keys) {
        final v = json[k];
        if (v == null) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty) return s;
      }
      return fallback;
    }

    final sid =
        asInt(
          json['student_id'] ??
              json['StudentID'] ??
              json['Student_Id'] ??
              json['id'],
        ) ??
        0;

    return Student(
      studentId: sid,
      isSelected: asBool(
        json['is_selected'] ?? json['IsSelected'] ?? json['selected'],
      ),
      classStudentId: asInt(
        json['class_student_id'] ??
            json['ClassStudentID'] ??
            json['ClassStudent_Id'],
      ),
      student: firstStr([
        'student',
        'Student',
        'student_name',
        'StudentName',
        'Name',
        'name',
        'full_name',
      ]),
      gender: asInt(json['gender'] ?? json['Gender']),
      dob: firstStr(['dob', 'DOB', 'date_of_birth']),
      photo: _optionalPhoto(firstStr(['photo', 'Photo', 'image', 'Image'])),
      classSectionId: asInt(json['class_section_id'] ?? json['ClassSectionID']),
      classSection: _optionalTrimmed(
        json['class_section'] ?? json['ClassSection'],
      ),
      rollNo: asInt(json['roll_no'] ?? json['RollNo'] ?? json['roll_number']),
      admissionNo: firstStr(['admission_no', 'AdmissionNo', 'Admission_No']),
      admissionDate: firstStr(['admission_date', 'AdmissionDate']),
      schoolName: firstStr(['SchoolName', 'school_name', 'school', 'School']),
      session: firstStr([
        'Session',
        'session',
        'academic_year',
        'AcademicYear',
      ]),
      initials: _optionalTrimmed(json['initials'] ?? json['Initials']),
      isActive: asBool(json['is_active'] ?? json['isActive'], true),
      attendanceToday: firstStr([
        'attendance_today',
        'attendanceToday',
      ], 'unknown'),
      pendingFee: asInt(json['pending_fee'] ?? json['pendingFee']) ?? 0,
      homeworkDueCount:
          asInt(json['homework_due_count'] ?? json['homeworkDueCount']) ?? 0,
      notificationsNewCount:
          asInt(
            json['notifications_new_count'] ?? json['notificationsNewCount'],
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'is_selected': isSelected,
      'class_student_id': classStudentId,
      'student': student,
      'gender': gender,
      'dob': dob,
      'photo': photo,
      'class_section_id': classSectionId,
      'class_section': classSection,
      'roll_no': rollNo,
      'admission_no': admissionNo,
      'admission_date': admissionDate,
      'SchoolName': schoolName,
      'Session': session,
      'initials': initials,
      'is_active': isActive,
      'attendance_today': attendanceToday,
      'pending_fee': pendingFee,
      'homework_due_count': homeworkDueCount,
      'notifications_new_count': notificationsNewCount,
    };
  }
}

class SelectStudentResponse {
  final bool success;
  final String message;
  final SelectStudentData data;

  SelectStudentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SelectStudentResponse.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    final topOk = _apiTruthy(json['success']);

    final SelectStudentData data;
    if (dataRaw is Map) {
      data = SelectStudentData.fromJson(Map<String, dynamic>.from(dataRaw));
    } else if (topOk) {
      // Select endpoints may return `data: null`, `[]`, or an empty primitive
      // while the top-level success flag confirms the selection.
      data = SelectStudentData(success: true, message: '');
    } else {
      data = SelectStudentData(
        success: false,
        message: dataRaw == null ? 'Missing data' : 'Invalid data',
      );
    }

    return SelectStudentResponse(
      success: topOk,
      message: json['message']?.toString() ?? '',
      data: data,
    );
  }
}

class SelectStudentData {
  final bool success;
  final String message;

  SelectStudentData({required this.success, required this.message});

  factory SelectStudentData.fromJson(Map<String, dynamic> json) {
    return SelectStudentData(
      success: json.containsKey('success') ? _apiTruthy(json['success']) : true,
      message: json['message']?.toString() ?? '',
    );
  }
}
