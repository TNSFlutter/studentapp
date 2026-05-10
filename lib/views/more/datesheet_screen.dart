import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../../controllers/datesheet_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/datesheet_models.dart';

const Color _datesheetHeaderOrange = Color(0xFFFF7000);

class DatesheetScreen extends StatefulWidget {
  const DatesheetScreen({super.key});

  @override
  State<DatesheetScreen> createState() => _DatesheetScreenState();
}

class _DatesheetScreenState extends State<DatesheetScreen> {
  final DatesheetController _datesheetController = DatesheetController();

  List<DatesheetExamType> _examTypes = [];
  DatesheetNextExam? _nextExam;

  int _selectedTab = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDatesheets();
  }

  @override
  void dispose() {
    _datesheetController.dispose();
    super.dispose();
  }

  Future<void> _loadDatesheets() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final parsed = await _datesheetController.fetchDatesheets(limit: 10);
    if (!mounted) return;
    if (!parsed.success) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'datesheet_error_load'.tr;
        _examTypes = [];
        _nextExam = null;
        _loading = false;
      });
      return;
    }
    setState(() {
      _examTypes = parsed.examTypes;
      _nextExam = parsed.nextExam;
      _selectedTab = _initialTabIndex(parsed.examTypes, parsed.nextExam);
      _loading = false;
    });
  }

  int _initialTabIndex(List<DatesheetExamType> types, DatesheetNextExam? next) {
    if (types.isEmpty) return 0;
    final cur = types.indexWhere((e) => e.isCurrent);
    if (cur >= 0) return cur;
    if (next != null) {
      final byNext = types.indexWhere((e) => e.examTypeId == next.examTypeId);
      if (byNext >= 0) return byNext;
    }
    return 0;
  }

  bool _isPrimaryUpcoming(DatesheetSubjectRow s, DatesheetNextExam? next) {
    if (next == null || !s.isUpcoming) return false;
    return s.scheduleId == next.scheduleId;
  }

  String _weekdayMonthDay(String dateStr) {
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('EEE dd').format(d).toUpperCase();
    } catch (_) {
      return '';
    }
  }

  String _timeRangeSubject(DatesheetSubjectRow s) {
    final t = s.time.trim();
    final end = s.formattedEndTime?.trim();
    if (end != null && end.isNotEmpty) return '$t – $end';
    return t;
  }

  String _timeRangeNext(DatesheetNextExam e) {
    final t = e.time.trim();
    final end = e.formattedEndTime?.trim();
    if (end != null && end.isNotEmpty) return '$t – $end';
    return t;
  }

  String _roomLabelShort(DatesheetSubjectRow s) {
    if (s.roomId != null) return '${'datesheet_room_no'.tr} ${s.roomId}';
    return 'datesheet_no_room'.tr;
  }

  String _roomHero(DatesheetNextExam e) {
    if (e.roomId != null) return '${'datesheet_room_no'.tr} ${e.roomId}';
    return 'datesheet_no_room'.tr;
  }

  String _daysBadge(DatesheetNextExam e) {
    final d = e.daysUntil;
    if (d <= 0) return 'datesheet_exam_today'.tr;
    if (d == 1) return 'datesheet_exam_tomorrow'.tr;
    return 'datesheet_in_days'.tr.replaceAll('@n', '$d');
  }

  String _tabLabel(DatesheetExamType e) {
    final base = e.displayName;
    if (e.isCurrent) {
      return '$base (${'datesheet_tab_current'.tr})';
    }
    return base;
  }

  String _subjectSubtitle(DatesheetSubjectRow s) {
    return '${_roomLabelShort(s)} · ${_timeRangeSubject(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subjects = _examTypes.isEmpty || _selectedTab >= _examTypes.length
        ? <DatesheetSubjectRow>[]
        : _examTypes[_selectedTab].subjects;

    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: CommonAppBar(
        title: 'datesheet_title'.tr,
        showBackgroundPattern: false,
        frostedLeadingBackground: true,
        backgroundColor: _datesheetHeaderOrange,
      ),
      body: RefreshIndicator(
        color: AppColors.accentOrange,
        onRefresh: _loadDatesheets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: _loadDatesheets,
                        child: Text('common_retry'.tr),
                      ),
                    ],
                  ),
                )
              else if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentOrange,
                    ),
                  ),
                )
              else ...[
                if (_nextExam != null) _buildNextExamHero(context, _nextExam!),
                if (_nextExam != null) const SizedBox(height: 20),
                if (_examTypes.isEmpty)
                  Text(
                    'datesheet_none'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  )
                else ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_examTypes.length, (i) {
                        return Padding(
                          padding: EdgeInsets.only(
                            right: i == _examTypes.length - 1 ? 0 : 10,
                          ),
                          child: _examTypeChip(
                            context,
                            index: i,
                            type: _examTypes[i],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ThemeAdaptive.cardShadow(context),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: subjects.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'datesheet_no_subjects'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          )
                        : Column(
                            children: List.generate(subjects.length, (i) {
                              final s = subjects[i];
                              final last = i == subjects.length - 1;
                              return _subjectRow(context, s, isLast: last);
                            }),
                          ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _examTypeChip(
    BuildContext context, {
    required int index,
    required DatesheetExamType type,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selectedTab == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : scheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Text(
            _tabLabel(type),
            style: TextStyle(
              color: selected ? Colors.white : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextExamHero(BuildContext context, DatesheetNextExam e) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF312E81)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -20,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -40,
              child: CircleAvatar(
                radius: 55,
                backgroundColor: const Color(
                  0xFF6366F1,
                ).withValues(alpha: 0.25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'datesheet_your_next_exam'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                                color: Colors.lightBlue.shade200,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              e.subjectName,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _datesheetHeaderOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _daysBadge(e),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _heroMetric(
                          label: 'datesheet_label_date'.tr,
                          value: e.shortFormattedDate.isNotEmpty
                              ? e.shortFormattedDate
                              : e.formattedDate,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      Expanded(
                        child: _heroMetric(
                          label: 'datesheet_label_time'.tr,
                          value: _timeRangeNext(e),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                      Expanded(
                        child: _heroMetric(
                          label: 'datesheet_label_room'.tr,
                          value: _roomHero(e),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroMetric({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 0.6,
            fontWeight: FontWeight.w600,
            color: Colors.lightBlue.shade200,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _subjectRow(
    BuildContext context,
    DatesheetSubjectRow s, {
    required bool isLast,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final done = s.isDone;
    final primaryUp = _isPrimaryUpcoming(s, _nextExam);
    final wd = _weekdayMonthDay(s.date);

    final borderSide = primaryUp
        ? const Border(
            left: BorderSide(color: _datesheetHeaderOrange, width: 4),
          )
        : null;

    final bg = primaryUp
        ? _datesheetHeaderOrange.withValues(alpha: 0.08)
        : null;

    return Container(
      decoration: BoxDecoration(color: bg, border: borderSide),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, top: 16),
                child: Text(
                  wd,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryUp
                        ? _datesheetHeaderOrange
                        : done
                        ? scheme.onSurfaceVariant.withValues(alpha: 0.65)
                        : AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 22,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (!isLast)
                    Positioned(
                      left: 9,
                      top: 22,
                      bottom: 0,
                      child: Container(
                        width: 2,
                        color: scheme.outlineVariant.withValues(alpha: 0.65),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _timelineDot(
                      done: done,
                      primaryUp: primaryUp,
                      scheme: scheme,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            s.subjectName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: done
                                  ? scheme.onSurfaceVariant.withValues(
                                      alpha: 0.55,
                                    )
                                  : AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        if (primaryUp)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _datesheetHeaderOrange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'datesheet_upcoming'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.4,
                              ),
                            ),
                          )
                        else if (done)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.statusGreen,
                            size: 22,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _subjectSubtitle(s),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineDot({
    required bool done,
    required bool primaryUp,
    required ColorScheme scheme,
  }) {
    if (done) {
      return Icon(Icons.check_circle, color: AppColors.statusGreen, size: 18);
    }
    if (primaryUp) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _datesheetHeaderOrange, width: 3),
          color: _datesheetHeaderOrange.withValues(alpha: 0.25),
        ),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: scheme.outlineVariant, width: 2),
        color: scheme.surface,
      ),
    );
  }
}
