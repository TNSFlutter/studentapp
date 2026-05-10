import '../models/attendance_models.dart';

/// Calendar day mark derived from API `days[]` or fallback lists.
enum AttendanceDayMark { none, present, absent, leave, holiday }

/// Calendar state derived from an [AttendancePayload] (not UI).
class AttendanceCalendarSync {
  final DateTime focusedDate;
  final DateTime selectedDate;
  final int apiMonthYearKey;
  final Map<int, AttendanceDayMark> marksByDay;

  const AttendanceCalendarSync({
    required this.focusedDate,
    required this.selectedDate,
    required this.apiMonthYearKey,
    required this.marksByDay,
  });
}

class AttendanceCalendarHelper {
  AttendanceCalendarHelper._();

  static int monthYearKey(int year, int month) => year * 100 + month;

  static int? parseMonthAbbrev(String raw) {
    final t = raw.trim().toLowerCase();
    if (t.length < 3) return null;
    const keys = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    final head = t.substring(0, t.length >= 3 ? 3 : t.length);
    final i = keys.indexOf(head);
    if (i >= 0) return i + 1;
    return null;
  }

  static String fullMonthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }

  /// Prefer full `days[]` from API; else derive from `present_days` / etc.
  static Map<int, AttendanceDayMark> buildMarksFromMonth(
    AttendanceMonthBlock cm,
  ) {
    if (cm.days.isNotEmpty) {
      return buildMarksFromDayRecords(cm.days);
    }
    return buildMarksFromDayLists(cm);
  }

  static Map<int, AttendanceDayMark> buildMarksFromDayRecords(
    List<AttendanceDayRecord> days,
  ) {
    final map = <int, AttendanceDayMark>{};
    for (final d in days) {
      AttendanceDayMark m;
      switch (d.status.toLowerCase()) {
        case 'present':
          m = AttendanceDayMark.present;
          break;
        case 'absent':
          m = AttendanceDayMark.absent;
          break;
        case 'leave':
          m = AttendanceDayMark.leave;
          break;
        default:
          m = d.isHoliday ? AttendanceDayMark.holiday : AttendanceDayMark.none;
      }
      map[d.day] = m;
    }
    return map;
  }

  static Map<int, AttendanceDayMark> buildMarksFromDayLists(
    AttendanceMonthBlock cm,
  ) {
    final map = <int, AttendanceDayMark>{};
    for (final d in cm.presentDays) {
      map[d] = AttendanceDayMark.present;
    }
    for (final d in cm.absentDays) {
      map[d] = AttendanceDayMark.absent;
    }
    for (final d in cm.leaveDays) {
      map[d] = AttendanceDayMark.leave;
    }
    for (final d in cm.holidayDays) {
      if (!map.containsKey(d)) {
        map[d] = AttendanceDayMark.holiday;
      }
    }
    return map;
  }

  static AttendanceCalendarSync syncFromPayload(
    AttendancePayload payload, {
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final cm = payload.currentMonth;
    final year = cm.year > 0 ? cm.year : payload.filters.year;
    final month = cm.monthNumber > 0 ? cm.monthNumber : payload.filters.month;
    final focused = DateTime(year, month, 1);
    final apiKey = monthYearKey(year, month);
    final selected = (clock.year == year && clock.month == month)
        ? DateTime(clock.year, clock.month, clock.day)
        : DateTime(year, month, 1);
    final marks = buildMarksFromMonth(cm);
    return AttendanceCalendarSync(
      focusedDate: focused,
      selectedDate: selected,
      apiMonthYearKey: apiKey,
      marksByDay: marks,
    );
  }
}
