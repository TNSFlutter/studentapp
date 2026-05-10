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
    this.timetableStyle = false,
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

  /// Compact weekday + date cells and navy month/year header (timetable mock).
  final bool timetableStyle;

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
    final monthHeaderText = timetableStyle
        ? '${localizedMonthName(focusedDate.month).toUpperCase()} ${focusedDate.year}'
        : monthTitle;

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
              monthHeaderText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: timetableStyle
                    ? AppColors.primaryBlue
                    : AppColors.accentOrange,
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
        if (!timetableStyle)
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
        if (!timetableStyle) const SizedBox(height: 16),
        _WeekRowSwipeDetector(
          onPrevWeek: onPrevWeek,
          onNextWeek: onNextWeek,
          timetableStyle: timetableStyle,
          child: Builder(
            builder: (_) {
              final weekStart = _sundayStartOfWeek(selectedDate);
              return Row(
                children: List.generate(7, (i) {
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
                      timetableStyle: timetableStyle,
                    ),
                  );
                }),
              );
            },
          ),
        ),
        if (!timetableStyle) ...[
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
      ],
    );
  }
}

/// Tracks both flick velocity and drag distance so prev/next week work reliably
/// when [primaryVelocity] is null or asymmetric (common with nested scroll views).
class _WeekRowSwipeDetector extends StatefulWidget {
  const _WeekRowSwipeDetector({
    required this.child,
    required this.onPrevWeek,
    required this.onNextWeek,
    required this.timetableStyle,
  });

  final Widget child;
  final VoidCallback? onPrevWeek;
  final VoidCallback? onNextWeek;
  final bool timetableStyle;

  @override
  State<_WeekRowSwipeDetector> createState() => _WeekRowSwipeDetectorState();
}

class _WeekRowSwipeDetectorState extends State<_WeekRowSwipeDetector> {
  double _dx = 0;

  static const double _velocityThreshold = 220;
  static const double _distanceThreshold = 36;

  void _onEnd(DragEndDetails details) {
    final vx = details.velocity.pixelsPerSecond.dx;
    final primary = details.primaryVelocity;

    double horizVx = vx;
    if (horizVx.abs() < 50 && primary != null && primary.abs() > 50) {
      horizVx = primary;
    }

    final goNext =
        horizVx < -_velocityThreshold || _dx < -_distanceThreshold;
    final goPrev =
        horizVx > _velocityThreshold || _dx > _distanceThreshold;

    if (goNext && !goPrev) {
      widget.onNextWeek?.call();
    } else if (goPrev && !goNext) {
      widget.onPrevWeek?.call();
    } else if (goNext && goPrev) {
      if (_dx.abs() >= _distanceThreshold) {
        if (_dx < 0) {
          widget.onNextWeek?.call();
        } else {
          widget.onPrevWeek?.call();
        }
      }
    }
    _dx = 0;
  }

  @override
  Widget build(BuildContext context) {
    final minHeight = widget.timetableStyle ? 72.0 : 56.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _dx = 0,
      onHorizontalDragUpdate: (d) => _dx += d.delta.dx,
      onHorizontalDragCancel: () => _dx = 0,
      onHorizontalDragEnd: _onEnd,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: widget.child,
      ),
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
    this.timetableStyle = false,
  });

  final int day;
  final String shortDow;
  final bool selected;
  final bool muted;
  final VoidCallback onTap;
  final bool timetableStyle;

  static const Color _timetableOrange = Color(0xFFFF7000);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mutedGrey =
        scheme.onSurfaceVariant.withValues(alpha: muted ? 0.35 : 0.65);

    Widget timetableUnselected() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            shortDow.toUpperCase(),
            style: TextStyle(
              color: mutedGrey,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$day',
            style: TextStyle(
              color: mutedGrey,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    Widget timetableSelected() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            shortDow.toUpperCase(),
            style: const TextStyle(
              color: _timetableOrange,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _timetableOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$day',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: timetableStyle
              ? (selected ? timetableSelected() : timetableUnselected())
              : selected
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
