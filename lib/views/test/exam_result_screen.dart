import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../../controllers/exam_result_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/exam_result_models.dart';

class ExamResultScreen extends StatefulWidget {
  const ExamResultScreen({super.key});

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final ExamResultController _controller = ExamResultController();

  static const int _pageLimit = 10;

  ExamResultsStudent? _student;
  List<ExamSession> _todayExams = [];
  ExamResultsListSummary _todaySummary = ExamResultsListSummary.empty();
  List<ExamSession> _previousExams = [];
  ExamResultsListSummary _previousSummary = ExamResultsListSummary.empty();
  ExamResultsPagination _pagination = ExamResultsPagination.empty();
  String? _nextCursor;

  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetch({required bool reset}) async {
    if (_loadingMore) return;
    if (!reset) {
      if (!_pagination.hasNextPage) return;
      final c = _nextCursor?.trim();
      if (c == null || c.isEmpty) return;
    }

    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _nextCursor = null;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    final cursor = reset ? null : _nextCursor;
    final parsed = await _controller.fetchExamResults(
      limit: _pageLimit,
      cursor: cursor,
    );

    if (!mounted) return;

    if (!parsed.success || parsed.data == null) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'exam_result_error_load'.tr;
        if (reset) {
          _todayExams = [];
          _previousExams = [];
        }
        _loading = false;
        _loadingMore = false;
      });
      return;
    }

    final d = parsed.data!;
    setState(() {
      _student = d.student;
      _todayExams = List<ExamSession>.from(d.today.exams);
      _todaySummary = d.today.summary;
      if (reset) {
        _previousExams = List<ExamSession>.from(d.previous.exams);
      } else {
        _appendPreviousDeduped(d.previous.exams);
      }
      _previousSummary = d.previous.summary;
      _pagination = parsed.pagination;
      _nextCursor = parsed.pagination.nextCursor;
      _loading = false;
      _loadingMore = false;
    });
  }

  void _appendPreviousDeduped(List<ExamSession> more) {
    final seen = _previousExams.map((e) => e.dedupeKey).toSet();
    for (final e in more) {
      final k = e.dedupeKey;
      if (!seen.contains(k)) {
        seen.add(k);
        _previousExams.add(e);
      }
    }
  }

  Future<void> _loadMore() => _fetch(reset: false);

  String _examListSummaryLine(ExamResultsListSummary s) {
    final pct = s.overallPercentage.toStringAsFixed(2);
    return '${'exam_result_exams'.tr} ${s.totalExams} · ${'exam_result_subjects'.tr} ${s.totalSubjects} · '
        '${'exam_result_marks'.tr} ${s.obtainedMarks}/${s.totalMarks} · $pct%';
  }

  String _examSessionSummaryLine(ExamSessionSummary s) {
    final pct = s.overallPercentage.toStringAsFixed(2);
    return '${'exam_result_subjects'.tr} ${s.totalSubjects} (${ 'common_present'.tr} ${s.presentSubjects}, '
        '${'common_absent'.tr} ${s.absentSubjects}, N/A ${s.naSubjects}) · '
        '${'exam_result_marks'.tr} ${s.obtainedMarks}/${s.totalMarks} · $pct%';
  }

  String _childObtained(ExamChildSubjectResult c) {
    if (c.isNa) return 'N/A';
    if (c.isAbsent) return 'AB';
    if (c.obtainedMarks != null && c.obtainedMarks!.trim().isNotEmpty) {
      return c.obtainedMarks!.trim();
    }
    return '—';
  }

  String _maxMarksLabel(int max) {
    if (max <= 0) return '—';
    return '$max';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeAdaptive.warmPageBackground(context),
      appBar: CommonAppBar(title: 'exam_results_title'.tr),
      body: RefreshIndicator(
          color: AppColors.accentOrange,
          onRefresh: () => _fetch(reset: true),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null && !_loading)
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
                            onPressed: () => _fetch(reset: true),
                            child: Text('common_retry'.tr),
                          ),
                        ],
                      ),
                    ),
                  if (_student != null) _buildStudentHeader(_student!),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentOrange,
                        ),
                      ),
                    )
                  else ...[
                    _buildSectionTitle('exam_results_today'.tr),
                    const SizedBox(height: 8),
                    Text(
                      _examListSummaryLine(_todaySummary),
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    if (_todayExams.isEmpty)
                      _buildEmptyHint('exam_results_none_today'.tr)
                    else
                      ..._todayExams.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildExamCard(e),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('exam_results_previous'.tr),
                    const SizedBox(height: 8),
                    Text(
                      _examListSummaryLine(_previousSummary),
                      style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    if (_previousExams.isEmpty)
                      _buildEmptyHint('exam_results_none_previous'.tr)
                    else
                      ..._previousExams.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildExamCard(e),
                        ),
                      ),
                    if (_pagination.hasNextPage) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: _loadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                              )
                            : TextButton.icon(
                                onPressed: _loadMore,
                                icon: const Icon(Icons.expand_more),
                                label: Text('common_load_more'.tr),
                              ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          ),
    );
  }

  Widget _buildStudentHeader(ExamResultsStudent s) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.school_outlined, color: AppColors.accentOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    s.classSection,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildEmptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildExamCard(ExamSession e) {
    final title = e.examName.isNotEmpty ? e.examName : e.examType.name;
    final dateRange = e.formattedStartDate.isNotEmpty &&
            e.formattedEndDate.isNotEmpty
        ? '${e.formattedStartDate} – ${e.formattedEndDate}'
        : '';

    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.accentOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (dateRange.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              dateRange,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            _examSessionSummaryLine(e.summary),
            style: TextStyle(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'exam_result_subject'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'exam_result_max'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'exam_result_obtained'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ..._buildSubjectRows(e.subjects),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubjectRows(List<ExamSubjectResult> subjects) {
    var total = 0;
    for (final s in subjects) {
      total += 1 + s.childResults.length;
    }
    var idx = 0;
    final out = <Widget>[];
    for (final s in subjects) {
      out.add(_subjectRow(s, isLast: ++idx == total));
      for (final c in s.childResults) {
        out.add(_childSubjectRow(c, isLast: ++idx == total));
      }
    }
    return out;
  }

  Widget _subjectRow(ExamSubjectResult s, {required bool isLast}) {
    final obtained = s.displayObtained();
    final isAb = s.isAbsent || obtained == 'AB';
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              s.subject.name.isNotEmpty ? s.subject.name : s.subject.shortName,
              style: TextStyle(fontSize: 14, color: scheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              _maxMarksLabel(s.maxMarks),
              style: TextStyle(fontSize: 14, color: scheme.onSurface),
            ),
          ),
          Expanded(
            child: Text(
              obtained,
              style: TextStyle(
                fontSize: 14,
                color: isAb ? scheme.error : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _childSubjectRow(ExamChildSubjectResult c, {required bool isLast}) {
    final obtained = _childObtained(c);
    final isAb = c.isAbsent || obtained == 'AB';
    final label = c.childSubject.name;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '· $label',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _maxMarksLabel(c.maxMarks),
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              obtained,
              style: TextStyle(
                fontSize: 13,
                color: isAb ? scheme.error : scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
