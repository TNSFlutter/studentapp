import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';

/// Sunday = first column (matches [DateTime.weekday]: Sun 7 % 7 = 0).
DateTime _sundayStartOfWeek(DateTime d) {
  return DateTime(d.year, d.month, d.day)
      .subtract(Duration(days: d.weekday % 7));
}

/// Week row + month header matching the timetable screen calendar UX.
/// Optionally supports swipe-left (next week) and swipe-right (prev week)
/// by passing [onPrevWeek] and [onNextWeek].
class WeekCalendarStrip extends StatelessWidget {
  const WeekCalendarStrip({
    super.key,
    required this.focusedDate,
    required this.selectedDate,
    required this.monthTitle,
    required this.onDayPicked,
    required this.onPrevMonth,
    required this.onNextMonth,
    this.onPrevWeek,
    this.onNextWeek,
  });

  /// First day of the month whose label is shown; used to grey out days outside that month.
  final DateTime focusedDate;
  final DateTime selectedDate;
  final String monthTitle;
  final ValueChanged<DateTime> onDayPicked;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  /// Called when the user swipes right across the week row (go back one week).
  final VoidCallback? onPrevWeek;

  /// Called when the user swipes left across the week row (go forward one week).
  final VoidCallback? onNextWeek;

  @override
  Widget build(BuildContext context) {
    final short = [
      'weekday_sun'.tr,
      'weekday_mon'.tr,
      'weekday_tue'.tr,
      'weekday_wed'.tr,
      'weekday_thu'.tr,
      'weekday_fri'.tr,
      'weekday_sat'.tr,
    ];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: onPrevMonth,
              icon: Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              monthTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.accentOrange,
              ),
            ),
            IconButton(
              onPressed: onNextMonth,
              icon: Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            WeekdayLabel('weekday_short_sun'.tr),
            WeekdayLabel('weekday_short_mon'.tr),
            WeekdayLabel('weekday_short_tue'.tr),
            WeekdayLabel('weekday_short_wed'.tr),
            WeekdayLabel('weekday_short_thu'.tr),
            WeekdayLabel('weekday_short_fri'.tr),
            WeekdayLabel('weekday_short_sat'.tr),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (details) {
            final v = details.primaryVelocity;
            if (v == null) return;
            if (v < -300) {
              onNextWeek?.call();
            } else if (v > 300) {
              onPrevWeek?.call();
            }
          },
          child: Row(
            children: List.generate(7, (i) {
              final weekStart = _sundayStartOfWeek(selectedDate);
              final d = weekStart.add(Duration(days: i));
              final inMonth = d.month == focusedDate.month;
              final isSel = selectedDate.year == d.year &&
                  selectedDate.month == d.month &&
                  selectedDate.day == d.day;
              final shortDow = short[d.weekday % 7];
              return Expanded(
                child: WeekDayCell(
                  day: d.day,
                  shortDow: shortDow,
                  selected: isSel,
                  muted: !inMonth,
                  onTap: () => onDayPicked(d),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 2,
          width: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

class WeekdayLabel extends StatelessWidget {
  const WeekdayLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class WeekDayCell extends StatelessWidget {
  const WeekDayCell({
    super.key,
    required this.day,
    required this.shortDow,
    required this.selected,
    required this.muted,
    required this.onTap,
  });

  final int day;
  final String shortDow;
  final bool selected;
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: selected
              ? Container(
                  width: 60,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFA44F),
                        AppColors.accentOrange,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          shortDow.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$day',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Text(
                  '$day',
                  style: TextStyle(
                    color: muted
                        ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
                        : scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

String localizedMonthName(int month) {
  final months = [
    'month_january'.tr,
    'month_february'.tr,
    'month_march'.tr,
    'month_april'.tr,
    'month_may'.tr,
    'month_june'.tr,
    'month_july'.tr,
    'month_august'.tr,
    'month_september'.tr,
    'month_october'.tr,
    'month_november'.tr,
    'month_december'.tr,
  ];
  return months[month - 1];
}
