// Response for `GET student/attendance?month=&year=&limit=&cursor=`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

class AttendancePagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  AttendancePagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory AttendancePagination.empty() => AttendancePagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory AttendancePagination.fromJson(Map<String, dynamic> json) {
    return AttendancePagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class AttendanceFilters {
  final int month;
  final int year;

  AttendanceFilters({required this.month, required this.year});

  factory AttendanceFilters.fromJson(Map<String, dynamic> json) {
    return AttendanceFilters(
      month: _asInt(json['month'], fallback: 1),
      year: _asInt(json['year']),
    );
  }

  factory AttendanceFilters.fallback(int month, int year) =>
      AttendanceFilters(month: month, year: year);
}

class AttendanceHolidayEntry {
  final int holidayId;
  final String name;
  final String date;
  final String description;
  final int day;
  final String formattedDate;
  final bool officialHoliday;

  AttendanceHolidayEntry({
    required this.holidayId,
    required this.name,
    required this.date,
    required this.description,
    required this.day,
    required this.formattedDate,
    required this.officialHoliday,
  });

  factory AttendanceHolidayEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceHolidayEntry(
      holidayId: _asInt(json['holiday_id']),
      name: json['name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      day: _asInt(json['day']),
      formattedDate: json['formatted_date']?.toString() ?? '',
      officialHoliday: json['official_holiday'] == true,
    );
  }
}

class AttendanceDayRecord {
  final int day;
  final String date;
  final int weekday;
  final String status;
  final String? code;
  final bool isHoliday;
  final List<AttendanceHolidayEntry> holidays;

  AttendanceDayRecord({
    required this.day,
    required this.date,
    required this.weekday,
    required this.status,
    this.code,
    required this.isHoliday,
    required this.holidays,
  });

  factory AttendanceDayRecord.fromJson(Map<String, dynamic> json) {
    final hRaw = json['holidays'];
    final list = <AttendanceHolidayEntry>[];
    if (hRaw is List) {
      for (final e in hRaw) {
        if (e is Map<String, dynamic>) {
          list.add(AttendanceHolidayEntry.fromJson(e));
        } else if (e is Map) {
          list.add(
            AttendanceHolidayEntry.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    return AttendanceDayRecord(
      day: _asInt(json['day']),
      date: json['date']?.toString() ?? '',
      weekday: _asInt(json['weekday']),
      status: json['status']?.toString() ?? 'none',
      code: json['code']?.toString(),
      isHoliday: json['is_holiday'] == true,
      holidays: list,
    );
  }
}

/// One row in `data.months` (session month summaries).
class AttendanceMonthSummary {
  final int recordId;
  final String month;
  final int year;
  final int totalPresentDays;
  final int totalAbsentDays;
  final int totalLeaveDays;

  AttendanceMonthSummary({
    required this.recordId,
    required this.month,
    required this.year,
    required this.totalPresentDays,
    required this.totalAbsentDays,
    required this.totalLeaveDays,
  });

  factory AttendanceMonthSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceMonthSummary(
      recordId: _asInt(json['record_id']),
      month: json['month']?.toString() ?? '',
      year: _asInt(json['year']),
      totalPresentDays: _asInt(json['total_present_days']),
      totalAbsentDays: _asInt(json['total_absent_days']),
      totalLeaveDays: _asInt(json['total_leave_days']),
    );
  }
}

class AttendanceMonthBlock {
  final int monthNumber;
  final String month;
  final String monthName;
  final int year;
  final int daysInMonth;
  final int totalPresentDays;
  final int totalAbsentDays;
  final int totalLeaveDays;
  final int totalHolidayDays;
  final List<int> holidayDays;
  final List<AttendanceHolidayEntry> holidays;
  final List<int> presentDays;
  final List<int> absentDays;
  final List<int> leaveDays;
  final List<AttendanceDayRecord> days;

  AttendanceMonthBlock({
    required this.monthNumber,
    required this.month,
    required this.monthName,
    required this.year,
    required this.daysInMonth,
    required this.totalPresentDays,
    required this.totalAbsentDays,
    required this.totalLeaveDays,
    required this.totalHolidayDays,
    required this.holidayDays,
    required this.holidays,
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.days,
  });

  factory AttendanceMonthBlock.empty() => AttendanceMonthBlock(
        monthNumber: 1,
        month: '--',
        monthName: '',
        year: 0,
        daysInMonth: 0,
        totalPresentDays: 0,
        totalAbsentDays: 0,
        totalLeaveDays: 0,
        totalHolidayDays: 0,
        holidayDays: [],
        holidays: [],
        presentDays: [],
        absentDays: [],
        leaveDays: [],
        days: [],
      );

  factory AttendanceMonthBlock.fromJson(Map<String, dynamic> json) {
    final hd = json['holiday_days'];
    final holidayDayNums = <int>[];
    if (hd is List) {
      for (final e in hd) {
        holidayDayNums.add(_asInt(e));
      }
    }
    final pr = json['present_days'];
    final presentList = <int>[];
    if (pr is List) {
      for (final e in pr) {
        presentList.add(_asInt(e));
      }
    }
    final ab = json['absent_days'];
    final absentList = <int>[];
    if (ab is List) {
      for (final e in ab) {
        absentList.add(_asInt(e));
      }
    }
    final lv = json['leave_days'];
    final leaveList = <int>[];
    if (lv is List) {
      for (final e in lv) {
        leaveList.add(_asInt(e));
      }
    }
    final holRaw = json['holidays'];
    final holList = <AttendanceHolidayEntry>[];
    if (holRaw is List) {
      for (final e in holRaw) {
        if (e is Map<String, dynamic>) {
          holList.add(AttendanceHolidayEntry.fromJson(e));
        } else if (e is Map) {
          holList.add(
            AttendanceHolidayEntry.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    final daysRaw = json['days'];
    final dayRecords = <AttendanceDayRecord>[];
    if (daysRaw is List) {
      for (final e in daysRaw) {
        if (e is Map<String, dynamic>) {
          dayRecords.add(AttendanceDayRecord.fromJson(e));
        } else if (e is Map) {
          dayRecords.add(
            AttendanceDayRecord.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    return AttendanceMonthBlock(
      monthNumber: _asInt(json['month_number'], fallback: 1),
      month: json['month']?.toString() ?? '',
      monthName: json['month_name']?.toString() ?? '',
      year: _asInt(json['year']),
      daysInMonth: _asInt(json['days_in_month']),
      totalPresentDays: _asInt(json['total_present_days']),
      totalAbsentDays: _asInt(json['total_absent_days']),
      totalLeaveDays: _asInt(json['total_leave_days']),
      totalHolidayDays: _asInt(json['total_holiday_days']),
      holidayDays: holidayDayNums,
      holidays: holList,
      presentDays: presentList,
      absentDays: absentList,
      leaveDays: leaveList,
      days: dayRecords,
    );
  }

  AttendanceDayRecord? dayRecord(int dayOfMonth) {
    for (final d in days) {
      if (d.day == dayOfMonth) return d;
    }
    return null;
  }
}

class AttendanceTotals {
  final int totalPresentDays;
  final int totalAbsentDays;
  final int totalLeaveDays;

  AttendanceTotals({
    required this.totalPresentDays,
    required this.totalAbsentDays,
    required this.totalLeaveDays,
  });

  factory AttendanceTotals.empty() => AttendanceTotals(
        totalPresentDays: 0,
        totalAbsentDays: 0,
        totalLeaveDays: 0,
      );

  factory AttendanceTotals.fromJson(Map<String, dynamic> json) {
    return AttendanceTotals(
      totalPresentDays: _asInt(json['total_present_days']),
      totalAbsentDays: _asInt(json['total_absent_days']),
      totalLeaveDays: _asInt(json['total_leave_days']),
    );
  }
}

class AttendancePayload {
  final AttendanceFilters filters;
  final AttendanceMonthBlock currentMonth;
  final AttendanceTotals session;
  final List<AttendanceMonthSummary> months;

  AttendancePayload({
    required this.filters,
    required this.currentMonth,
    required this.session,
    required this.months,
  });

  factory AttendancePayload.fromJson(Map<String, dynamic> json) {
    final cmRaw = json['current_month'];
    final cm = cmRaw is Map<String, dynamic>
        ? AttendanceMonthBlock.fromJson(cmRaw)
        : AttendanceMonthBlock.empty();
    final fRaw = json['filters'];
    final filters = fRaw is Map<String, dynamic>
        ? AttendanceFilters.fromJson(fRaw)
        : AttendanceFilters.fallback(
            cm.monthNumber > 0 ? cm.monthNumber : 1,
            cm.year > 0 ? cm.year : DateTime.now().year,
          );
    final sRaw = json['session'];
    final mRaw = json['months'];
    final months = <AttendanceMonthSummary>[];
    if (mRaw is List) {
      for (final e in mRaw) {
        if (e is Map<String, dynamic>) {
          months.add(AttendanceMonthSummary.fromJson(e));
        } else if (e is Map) {
          months.add(
            AttendanceMonthSummary.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    return AttendancePayload(
      filters: filters,
      currentMonth: cm,
      session: sRaw is Map<String, dynamic>
          ? AttendanceTotals.fromJson(sRaw)
          : AttendanceTotals.empty(),
      months: months,
    );
  }

  /// Local calendar data only (no network). All days `none`, counts zero.
  factory AttendancePayload.localPlaceholder(int year, int month) {
    const abbr = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const full = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    if (month < 1 || month > 12) {
      return AttendancePayload(
        filters: AttendanceFilters(month: 1, year: year),
        currentMonth: AttendanceMonthBlock.empty(),
        session: AttendanceTotals.empty(),
        months: [],
      );
    }
    final lastDay = DateTime(year, month + 1, 0).day;
    final days = <AttendanceDayRecord>[];
    for (var d = 1; d <= lastDay; d++) {
      final dt = DateTime(year, month, d);
      final dateStr =
          '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      days.add(
        AttendanceDayRecord(
          day: d,
          date: dateStr,
          weekday: dt.weekday,
          status: 'none',
          code: null,
          isHoliday: false,
          holidays: [],
        ),
      );
    }
    final cm = AttendanceMonthBlock(
      monthNumber: month,
      month: abbr[month - 1],
      monthName: full[month - 1],
      year: year,
      daysInMonth: lastDay,
      totalPresentDays: 0,
      totalAbsentDays: 0,
      totalLeaveDays: 0,
      totalHolidayDays: 0,
      holidayDays: [],
      holidays: [],
      presentDays: [],
      absentDays: [],
      leaveDays: [],
      days: days,
    );
    return AttendancePayload(
      filters: AttendanceFilters(month: month, year: year),
      currentMonth: cm,
      session: AttendanceTotals.empty(),
      months: [],
    );
  }
}

class AttendanceApiResponse {
  final bool success;
  final String message;
  final AttendancePayload? data;
  final AttendancePagination pagination;

  AttendanceApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.pagination,
  });

  factory AttendanceApiResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final pRaw = json['pagination'];
    return AttendanceApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: raw is Map<String, dynamic>
          ? AttendancePayload.fromJson(raw)
          : null,
      pagination: pRaw is Map<String, dynamic>
          ? AttendancePagination.fromJson(pRaw)
          : AttendancePagination.empty(),
    );
  }
}
