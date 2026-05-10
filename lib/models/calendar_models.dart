// Response for `GET calender?month=&year=&limit=`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

class CalendarHolidaysResponse {
  final bool success;
  final String message;
  final CalendarHolidaysData? data;
  final CalendarPagination pagination;

  CalendarHolidaysResponse({
    required this.success,
    required this.message,
    this.data,
    required this.pagination,
  });

  factory CalendarHolidaysResponse.fromJson(Map<String, dynamic> json) {
    final pRaw = json['pagination'];
    return CalendarHolidaysResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? CalendarHolidaysData.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
      pagination: pRaw is Map<String, dynamic>
          ? CalendarPagination.fromJson(
              Map<String, dynamic>.from(pRaw as Map),
            )
          : CalendarPagination.empty(),
    );
  }
}

class CalendarPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  CalendarPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory CalendarPagination.empty() => CalendarPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory CalendarPagination.fromJson(Map<String, dynamic> json) {
    return CalendarPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class CalendarHolidaysData {
  final CalendarStudent? student;
  final List<CalendarMonthBlock> months;

  CalendarHolidaysData({this.student, required this.months});

  factory CalendarHolidaysData.fromJson(Map<String, dynamic> json) {
    final monthsRaw = json['months'];
    final months = <CalendarMonthBlock>[];
    if (monthsRaw is List) {
      for (final e in monthsRaw) {
        if (e is Map<String, dynamic>) {
          months.add(CalendarMonthBlock.fromJson(e));
        }
      }
    }
    return CalendarHolidaysData(
      student: json['student'] is Map<String, dynamic>
          ? CalendarStudent.fromJson(
              Map<String, dynamic>.from(json['student'] as Map),
            )
          : null,
      months: months,
    );
  }

  /// Holidays for a specific year/month, or empty if that block is missing.
  List<CalendarHoliday> holidaysFor(int year, int month) {
    for (final m in months) {
      if (m.year == year && m.monthNumber == month) {
        return m.holidays;
      }
    }
    return [];
  }
}

class CalendarStudent {
  final int studentId;
  final String name;
  final String classSection;

  CalendarStudent({
    required this.studentId,
    required this.name,
    required this.classSection,
  });

  factory CalendarStudent.fromJson(Map<String, dynamic> json) {
    return CalendarStudent(
      studentId: _asInt(json['student_id']),
      name: json['name']?.toString() ?? '',
      classSection: json['class_section']?.toString() ?? '',
    );
  }
}

class CalendarMonthBlock {
  final int year;
  final int monthNumber;
  final String monthName;
  final List<CalendarHoliday> holidays;

  CalendarMonthBlock({
    required this.year,
    required this.monthNumber,
    required this.monthName,
    required this.holidays,
  });

  factory CalendarMonthBlock.fromJson(Map<String, dynamic> json) {
    final list = <CalendarHoliday>[];
    final h = json['holidays'];
    if (h is List) {
      for (final e in h) {
        if (e is Map<String, dynamic>) {
          list.add(CalendarHoliday.fromJson(e));
        }
      }
    }
    return CalendarMonthBlock(
      year: _asInt(json['year']),
      monthNumber: _asInt(json['month_number'], fallback: 1),
      monthName: json['month_name']?.toString() ?? '',
      holidays: list,
    );
  }
}

class CalendarHoliday {
  final int holidayId;
  final String name;
  final String date;
  final String? description;
  final int day;
  final String formattedDate;
  final bool officialHoliday;

  CalendarHoliday({
    required this.holidayId,
    required this.name,
    required this.date,
    this.description,
    required this.day,
    required this.formattedDate,
    required this.officialHoliday,
  });

  factory CalendarHoliday.fromJson(Map<String, dynamic> json) {
    return CalendarHoliday(
      holidayId: _asInt(json['holiday_id']),
      name: json['name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      description: json['description']?.toString(),
      day: _asInt(json['day']),
      formattedDate: json['formatted_date']?.toString() ?? '',
      officialHoliday: json['official_holiday'] == true,
    );
  }
}
