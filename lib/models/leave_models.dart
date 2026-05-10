int _intVal(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

String _strVal(dynamic v, {String fallback = ''}) {
  if (v == null) return fallback;
  return v.toString();
}

String? _optionalString(dynamic v) {
  final t = _strVal(v).trim();
  return t.isEmpty ? null : t;
}

class LeaveType {
  final int id;
  final String name;
  final bool requiresDocument;
  final int daysPerYear;
  final int daysUsed;
  final int daysRemaining;

  LeaveType({
    required this.id,
    required this.name,
    required this.requiresDocument,
    required this.daysPerYear,
    this.daysUsed = 0,
    this.daysRemaining = 0,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) => LeaveType(
        id: _intVal(json['id']),
        name: _strVal(json['name']),
        requiresDocument: json['requires_document'] == true,
        daysPerYear: _intVal(json['days_per_year']),
        daysUsed: _intVal(json['days_used']),
        daysRemaining: _intVal(json['days_remaining']),
      );
}

class LeaveListSummary {
  final int total;
  final int approved;
  final int pending;
  final int rejected;

  const LeaveListSummary({
    required this.total,
    required this.approved,
    required this.pending,
    required this.rejected,
  });

  factory LeaveListSummary.fromJson(Map<String, dynamic> json) =>
      LeaveListSummary(
        total: _intVal(json['total']),
        approved: _intVal(json['approved']),
        pending: _intVal(json['pending']),
        rejected: _intVal(json['rejected']),
      );

  factory LeaveListSummary.empty() => const LeaveListSummary(
        total: 0,
        approved: 0,
        pending: 0,
        rejected: 0,
      );
}

class LeavePagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  const LeavePagination({
    required this.total,
    required this.limit,
    required this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory LeavePagination.fromJson(Map<String, dynamic> json) => LeavePagination(
        total: _intVal(json['total']),
        limit: _intVal(json['limit'], fallback: 10),
        nextCursor: _optionalString(json['next_cursor']),
        hasNextPage: json['has_next_page'] == true,
        hasPrevPage: json['has_prev_page'] == true,
      );

  factory LeavePagination.empty() => const LeavePagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );
}

class LeaveItem {
  final int id;
  final LeaveType leaveType;
  final String fromDate;
  final String toDate;
  final int totalDays;
  final String description;
  final String? documentUrl;
  final String status;
  final String? remarks;
  final String? approvedBy;
  final String? approvedOn;
  final String formattedFromDate;
  final String formattedToDate;
  final String formattedDateRange;
  final String formattedApprovedOn;
  final String createdOn;
  final String formattedAppliedOn;

  LeaveItem({
    required this.id,
    required this.leaveType,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.description,
    required this.documentUrl,
    required this.status,
    required this.remarks,
    required this.approvedBy,
    required this.approvedOn,
    required this.formattedFromDate,
    required this.formattedToDate,
    required this.formattedDateRange,
    required this.formattedApprovedOn,
    required this.createdOn,
    required this.formattedAppliedOn,
  });

  factory LeaveItem.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['leave_type'];
    final leaveType = typeRaw is Map<String, dynamic>
        ? LeaveType.fromJson(typeRaw)
        : typeRaw is Map
            ? LeaveType.fromJson(Map<String, dynamic>.from(typeRaw))
            : LeaveType(
                id: 0,
                name: 'Leave',
                requiresDocument: false,
                daysPerYear: 0,
              );
    return LeaveItem(
      id: _intVal(json['id']),
      leaveType: leaveType,
      fromDate: _strVal(json['from_date']),
      toDate: _strVal(json['to_date']),
      totalDays: _intVal(json['total_days']),
      description: _strVal(json['description']),
      documentUrl: _optionalString(json['document_url']),
      status: _strVal(json['status']),
      remarks: _optionalString(json['remarks']),
      approvedBy: _optionalString(json['approved_by']),
      approvedOn: _optionalString(json['approved_on']),
      formattedFromDate: _strVal(json['formatted_from_date']),
      formattedToDate: _strVal(json['formatted_to_date']),
      formattedDateRange: _strVal(json['formatted_date_range']),
      formattedApprovedOn: _strVal(json['formatted_approved_on']),
      createdOn: _strVal(json['created_on']),
      formattedAppliedOn: _strVal(json['formatted_applied_on']),
    );
  }
}

class LeaveListResponse {
  final bool success;
  final String message;
  final LeaveListSummary summary;
  final List<LeaveItem> data;
  final LeavePagination pagination;

  LeaveListResponse({
    required this.success,
    required this.message,
    required this.summary,
    required this.data,
    required this.pagination,
  });

  factory LeaveListResponse.fromJson(Map<String, dynamic> json) {
    final summaryRaw = json['summary'];
    final summary = summaryRaw is Map<String, dynamic>
        ? LeaveListSummary.fromJson(summaryRaw)
        : summaryRaw is Map
            ? LeaveListSummary.fromJson(Map<String, dynamic>.from(summaryRaw))
            : LeaveListSummary.empty();

    final listRaw = json['data'];
    final items = <LeaveItem>[];
    if (listRaw is List) {
      for (final e in listRaw) {
        if (e is Map<String, dynamic>) {
          items.add(LeaveItem.fromJson(e));
        } else if (e is Map) {
          items.add(LeaveItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    final pagRaw = json['pagination'];
    final pagination = pagRaw is Map<String, dynamic>
        ? LeavePagination.fromJson(pagRaw)
        : pagRaw is Map
            ? LeavePagination.fromJson(Map<String, dynamic>.from(pagRaw))
            : LeavePagination.empty();

    return LeaveListResponse(
      success: json['success'] == true,
      message: _strVal(json['message']),
      summary: summary,
      data: items,
      pagination: pagination,
    );
  }

  factory LeaveListResponse.failure(String message) => LeaveListResponse(
        success: false,
        message: message,
        summary: LeaveListSummary.empty(),
        data: const [],
        pagination: LeavePagination.empty(),
      );
}

class LeaveStudentInfo {
  final String name;
  final String initials;
  final String? photo;
  final String classSection;
  final int rollNo;
  final String sessionName;

  LeaveStudentInfo({
    required this.name,
    required this.initials,
    required this.photo,
    required this.classSection,
    required this.rollNo,
    required this.sessionName,
  });

  factory LeaveStudentInfo.fromJson(Map<String, dynamic> json) => LeaveStudentInfo(
        name: _strVal(json['name']),
        initials: _strVal(json['initials']),
        photo: _optionalString(json['photo']),
        classSection: _strVal(json['class_section']),
        rollNo: _intVal(json['roll_no']),
        sessionName: _strVal(json['session_name']),
      );

  factory LeaveStudentInfo.empty() => LeaveStudentInfo(
        name: 'Student',
        initials: 'ST',
        photo: null,
        classSection: '—',
        rollNo: 0,
        sessionName: '',
      );
}

class LeaveTypesResponse {
  final bool success;
  final String message;
  final List<LeaveType> data;
  final LeaveStudentInfo student;

  LeaveTypesResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.student,
  });

  factory LeaveTypesResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final types = <LeaveType>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          types.add(LeaveType.fromJson(e));
        } else if (e is Map) {
          types.add(LeaveType.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final studentRaw = json['student'];
    final student = studentRaw is Map<String, dynamic>
        ? LeaveStudentInfo.fromJson(studentRaw)
        : studentRaw is Map
            ? LeaveStudentInfo.fromJson(Map<String, dynamic>.from(studentRaw))
            : LeaveStudentInfo.empty();
    return LeaveTypesResponse(
      success: json['success'] == true,
      message: _strVal(json['message']),
      data: types,
      student: student,
    );
  }

  factory LeaveTypesResponse.failure(String message) => LeaveTypesResponse(
        success: false,
        message: message,
        data: const [],
        student: LeaveStudentInfo.empty(),
      );
}

class LeaveDetailResponse {
  final bool success;
  final String message;
  final LeaveItem? data;

  LeaveDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LeaveDetailResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return LeaveDetailResponse(
      success: json['success'] == true,
      message: _strVal(json['message']),
      data: raw is Map<String, dynamic>
          ? LeaveItem.fromJson(raw)
          : raw is Map
              ? LeaveItem.fromJson(Map<String, dynamic>.from(raw))
              : null,
    );
  }

  factory LeaveDetailResponse.failure(String message) => LeaveDetailResponse(
        success: false,
        message: message,
        data: null,
      );
}

class LeaveApplyResponse {
  final bool success;
  final String message;
  final LeaveItem? data;

  LeaveApplyResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LeaveApplyResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return LeaveApplyResponse(
      success: json['success'] == true,
      message: _strVal(json['message']),
      data: raw is Map<String, dynamic>
          ? LeaveItem.fromJson(raw)
          : raw is Map
              ? LeaveItem.fromJson(Map<String, dynamic>.from(raw))
              : null,
    );
  }

  factory LeaveApplyResponse.failure(String message) => LeaveApplyResponse(
        success: false,
        message: message,
        data: null,
      );
}

class LeaveActionResponse {
  final bool success;
  final String message;

  const LeaveActionResponse({required this.success, required this.message});

  factory LeaveActionResponse.fromJson(Map<String, dynamic> json) =>
      LeaveActionResponse(
        success: json['success'] == true,
        message: _strVal(json['message']),
      );

  factory LeaveActionResponse.failure(String message) =>
      LeaveActionResponse(success: false, message: message);
}
