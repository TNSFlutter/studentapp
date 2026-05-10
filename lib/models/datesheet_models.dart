// Response for `GET datesheets?limit=&cursor=`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

class DatesheetsApiResponse {
  final bool success;
  final String message;
  final DatesheetNextExam? nextExam;
  final List<DatesheetExamType> examTypes;
  final DatesheetPagination pagination;

  DatesheetsApiResponse({
    required this.success,
    required this.message,
    this.nextExam,
    required this.examTypes,
    required this.pagination,
  });

  factory DatesheetsApiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <DatesheetExamType>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(DatesheetExamType.fromJson(e));
        } else if (e is Map) {
          list.add(DatesheetExamType.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    DatesheetNextExam? next;
    final nRaw = json['next_exam'];
    if (nRaw is Map<String, dynamic>) {
      next = DatesheetNextExam.fromJson(nRaw);
    } else if (nRaw is Map) {
      next = DatesheetNextExam.fromJson(Map<String, dynamic>.from(nRaw));
    }

    final pRaw = json['pagination'];
    return DatesheetsApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      nextExam: next,
      examTypes: list,
      pagination: pRaw is Map<String, dynamic>
          ? DatesheetPagination.fromJson(Map<String, dynamic>.from(pRaw as Map))
          : DatesheetPagination.empty(),
    );
  }
}

class DatesheetPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  DatesheetPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory DatesheetPagination.empty() => DatesheetPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory DatesheetPagination.fromJson(Map<String, dynamic> json) {
    return DatesheetPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

/// Global “next exam” strip — independent of selected tab.
class DatesheetNextExam {
  final int examTypeId;
  final String examName;
  final int scheduleId;
  final int subjectId;
  final String subjectName;
  final String date;
  final String formattedDate;
  final String shortFormattedDate;
  final String day;
  final String time;
  final String? endTime;
  final String? formattedEndTime;
  final int? roomId;
  final int daysUntil;
  final String status;

  DatesheetNextExam({
    required this.examTypeId,
    required this.examName,
    required this.scheduleId,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.formattedDate,
    required this.shortFormattedDate,
    required this.day,
    required this.time,
    this.endTime,
    this.formattedEndTime,
    this.roomId,
    required this.daysUntil,
    required this.status,
  });

  factory DatesheetNextExam.fromJson(Map<String, dynamic> json) {
    return DatesheetNextExam(
      examTypeId: _asInt(json['exam_type_id']),
      examName: json['exam_name']?.toString() ?? '',
      scheduleId: _asInt(json['schedule_id']),
      subjectId: _asInt(json['subject_id']),
      subjectName: json['subject_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString() ?? '',
      shortFormattedDate: json['short_formatted_date']?.toString() ??
          json['formatted_date']?.toString() ??
          '',
      day: json['day']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      endTime: json['end_time']?.toString(),
      formattedEndTime: json['formatted_end_time']?.toString(),
      roomId: json['room_id'] == null ? null : _asInt(json['room_id']),
      daysUntil: _asInt(json['days_until']),
      status: json['status']?.toString() ?? '',
    );
  }
}

/// One exam type block (tab) with subject rows.
class DatesheetExamType {
  final int examTypeId;
  final String examName;
  final String? shortName;
  final String nameAlias;
  final String? description;
  final bool isCurrent;
  final int sortOrder;
  final String startDate;
  final String endDate;
  final List<DatesheetSubjectRow> subjects;

  DatesheetExamType({
    required this.examTypeId,
    required this.examName,
    this.shortName,
    required this.nameAlias,
    this.description,
    required this.isCurrent,
    required this.sortOrder,
    required this.startDate,
    required this.endDate,
    required this.subjects,
  });

  String get displayName {
    final a = nameAlias.trim();
    if (a.isNotEmpty) return a;
    return examName.trim();
  }

  factory DatesheetExamType.fromJson(Map<String, dynamic> json) {
    final subs = <DatesheetSubjectRow>[];
    final raw = json['subjects'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          subs.add(DatesheetSubjectRow.fromJson(e));
        } else if (e is Map) {
          subs.add(DatesheetSubjectRow.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    subs.sort((a, b) {
      final bySort = a.sortOrder.compareTo(b.sortOrder);
      if (bySort != 0) return bySort;
      return a.date.compareTo(b.date);
    });

    return DatesheetExamType(
      examTypeId: _asInt(json['exam_type_id']),
      examName: json['exam_name']?.toString() ?? '',
      shortName: json['short_name']?.toString(),
      nameAlias: json['name_alias']?.toString() ?? '',
      description: json['description']?.toString(),
      isCurrent: json['is_current'] == true,
      sortOrder: _asInt(json['sort_order']),
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      subjects: subs,
    );
  }
}

/// Single exam slot in the datesheet list.
class DatesheetSubjectRow {
  final int scheduleId;
  final String name;
  final String? nameAlias;
  final int subjectId;
  final String subjectName;
  final String date;
  final String formattedDate;
  final String day;
  final String time;
  final String? endTime;
  final String? formattedEndTime;
  final String? description;
  final int sortOrder;
  final int? roomId;
  final String status;
  final int daysUntil;

  DatesheetSubjectRow({
    required this.scheduleId,
    required this.name,
    this.nameAlias,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.formattedDate,
    required this.day,
    required this.time,
    this.endTime,
    this.formattedEndTime,
    this.description,
    required this.sortOrder,
    this.roomId,
    required this.status,
    required this.daysUntil,
  });

  factory DatesheetSubjectRow.fromJson(Map<String, dynamic> json) {
    return DatesheetSubjectRow(
      scheduleId: _asInt(json['schedule_id']),
      name: json['name']?.toString() ?? '',
      nameAlias: json['name_alias']?.toString(),
      subjectId: _asInt(json['subject_id']),
      subjectName: json['subject_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      endTime: json['end_time']?.toString(),
      formattedEndTime: json['formatted_end_time']?.toString(),
      description: json['description']?.toString(),
      sortOrder: _asInt(json['sort_order']),
      roomId: json['room_id'] == null ? null : _asInt(json['room_id']),
      status: json['status']?.toString().toLowerCase() ?? '',
      daysUntil: _asInt(json['days_until']),
    );
  }

  bool get isDone => status == 'done';

  bool get isUpcoming => status == 'upcoming';
}
