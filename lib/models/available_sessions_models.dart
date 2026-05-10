// Response for `GET student/available-sessions` — shape may vary; parsing is defensive.

bool _truthy(dynamic v, {bool ifNull = false}) {
  if (v == null) return ifNull;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase().trim();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return ifNull;
}

Map<String, dynamic> _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return {};
}

List<Map<String, dynamic>> _sessionRowsFromData(dynamic data) {
  if (data == null) return [];
  if (data is List) {
    return data.map((e) => _asMap(e)).toList();
  }
  if (data is Map) {
    final m = Map<String, dynamic>.from(data);
    for (final key in [
      'sessions',
      'available_sessions',
      'items',
      'records',
      'list',
      'data',
    ]) {
      final inner = m[key];
      if (inner is List) {
        return inner.map((e) => _asMap(e)).toList();
      }
    }
  }
  return [];
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String _str(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  final t = v.toString().trim();
  return t.isEmpty ? fallback : t;
}

/// One selectable academic session from `student/available-sessions`.
class AvailableSessionItem {
  final int? sessionId;
  final String name;
  final String? code;
  final bool isSelected;
  final int? classStudentId;
  final bool isCurrentYear;
  final String? classSection;
  final int? rollNo;
  final String? admissionNo;

  const AvailableSessionItem({
    required this.sessionId,
    required this.name,
    this.code,
    this.isSelected = false,
    this.classStudentId,
    this.isCurrentYear = false,
    this.classSection,
    this.rollNo,
    this.admissionNo,
  });

  factory AvailableSessionItem.fromJson(Map<String, dynamic> json) {
    final id = _asInt(
      json['session_id'] ??
          json['SessionId'] ??
          json['id'] ??
          json['academic_session_id'] ??
          json['AcademicSessionId'],
    );
    String firstLabel() {
      for (final k in [
        'session_name',
        'name',
        'title',
        'label',
        'session',
        'Session',
        'academic_year',
        'AcademicYear',
        'year',
      ]) {
        final s = _str(json[k]);
        if (s.isNotEmpty) return s;
      }
      return '';
    }

    return AvailableSessionItem(
      sessionId: id,
      name: firstLabel(),
      code: _str(json['code'] ?? json['session_code'] ?? json['short_name']),
      isSelected: _truthy(
        json['is_selected'] ??
            json['is_selected_session'] ??
            json['selected'] ??
            json['IsSelected'],
      ),
      classStudentId: _asInt(
        json['class_student_id'] ?? json['ClassStudentID'] ?? json['classStudentId'],
      ),
      isCurrentYear: _truthy(json['is_current_year'] ?? json['is_current'] ?? json['IsCurrentYear']),
      classSection: _nullableStr(json['class_section'] ?? json['ClassSection']),
      rollNo: _asInt(json['roll_no'] ?? json['RollNo'] ?? json['roll_number']),
      admissionNo: _nullableStr(json['admission_no'] ?? json['AdmissionNo']),
    );
  }
}

String? _nullableStr(dynamic v) {
  if (v == null) return null;
  final t = v.toString().trim();
  return t.isEmpty ? null : t;
}

/// Response for `POST student/change-session/{class_student_id}`.
class ChangeSessionData {
  final int studentId;
  final int classStudentId;
  final int? institutionId;
  final int? sessionId;
  final String sessionName;
  final String? classSection;
  final bool isCurrentYear;

  ChangeSessionData({
    required this.studentId,
    required this.classStudentId,
    this.institutionId,
    this.sessionId,
    required this.sessionName,
    this.classSection,
    this.isCurrentYear = false,
  });

  factory ChangeSessionData.fromJson(Map<String, dynamic> json) {
    return ChangeSessionData(
      studentId: _asInt(json['student_id']) ?? 0,
      classStudentId: _asInt(json['class_student_id']) ?? 0,
      institutionId: _asInt(json['institution_id']),
      sessionId: _asInt(json['session_id']),
      sessionName: _str(json['session_name'] ?? json['Session']),
      classSection: _nullableStr(json['class_section']),
      isCurrentYear: _truthy(json['is_current_year']),
    );
  }
}

class ChangeSessionResponse {
  final bool success;
  final String message;
  final ChangeSessionData? data;

  ChangeSessionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChangeSessionResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return ChangeSessionResponse(
      success: _truthy(json['success']),
      message: json['message']?.toString() ?? '',
      data: raw is Map<String, dynamic>
          ? ChangeSessionData.fromJson(raw)
          : (raw is Map
              ? ChangeSessionData.fromJson(Map<String, dynamic>.from(raw))
              : null),
    );
  }

  factory ChangeSessionResponse.failure(String message) => ChangeSessionResponse(
        success: false,
        message: message,
        data: null,
      );
}

class AvailableSessionsResponse {
  final bool success;
  final String message;
  final List<AvailableSessionItem> sessions;

  AvailableSessionsResponse({
    required this.success,
    required this.message,
    required this.sessions,
  });

  factory AvailableSessionsResponse.fromJson(Map<String, dynamic> json) {
    final rows = _sessionRowsFromData(json['data']);
    return AvailableSessionsResponse(
      success: _truthy(json['success']),
      message: json['message']?.toString() ?? '',
      sessions: rows.map(AvailableSessionItem.fromJson).toList(),
    );
  }

  factory AvailableSessionsResponse.failure(String message) =>
      AvailableSessionsResponse(
        success: false,
        message: message,
        sessions: const [],
      );
}
