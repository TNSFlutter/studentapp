import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:studentapp/widgets/common_app_bar.dart';
import 'package:studentapp/widgets/week_calendar_strip.dart';

import '../../constants/app_colors.dart';
import '../../controllers/timetable_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/timetable_models.dart';

/// Primary accent for timetable UI (matches design reference).
const Color _timetableOrange = Color(0xFFFF7000);

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final TimetableController _timetableController = TimetableController();

  late DateTime _selectedDate;
  late DateTime _focusedDate;

  bool _loading = true;
  String? _error;
  String _sectionSubtitle = '';
  final List<TimetableEntry> _entries = [];

  static String _toYmd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static final List<Color> _accentPalette = [
    const Color(0xFF14B8A6),
    _timetableOrange,
    const Color(0xFFA855F7),
    const Color(0xFF22C55E),
    const Color(0xFFEAB308),
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDate = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _fetchTimetable();
  }

  @override
  void dispose() {
    _timetableController.dispose();
    super.dispose();
  }

  void _syncSelectedToFocusedMonth() {
    final now = DateTime.now();
    if (now.year == _focusedDate.year && now.month == _focusedDate.month) {
      _selectedDate = DateTime(now.year, now.month, now.day);
    } else {
      _selectedDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
    }
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final parsed = await _timetableController.fetchTimetable(
      yyyyMmDd: _toYmd(_selectedDate),
      limit: 10,
    );
    if (!mounted) return;
    if (!parsed.success) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'timetable_error_load'.tr;
        _entries.clear();
        _sectionSubtitle = '';
        _loading = false;
      });
      return;
    }
    final data = parsed.data;
    if (data == null) {
      setState(() {
        _entries.clear();
        _sectionSubtitle = '';
        _loading = false;
      });
      return;
    }
    setState(() {
      _entries
        ..clear()
        ..addAll(data.timetable);
      _sectionSubtitle =
          data.classSection == null ? '' : data.classSection!.name;
      _loading = false;
    });
  }

  void _onDayPicked(DateTime day) {
    setState(() {
      _selectedDate = DateTime(day.year, day.month, day.day);
      _focusedDate = DateTime(day.year, day.month, 1);
    });
    _fetchTimetable();
  }

  void _onPrevWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      _focusedDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    });
    _fetchTimetable();
  }

  void _onNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
      _focusedDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
    });
    _fetchTimetable();
  }

  bool _isSelectedToday() {
    final n = DateTime.now();
    return _selectedDate.year == n.year &&
        _selectedDate.month == n.month &&
        _selectedDate.day == n.day;
  }

  List<TimetableEntry> _sortedEntries() {
    final copy = List<TimetableEntry>.from(_entries);
    copy.sort((a, b) {
      final as = _parseTimeOnDay(a.period.formattedStartTime, _selectedDate);
      final bs = _parseTimeOnDay(b.period.formattedStartTime, _selectedDate);
      if (as == null && bs == null) return 0;
      if (as == null) return 1;
      if (bs == null) return -1;
      return as.compareTo(bs);
    });
    return copy;
  }

  int? _currentPeriodIndex(List<TimetableEntry> sorted) {
    if (!_isSelectedToday()) return null;
    final now = DateTime.now();
    for (var i = 0; i < sorted.length; i++) {
      final start =
          _parseTimeOnDay(sorted[i].period.formattedStartTime, _selectedDate);
      final end =
          _parseTimeOnDay(sorted[i].period.formattedEndTime, _selectedDate);
      if (start != null &&
          end != null &&
          !now.isBefore(start) &&
          now.isBefore(end)) {
        return i;
      }
    }
    return null;
  }

  int? _nextPeriodIndex(List<TimetableEntry> sorted) {
    if (!_isSelectedToday()) return null;
    final now = DateTime.now();
    for (var i = 0; i < sorted.length; i++) {
      final start =
          _parseTimeOnDay(sorted[i].period.formattedStartTime, _selectedDate);
      if (start != null && now.isBefore(start)) {
        return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sorted = _sortedEntries();
    final currentIdx = _currentPeriodIndex(sorted);
    final nextIdx = _nextPeriodIndex(sorted);

    return Scaffold(
      backgroundColor: ThemeAdaptive.warmPageBackground(context),
      appBar: CommonAppBar(
        title: 'timetable_title'.tr,
        showBackgroundPattern: false,
        frostedLeadingBackground: true,
        backgroundColor: _timetableOrange,
      ),
      body: RefreshIndicator(
        color: _timetableOrange,
        onRefresh: _fetchTimetable,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: ThemeAdaptive.cardShadow(context),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
                  child: WeekCalendarStrip(
                    focusedDate: _focusedDate,
                    selectedDate: _selectedDate,
                    monthTitle:
                        '${localizedMonthName(_focusedDate.month).toUpperCase()} ${_focusedDate.year}',
                    timetableStyle: true,
                    onDayPicked: _onDayPicked,
                    onPrevMonth: () {
                      setState(() {
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          _focusedDate.month - 1,
                          1,
                        );
                        _syncSelectedToFocusedMonth();
                      });
                      _fetchTimetable();
                    },
                    onNextMonth: () {
                      setState(() {
                        _focusedDate = DateTime(
                          _focusedDate.year,
                          _focusedDate.month + 1,
                          1,
                        );
                        _syncSelectedToFocusedMonth();
                      });
                      _fetchTimetable();
                    },
                    onPrevWeek: _onPrevWeek,
                    onNextWeek: _onNextWeek,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'timetable_today'.tr.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDarkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            _summaryTitle(sorted.length),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        if (currentIdx != null &&
                            sorted.isNotEmpty &&
                            currentIdx < sorted.length)
                          _CurrentPeriodBadge(
                            periodNumber: currentIdx + 1,
                            subjectName:
                                sorted[currentIdx].subject.name,
                          ),
                      ],
                    ),
                    if (_sectionSubtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _sectionSubtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _timetableOrange,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _timetableOrange,
                          ),
                        ),
                      )
                    else if (sorted.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'timetable_none_day'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ..._buildTimelineRows(
                        sorted: sorted,
                        currentIdx: currentIdx,
                        nextIdx: nextIdx,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _summaryTitle(int count) {
    final datePart =
        DateFormat('EEE, d MMM').format(_selectedDate);
    if (count == 0) return datePart;
    return '$datePart · $count periods';
  }

  List<Widget> _buildTimelineRows({
    required List<TimetableEntry> sorted,
    required int? currentIdx,
    required int? nextIdx,
  }) {
    final widgets = <Widget>[];
    final isToday = _isSelectedToday();
    final now = DateTime.now();

    for (var i = 0; i < sorted.length; i++) {
      if (i > 0) {
        widgets.add(const SizedBox(height: 4));
      }
      final entry = sorted[i];
      final accent = _accentPalette[i % _accentPalette.length];

      _PeriodStatus status;
      if (!isToday) {
        status = _PeriodStatus.upcoming;
      } else if (currentIdx == i) {
        status = _PeriodStatus.current;
      } else {
        final end =
            _parseTimeOnDay(entry.period.formattedEndTime, _selectedDate);
        if (end != null && now.isAfter(end)) {
          status = _PeriodStatus.past;
        } else {
          status = _PeriodStatus.upcoming;
        }
      }

      final startLabel = _shortTimeLabel(entry.period.formattedStartTime);
      final showRelative =
          isToday && nextIdx == i && status == _PeriodStatus.upcoming;

      widgets.add(
        _TimelinePeriodRow(
          startLabel: startLabel,
          accent: accent,
          entry: entry,
          index: i,
          status: status,
          showRelativeMinutes: showRelative,
          selectedDate: _selectedDate,
          isLast: i == sorted.length - 1,
        ),
      );
    }
    return widgets;
  }

  String _shortTimeLabel(String formatted) {
    final t = _parseTimeOfDay(formatted);
    if (t == null) return formatted;
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

enum _PeriodStatus { past, current, upcoming }

class _CurrentPeriodBadge extends StatelessWidget {
  const _CurrentPeriodBadge({
    required this.periodNumber,
    required this.subjectName,
  });

  final int periodNumber;
  final String subjectName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _timetableOrange, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _timetableOrange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'P$periodNumber · $subjectName',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _timetableOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelinePeriodRow extends StatelessWidget {
  const _TimelinePeriodRow({
    required this.startLabel,
    required this.accent,
    required this.entry,
    required this.index,
    required this.status,
    required this.showRelativeMinutes,
    required this.selectedDate,
    required this.isLast,
  });

  final String startLabel;
  final Color accent;
  final TimetableEntry entry;
  final int index;
  final _PeriodStatus status;
  final bool showRelativeMinutes;
  final DateTime selectedDate;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final teacher = entry.staff.name ?? '—';
    final timeRange =
        '${entry.period.formattedStartTime}–${entry.period.formattedEndTime}';
    final subLine = '$teacher · $timeRange';

    final isPast = status == _PeriodStatus.past;
    final isCurrent = status == _PeriodStatus.current;

    final titleColor = isPast
        ? scheme.onSurfaceVariant.withValues(alpha: 0.55)
        : AppColors.primaryBlue;
    final subColor = isPast
        ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
        : AppColors.textDarkGrey;

    String? rightLabel;
    if (isPast) {
      rightLabel = null;
    } else if (showRelativeMinutes) {
      final start =
          _parseTimeOnDay(entry.period.formattedStartTime, selectedDate);
      if (start != null) {
        final m = start.difference(DateTime.now()).inMinutes;
        if (m > 0) rightLabel = 'in $m min';
      }
    }
    rightLabel ??=
        isCurrent ? null : _compactTime(entry.period.formattedStartTime);

    final progress = isCurrent ? _periodProgress(entry, selectedDate) : null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                startLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 18,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                if (!isLast)
                  Positioned(
                    left: 7,
                    top: 18,
                    bottom: -4,
                    child: Container(
                      width: 2,
                      color: scheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCurrent ? _timetableOrange : scheme.outlineVariant,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: isCurrent
                      ? Border.all(color: _timetableOrange, width: 2)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(width: 5, color: accent),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 8,
                                        children: [
                                          Text(
                                            entry.subject.name,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: titleColor,
                                            ),
                                          ),
                                          if (isCurrent)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _timetableOrange
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'NOW',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: _timetableOrange,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (isPast)
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.statusGreen,
                                        size: 22,
                                      )
                                    else if (rightLabel != null)
                                      Text(
                                        rightLabel,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: isCurrent
                                              ? _timetableOrange
                                              : AppColors.textDarkGrey,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  subLine,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: subColor,
                                  ),
                                ),
                                if (progress != null) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 5,
                                      backgroundColor: scheme.outlineVariant
                                          .withValues(alpha: 0.35),
                                      color: _timetableOrange,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double? _periodProgress(TimetableEntry entry, DateTime day) {
  final start = _parseTimeOnDay(entry.period.formattedStartTime, day);
  final end = _parseTimeOnDay(entry.period.formattedEndTime, day);
  if (start == null || end == null) return null;
  final now = DateTime.now();
  if (now.isBefore(start) || !now.isBefore(end)) return null;
  final total = end.difference(start).inMilliseconds;
  if (total <= 0) return 1.0;
  final elapsed = now.difference(start).inMilliseconds;
  return (elapsed / total).clamp(0.0, 1.0);
}

String _compactTime(String formatted) {
  final t = _parseTimeOfDay(formatted);
  if (t == null) return formatted;
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

TimeOfDay? _parseTimeOfDay(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;

  final m24 = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(s);
  if (m24 != null) {
    final h = int.tryParse(m24.group(1) ?? '');
    final m = int.tryParse(m24.group(2) ?? '');
    if (h != null && m != null && h < 24 && m < 60) {
      return TimeOfDay(hour: h, minute: m);
    }
  }

  final m12 = RegExp(
    r'^(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([AaPp][Mm])',
  ).firstMatch(s);
  if (m12 != null) {
    var h = int.tryParse(m12.group(1) ?? '') ?? 0;
    final m = int.tryParse(m12.group(2) ?? '') ?? 0;
    final ap = m12.group(4);
    final isPm = ap != null && ap.toUpperCase().startsWith('P');
    if (h == 12) {
      h = isPm ? 12 : 0;
    } else if (isPm) {
      h += 12;
    }
    if (h < 24 && m < 60) return TimeOfDay(hour: h, minute: m);
  }

  return null;
}

DateTime? _parseTimeOnDay(String formatted, DateTime day) {
  final t = _parseTimeOfDay(formatted);
  if (t == null) return null;
  return DateTime(day.year, day.month, day.day, t.hour, t.minute);
}
