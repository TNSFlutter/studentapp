// Response for `GET timetable/{yyyy-MM-dd}?limit=`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

class TimetableResponse {
  final bool success;
  final String message;
  final TimetableData? data;
  final TimetablePagination pagination;

  TimetableResponse({
    required this.success,
    required this.message,
    this.data,
    required this.pagination,
  });

  factory TimetableResponse.fromJson(Map<String, dynamic> json) {
    final pRaw = json['pagination'];
    return TimetableResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? TimetableData.fromJson(Map<String, dynamic>.from(json['data'] as Map))
          : null,
      pagination: pRaw is Map<String, dynamic>
          ? TimetablePagination.fromJson(Map<String, dynamic>.from(pRaw as Map))
          : TimetablePagination.empty(),
    );
  }
}

class TimetablePagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  TimetablePagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory TimetablePagination.empty() => TimetablePagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory TimetablePagination.fromJson(Map<String, dynamic> json) {
    return TimetablePagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class ClassSection {
  final int id;
  final String name;

  ClassSection({required this.id, required this.name});

  factory ClassSection.fromJson(Map<String, dynamic> json) {
    return ClassSection(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class TimetableData {
  final String date;
  final String formattedDate;
  final String dayId;
  final String dayName;
  final ClassSection? classSection;
  final List<TimetableEntry> timetable;

  TimetableData({
    required this.date,
    required this.formattedDate,
    required this.dayId,
    required this.dayName,
    this.classSection,
    required this.timetable,
  });

  factory TimetableData.fromJson(Map<String, dynamic> json) {
    // API returns data.shifts[].periods[] — flatten all periods across all shifts.
    final entries = <TimetableEntry>[];
    final shifts = json['shifts'];
    if (shifts is List) {
      for (final shiftRaw in shifts) {
        if (shiftRaw is! Map) continue;
        final shiftMap = Map<String, dynamic>.from(shiftRaw);
        final shift = TimetableShift.fromJson(shiftMap);
        final periods = shiftMap['periods'];
        if (periods is List) {
          for (final p in periods) {
            if (p is! Map) continue;
            entries.add(TimetableEntry._fromPeriodWithShift(
              Map<String, dynamic>.from(p),
              shift,
            ));
          }
        }
      }
    }
    return TimetableData(
      date: json['date']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString() ??
          json['short_formatted_date']?.toString() ??
          json['date']?.toString() ?? '',
      dayId: json['day_id']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? '',
      classSection: json['class_section'] is Map<String, dynamic>
          ? ClassSection.fromJson(
              Map<String, dynamic>.from(json['class_section'] as Map),
            )
          : null,
      timetable: entries,
    );
  }
}

class TimetableShift {
  final int id;
  final String name;
  final String formattedStartTime;
  final String formattedEndTime;

  TimetableShift({
    required this.id,
    required this.name,
    required this.formattedStartTime,
    required this.formattedEndTime,
  });

  factory TimetableShift.fromJson(Map<String, dynamic> json) {
    return TimetableShift(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      formattedStartTime: json['formatted_start_time']?.toString() ?? '',
      formattedEndTime: json['formatted_end_time']?.toString() ?? '',
    );
  }
}

class TimetablePeriod {
  final int id;
  final String name;
  final String formattedStartTime;
  final String formattedEndTime;
  final int half;
  final String halfName;

  TimetablePeriod({
    required this.id,
    required this.name,
    required this.formattedStartTime,
    required this.formattedEndTime,
    required this.half,
    required this.halfName,
  });

  factory TimetablePeriod.fromJson(Map<String, dynamic> json) {
    return TimetablePeriod(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      formattedStartTime: json['formatted_start_time']?.toString() ?? '',
      formattedEndTime: json['formatted_end_time']?.toString() ?? '',
      half: _asInt(json['half']),
      halfName: json['half_name']?.toString() ?? '',
    );
  }
}

class TimetableStaff {
  final int? id;
  final String? name;
  final String? employeeNumber;

  TimetableStaff({this.id, this.name, this.employeeNumber});

  factory TimetableStaff.fromJson(Map<String, dynamic> json) {
    final nameStr = json['name']?.toString().trim();
    final empStr = json['employee_number']?.toString().trim();
    return TimetableStaff(
      id: json['id'] == null ? null : _asInt(json['id']),
      name: (nameStr == null || nameStr.isEmpty) ? null : nameStr,
      employeeNumber: (empStr == null || empStr.isEmpty) ? null : empStr,
    );
  }
}

class TimetableSubject {
  final int id;
  final String name;
  final String shortName;

  TimetableSubject({
    required this.id,
    required this.name,
    required this.shortName,
  });

  factory TimetableSubject.fromJson(Map<String, dynamic> json) {
    return TimetableSubject(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      shortName: json['short_name']?.toString() ?? '',
    );
  }
}

class TimetableEntry {
  final int id;
  final TimetableShift shift;
  final TimetablePeriod period;
  final TimetableStaff staff;
  final TimetableSubject subject;

  TimetableEntry({
    required this.id,
    required this.shift,
    required this.period,
    required this.staff,
    required this.subject,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: _asInt(json['id']),
      shift: json['shift'] is Map<String, dynamic>
          ? TimetableShift.fromJson(
              Map<String, dynamic>.from(json['shift'] as Map),
            )
          : TimetableShift(
              id: 0,
              name: '',
              formattedStartTime: '',
              formattedEndTime: '',
            ),
      period: json['period'] is Map<String, dynamic>
          ? TimetablePeriod.fromJson(
              Map<String, dynamic>.from(json['period'] as Map),
            )
          : TimetablePeriod(
              id: 0,
              name: '',
              formattedStartTime: '',
              formattedEndTime: '',
              half: 0,
              halfName: '',
            ),
      staff: json['staff'] is Map<String, dynamic>
          ? TimetableStaff.fromJson(
              Map<String, dynamic>.from(json['staff'] as Map),
            )
          : TimetableStaff(),
      subject: json['subject'] is Map<String, dynamic>
          ? TimetableSubject.fromJson(
              Map<String, dynamic>.from(json['subject'] as Map),
            )
          : TimetableSubject(id: 0, name: '', shortName: ''),
    );
  }

  factory TimetableEntry._fromPeriodWithShift(
    Map<String, dynamic> json,
    TimetableShift shift,
  ) {
    return TimetableEntry(
      id: _asInt(json['id']),
      shift: shift,
      period: json['period'] is Map<String, dynamic>
          ? TimetablePeriod.fromJson(
              Map<String, dynamic>.from(json['period'] as Map),
            )
          : TimetablePeriod(
              id: 0,
              name: '',
              formattedStartTime: '',
              formattedEndTime: '',
              half: 0,
              halfName: '',
            ),
      staff: json['staff'] is Map<String, dynamic>
          ? TimetableStaff.fromJson(
              Map<String, dynamic>.from(json['staff'] as Map),
            )
          : TimetableStaff(),
      subject: json['subject'] is Map<String, dynamic>
          ? TimetableSubject.fromJson(
              Map<String, dynamic>.from(json['subject'] as Map),
            )
          : TimetableSubject(id: 0, name: '', shortName: ''),
    );
  }
}
