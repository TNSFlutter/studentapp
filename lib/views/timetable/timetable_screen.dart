import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studentapp/widgets/common_app_bar.dart';
import 'package:studentapp/widgets/week_calendar_strip.dart';

import '../../constants/app_colors.dart';
import '../../controllers/timetable_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/timetable_models.dart';

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
  String _dayTitle = '';
  final List<TimetableEntry> _entries = [];

  static String _toYmd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

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
        _dayTitle = '';
        _sectionSubtitle = '';
        _loading = false;
      });
      return;
    }
    final data = parsed.data;
    if (data == null) {
      setState(() {
        _entries.clear();
        _dayTitle = '';
        _sectionSubtitle = '';
        _loading = false;
      });
      return;
    }
    setState(() {
      _entries
        ..clear()
        ..addAll(data.timetable);
      _dayTitle = '${data.dayName} · ${data.date}';
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.warmPageBackground(context),
      appBar: CommonAppBar(title: 'timetable_title'.tr),
      body: RefreshIndicator(
          color: AppColors.accentOrange,
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
                // Calendar Section
                Container(
                  margin: const EdgeInsets.all(20),
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
                    padding: const EdgeInsets.all(20),
                    child: WeekCalendarStrip(
                      focusedDate: _focusedDate,
                      selectedDate: _selectedDate,
                      monthTitle:
                          '< ${localizedMonthName(_focusedDate.month).toUpperCase()} >',
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
                // Timetable list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'timetable_today'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (_dayTitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _dayTitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (_sectionSubtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _sectionSubtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accentOrange,
                            ),
                          ),
                        )
                      else if (_entries.isEmpty)
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
                        ...List.generate(
                          _entries.length * 2 - 1,
                          (i) {
                            if (i.isOdd) {
                              return const SizedBox(height: 12);
                            }
                            final e = _entries[i ~/ 2];
                            return _buildPeriodCard(
                              index: i ~/ 2,
                              entry: e,
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          ),
    );
  }

  Widget _buildPeriodCard({
    required int index,
    required TimetableEntry entry,
  }) {
    final p = entry.period;
    final s = entry.subject;
    final staff = entry.staff;
    final teacher = staff.name ?? '—';
    final scheme = Theme.of(context).colorScheme;
    final time =
        '${p.formattedStartTime} – ${p.formattedEndTime}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeAdaptive.neutralFill(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: ThemeAdaptive.neutralFillStrong(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'timetable_period'.tr,
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                if (p.name.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    p.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  teacher,
                  style: TextStyle(fontSize: 14, color: scheme.onSurface),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (p.halfName.isNotEmpty)
                Text(
                  p.halfName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (p.halfName.isNotEmpty) const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ],
      ),
    );
  }

}
