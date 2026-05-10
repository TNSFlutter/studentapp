import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../../controllers/holiday_calendar_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/calendar_models.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final HolidayCalendarController _holidayCalendarController =
      HolidayCalendarController();

  late DateTime _selectedDate;
  late DateTime _focusedDate;

  bool _loading = true;
  String? _error;
  final List<CalendarHoliday> _holidays = [];
  CalendarStudent? _student;
  int _holidayTotal = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDate = DateTime(now.year, now.month, 1);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _fetchHolidays();
  }

  @override
  void dispose() {
    _holidayCalendarController.dispose();
    super.dispose();
  }

  void _syncSelectedDateToFocusedMonth() {
    final now = DateTime.now();
    if (now.year == _focusedDate.year && now.month == _focusedDate.month) {
      _selectedDate = DateTime(now.year, now.month, now.day);
    } else {
      _selectedDate = DateTime(_focusedDate.year, _focusedDate.month, 1);
    }
  }

  Future<void> _fetchHolidays() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final parsed = await _holidayCalendarController.fetchHolidays(
      month: _focusedDate.month,
      year: _focusedDate.year,
      limit: 100,
    );
    if (!mounted) return;
    if (!parsed.success) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'holiday_error_load'.tr;
        _holidays.clear();
        _loading = false;
      });
      return;
    }
    final data = parsed.data;
    final list = data?.holidaysFor(
          _focusedDate.year,
          _focusedDate.month,
        ) ??
        [];
    setState(() {
      _holidays
        ..clear()
        ..addAll(list);
      _student = data?.student;
      _holidayTotal = parsed.pagination.total;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.warmPageBackground(context),
      appBar: CommonAppBar(title: 'more_holiday_calendar'.tr),
      body: RefreshIndicator(
          color: AppColors.accentOrange,
          onRefresh: _fetchHolidays,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _buildSummaryRow(context),
                ),

              // Calendar Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                    child: Column(
                      children: [
                        // Month Navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _focusedDate = DateTime(
                                    _focusedDate.year,
                                    _focusedDate.month - 1,
                                    1,
                                  );
                                  _syncSelectedDateToFocusedMonth();
                                });
                                _fetchHolidays();
                              },
                              icon: Icon(
                                Icons.chevron_left,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _focusedDate = DateTime(
                                    _focusedDate.year,
                                    _focusedDate.month + 1,
                                    1,
                                  );
                                  _syncSelectedDateToFocusedMonth();
                                });
                                _fetchHolidays();
                              },
                              icon: Icon(
                                Icons.chevron_right,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Days of Week Header
                        Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  'weekday_short_sun'.tr,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'weekday_short_mon'.tr,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'weekday_short_tue'.tr,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'weekday_short_wed'.tr,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'weekday_short_thu'.tr,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'weekday_short_fri'.tr,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'weekday_short_sat'.tr,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentOrange,
                                ),
                              ),
                            ),
                          )
                        else
                          _buildCalendarGrid(),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'holiday_this_month'.tr,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_loading && _holidays.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'holiday_none_this_month'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else if (!_loading)
                      for (int i = 0; i < _holidays.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
                        _buildHolidayEventItem(context, _holidays[i]),
                      ],
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

  Widget _buildSummaryRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            number: '$_holidayTotal',
            label: 'holiday_holidays'.tr,
            backgroundColor: AppColors.accentOrange,
            textColor: Colors.white,
          ),
        ),
        if (_student != null) ...[
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ThemeAdaptive.cardShadow(context),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _student!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _student!.classSection,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHolidayEventItem(BuildContext context, CalendarHoliday h) {
    final scheme = Theme.of(context).colorScheme;
    final shortMonth = _shortMonthName(_focusedDate.month);
    return _buildEventItem(
      context,
      month: shortMonth,
      day: '${h.day}',
      title: h.name,
      subtitle: h.description == null || h.description!.isEmpty
          ? (h.officialHoliday ? 'holiday_school_holiday'.tr : 'holiday_observance'.tr)
          : h.description!,
      type: h.officialHoliday ? 'holiday_official'.tr : 'linked_devices_other'.tr,
      date: h.formattedDate,
      typeColor: h.officialHoliday ? AppColors.accentOrange : scheme.primary,
    );
  }

  String _shortMonthName(int m) {
    return _getMonthName(m).substring(0, 3).toUpperCase();
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String number,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? numberColor,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeAdaptive.cardShadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: numberColor ?? textColor,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final scheme = Theme.of(context).colorScheme;
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth = DateTime(
      _focusedDate.year,
      _focusedDate.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day;

    final holidayDays = <int>{
      for (final h in _holidays) h.day,
    };

    List<Widget> calendarDays = [];

    for (int i = 0; i < firstWeekday; i++) {
      calendarDays.add(const Expanded(child: SizedBox()));
    }

    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(_focusedDate.year, _focusedDate.month, day);
      final isSelected = _selectedDate.year == date.year &&
          _selectedDate.month == date.month &&
          _selectedDate.day == date.day;
      final isHoliday = holidayDays.contains(day);

      final Color dayColor =
          isHoliday ? AppColors.accentOrange : scheme.onSurface;

      calendarDays.add(
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              customBorder: const CircleBorder(),
              child: Container(
                height: 40,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentOrange : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '$day',
                      style: TextStyle(
                        color: isSelected ? Colors.white : dayColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isHoliday && !isSelected)
                      Positioned(
                        bottom: 2,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.accentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Create rows of 7 days each
    List<Widget> calendarRows = [];
    for (int i = 0; i < calendarDays.length; i += 7) {
      final rowDays = calendarDays.skip(i).take(7).toList();
      // Pad the last row if needed
      while (rowDays.length < 7) {
        rowDays.add(const Expanded(child: SizedBox()));
      }
      calendarRows.add(Row(children: rowDays));
    }

    return Column(children: calendarRows);
  }

  Widget _buildEventItem(
    BuildContext context, {
    required String month,
    required String day,
    required String title,
    required String subtitle,
    required String type,
    required String date,
    required Color typeColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ThemeAdaptive.cardShadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ThemeAdaptive.neutralFillStrong(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Type and Date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: typeColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
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
}
