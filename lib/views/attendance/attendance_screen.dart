import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/attendance_controller.dart';
import '../../helpers/attendance_calendar_helper.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/attendance_models.dart';
import '../../widgets/common_app_bar.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AttendanceController _attendanceController = AttendanceController();

  bool _loading = true;
  String? _errorMessage;
  AttendancePayload? _payload;

  late DateTime _focusedDate;
  DateTime _selectedDate = DateTime.now();

  Map<int, AttendanceDayMark> _marksByDay = {};

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadAttendance();
    });
  }

  @override
  void dispose() {
    _attendanceController.dispose();
    super.dispose();
  }

  bool get _focusedIsApiMonth {
    final p = _payload;
    if (p == null) return false;
    return p.filters.month == _focusedDate.month &&
        p.filters.year == _focusedDate.year;
  }

  AttendanceDayRecord? _dayRecordForSelected() {
    if (!_focusedIsApiMonth || _payload == null) return null;
    return _payload!.currentMonth.dayRecord(_selectedDate.day);
  }

  Future<void> _loadAttendance({DateTime? revertFocusedToIfError}) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final parsed = await _attendanceController.fetchStudentAttendance(
      month: _focusedDate.month,
      year: _focusedDate.year,
      limit: 10,
    );
    if (!mounted) return;

    if (parsed.success && parsed.data != null) {
      final sync = AttendanceCalendarHelper.syncFromPayload(parsed.data!);
      setState(() {
        _payload = parsed.data;
        _focusedDate = sync.focusedDate;
        _selectedDate = sync.selectedDate;
        _marksByDay = sync.marksByDay;
        _loading = false;
      });
      return;
    }

    setState(() {
      if (revertFocusedToIfError != null) {
        _focusedDate = revertFocusedToIfError;
        if (_selectedDate.year != _focusedDate.year ||
            _selectedDate.month != _focusedDate.month) {
          _selectedDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
        }
      }
      _errorMessage = parsed.message.isNotEmpty
          ? parsed.message
          : 'attendance_error_load'.tr;
      _loading = false;
    });
  }

  void _shiftMonth(int delta) {
    final before = DateTime(_focusedDate.year, _focusedDate.month, 1);
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + delta, 1);
      if (_selectedDate.year != _focusedDate.year ||
          _selectedDate.month != _focusedDate.month) {
        _selectedDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
      }
    });
    _loadAttendance(revertFocusedToIfError: before);
  }

  Color _softFillForMark(BuildContext context, AttendanceDayMark mark) {
    switch (mark) {
      case AttendanceDayMark.present:
        return ThemeAdaptive.softTint(context, const Color(0xFFDCFCE7));
      case AttendanceDayMark.absent:
        return ThemeAdaptive.softTint(context, const Color(0xFFFEE2E2));
      case AttendanceDayMark.leave:
        return ThemeAdaptive.softTint(context, const Color(0xFFDBEAFE));
      case AttendanceDayMark.holiday:
        return ThemeAdaptive.softTint(context, const Color(0xFFEDE9FE));
      case AttendanceDayMark.none:
        return ThemeAdaptive.neutralFill(context);
    }
  }

  Color _textForMark(
    BuildContext context,
    AttendanceDayMark mark, {
    required bool selected,
  }) {
    final scheme = Theme.of(context).colorScheme;
    if (selected) return Colors.white;
    switch (mark) {
      case AttendanceDayMark.present:
        return const Color(0xFF15803D);
      case AttendanceDayMark.absent:
        return const Color(0xFFB91C1C);
      case AttendanceDayMark.leave:
        return const Color(0xFF1D4ED8);
      case AttendanceDayMark.holiday:
        return const Color(0xFF5B21B6);
      case AttendanceDayMark.none:
        return scheme.onSurface;
    }
  }

  String _statusLabel(AttendanceDayMark mark, {AttendanceDayRecord? record}) {
    if (mark == AttendanceDayMark.holiday &&
        record != null &&
        record.holidays.isNotEmpty) {
      return record.holidays.map((h) => h.name).join(', ');
    }
    switch (mark) {
      case AttendanceDayMark.present:
        return 'common_present'.tr;
      case AttendanceDayMark.absent:
        return 'common_absent'.tr;
      case AttendanceDayMark.leave:
        return 'attendance_on_leave'.tr;
      case AttendanceDayMark.holiday:
        return 'common_holiday'.tr;
      case AttendanceDayMark.none:
        return 'attendance_no_record'.tr;
    }
  }

  String _shortStatusBadge(AttendanceDayMark mark) {
    switch (mark) {
      case AttendanceDayMark.present:
        return 'common_present'.tr;
      case AttendanceDayMark.absent:
        return 'common_absent'.tr;
      case AttendanceDayMark.leave:
        return 'common_leave'.tr;
      case AttendanceDayMark.holiday:
        return 'common_holiday'.tr;
      case AttendanceDayMark.none:
        return 'common_none'.tr;
    }
  }

  // Kept for the fuller attendance summary layout; current screen uses compact sections.
  // ignore: unused_element
  Widget _buildHeroCard(AttendancePayload p) {
    final cm = p.currentMonth;
    final titleMonth = cm.monthName.isNotEmpty
        ? cm.monthName
        : (cm.month.isNotEmpty ? cm.month : 'Month');
    final titleYear = cm.year > 0 ? '${cm.year}' : '${p.filters.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA44F), AppColors.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$titleMonth $titleYear',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'attendance_overview'.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required int present,
    required int absent,
    required int leave,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            label: 'common_present'.tr,
            value: present,
            accent: AppColors.statusGreen,
            lightBg: ThemeAdaptive.softTint(context, const Color(0xFFECFDF5)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            label: 'common_absent'.tr,
            value: absent,
            accent: AppColors.statusRed,
            lightBg: ThemeAdaptive.softTint(context, const Color(0xFFFEF2F2)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatPill(
            label: 'common_leave'.tr,
            value: leave,
            accent: AppColors.primaryBlue,
            lightBg: ThemeAdaptive.softTint(context, const Color(0xFFEFF6FF)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title, String subtitle) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: scheme.onSurfaceVariant,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDayChip() {
    if (!_focusedIsApiMonth || _payload == null) return const SizedBox.shrink();

    final d = _selectedDate;
    final scheme = Theme.of(context).colorScheme;
    final mark = _marksByDay[d.day] ?? AttendanceDayMark.none;
    final record = _dayRecordForSelected();
    final label = _statusLabel(mark, record: record);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatSelectedDate(d),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _softFillForMark(context, mark),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _shortStatusBadge(mark),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textForMark(context, mark, selected: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSelectedDate(DateTime d) {
    final weekdays = [
      'weekday_monday'.tr,
      'weekday_tuesday'.tr,
      'weekday_wednesday'.tr,
      'weekday_thursday'.tr,
      'weekday_friday'.tr,
      'weekday_saturday'.tr,
      'weekday_sunday'.tr,
    ];
    final w = weekdays[d.weekday - 1];
    final m = AttendanceCalendarHelper.fullMonthName(d.month);
    return '$w, $m ${d.day}, ${d.year}';
  }

  Widget _buildCalendarCard() {
    final scheme = Theme.of(context).colorScheme;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    final marks = _focusedIsApiMonth ? _marksByDay : <int, AttendanceDayMark>{};
    final today = DateTime.now();

    final calendarDays = <Widget>[];

    for (var i = 0; i < firstWeekday; i++) {
      calendarDays.add(const Expanded(child: SizedBox()));
    }

    for (var day = 1; day <= totalDays; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final selected =
          date.year == _selectedDate.year &&
          date.month == _selectedDate.month &&
          date.day == _selectedDate.day;
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      final mark = marks[day] ?? AttendanceDayMark.none;

      Color? fill;
      if (selected) {
        fill = AppColors.accentOrange;
      } else if (_focusedIsApiMonth &&
          (mark != AttendanceDayMark.none || isToday)) {
        fill = mark != AttendanceDayMark.none
            ? _softFillForMark(context, mark)
            : (isToday ? ThemeAdaptive.neutralFillStrong(context) : null);
      } else if (!_focusedIsApiMonth && isToday) {
        fill = ThemeAdaptive.neutralFillStrong(context);
      }

      calendarDays.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedDate = date),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  height: 44,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(14),
                    border: isToday && !selected
                        ? Border.all(
                            color: AppColors.accentOrange.withValues(
                              alpha: 0.5,
                            ),
                            width: 1.5,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: _textForMark(context, mark, selected: selected),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final calendarRows = <Widget>[];
    for (var i = 0; i < calendarDays.length; i += 7) {
      final rowDays = calendarDays.skip(i).take(7).toList();
      while (rowDays.length < 7) {
        rowDays.add(const Expanded(child: SizedBox()));
      }
      calendarRows.add(Row(children: rowDays));
    }

    final monthTitle = AttendanceCalendarHelper.fullMonthName(
      _focusedDate.month,
    );
    final weekdays = [
      'weekday_short_sun'.tr,
      'weekday_short_mon'.tr,
      'weekday_short_tue'.tr,
      'weekday_short_wed'.tr,
      'weekday_short_thu'.tr,
      'weekday_short_fri'.tr,
      'weekday_short_sat'.tr,
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _MonthNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () => _shiftMonth(-1),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$monthTitle ${_focusedDate.year}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'attendance_tap_date'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _MonthNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () => _shiftMonth(1),
              ),
            ],
          ),
          if (!_focusedIsApiMonth)
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.accentOrange.withValues(alpha: 0.12)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accentOrange.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '${'attendance_colored_days_note'.tr} ${AttendanceCalendarHelper.fullMonthName(_payload!.filters.month)} ${_payload!.filters.year}.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: weekdays
                      .map(
                        (w) => Expanded(
                          child: Center(
                            child: Text(
                              w,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                Column(children: calendarRows),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _LegendChip(
                color: ThemeAdaptive.softTint(context, const Color(0xFFDCFCE7)),
                borderColor: const Color(0xFF86EFAC),
                label: 'common_present'.tr,
              ),
              _LegendChip(
                color: ThemeAdaptive.softTint(context, const Color(0xFFFEE2E2)),
                borderColor: const Color(0xFFF87171),
                label: 'common_absent'.tr,
              ),
              _LegendChip(
                color: ThemeAdaptive.softTint(context, const Color(0xFFDBEAFE)),
                borderColor: const Color(0xFF60A5FA),
                label: 'common_leave'.tr,
              ),
              _LegendChip(
                color: ThemeAdaptive.softTint(context, const Color(0xFFEDE9FE)),
                borderColor: const Color(0xFFC4B5FD),
                label: 'common_holiday'.tr,
              ),
              _LegendChip(
                color: ThemeAdaptive.softTint(context, const Color(0xFFF3F4F6)),
                borderColor: const Color(0xFFD1D5DB),
                label: 'attendance_no_record_short'.tr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CommonAppBar(title: 'attendance_title'.tr),
      body: RefreshIndicator(
        color: AppColors.accentOrange,
        onRefresh: () async => _loadAttendance(),
        child: _loading
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            color: AppColors.accentOrange,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'attendance_loading'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : _errorMessage != null
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(28),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  Builder(
                    builder: (ctx) {
                      final s = Theme.of(ctx).colorScheme;
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: s.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeAdaptive.cardShadow(
                                ctx,
                                lightAlpha: 0.06,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.4,
                                color: s.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _loadAttendance(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentOrange,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'common_try_again'.tr,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                children: [
                  if (_payload != null) ...[
                    // _buildHeroCard(_payload!),
                    const SizedBox(height: 04),
                    _buildSectionLabel(
                      'attendance_this_month'.tr,
                      'attendance_this_month_subtitle'.tr,
                    ),
                    const SizedBox(height: 14),
                    _buildStatRow(
                      present: _payload!.currentMonth.totalPresentDays,
                      absent: _payload!.currentMonth.totalAbsentDays,
                      leave: _payload!.currentMonth.totalLeaveDays,
                    ),
                    const SizedBox(height: 24),
                    _buildCalendarCard(),
                    const SizedBox(height: 14),
                    _buildSelectedDayChip(),
                    const SizedBox(height: 28),
                    _buildSectionLabel(
                      'attendance_academic_session'.tr,
                      'attendance_academic_session_subtitle'.tr,
                    ),
                    const SizedBox(height: 14),
                    _buildStatRow(
                      present: _payload!.session.totalPresentDays,
                      absent: _payload!.session.totalAbsentDays,
                      leave: _payload!.session.totalLeaveDays,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const _LegendChip({
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color accent;
  final Color lightBg;

  const _StatPill({
    required this.label,
    required this.value,
    required this.accent,
    required this.lightBg,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: accent,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
