import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../../controllers/class_test_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/class_test_models.dart';

class ClassTestScreen extends StatefulWidget {
  const ClassTestScreen({super.key});

  @override
  State<ClassTestScreen> createState() => _ClassTestScreenState();
}

class _ClassTestScreenState extends State<ClassTestScreen> {
  final ClassTestController _classTestController = ClassTestController();

  static const int _pageLimit = 10;

  ClassTestStudent? _student;
  List<ClassTestResult> _todayResults = [];
  ClassTestSummary _todaySummary = ClassTestSummary.empty();
  List<ClassTestResult> _previousResults = [];
  ClassTestSummary _previousSummary = ClassTestSummary.empty();
  ClassTestPagination _pagination = ClassTestPagination.empty();
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
    _classTestController.dispose();
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
    final parsed = await _classTestController.fetchClassTests(
      limit: _pageLimit,
      cursor: cursor,
    );

    if (!mounted) return;

    if (!parsed.success || parsed.data == null) {
      setState(() {
        _error = parsed.message.isNotEmpty
            ? parsed.message
            : 'class_test_error_load'.tr;
        if (reset) {
          _todayResults = [];
          _previousResults = [];
        }
        _loading = false;
        _loadingMore = false;
      });
      return;
    }

    final d = parsed.data!;
    setState(() {
      _student = d.student;
      _todayResults = List<ClassTestResult>.from(d.today.results);
      _todaySummary = d.today.summary;
      if (reset) {
        _previousResults = List<ClassTestResult>.from(d.previous.results);
      } else {
        _appendPreviousDeduped(d.previous.results);
      }
      _previousSummary = d.previous.summary;
      _pagination = parsed.pagination;
      _nextCursor = parsed.pagination.nextCursor;
      _loading = false;
      _loadingMore = false;
    });
  }

  void _appendPreviousDeduped(List<ClassTestResult> more) {
    final seen = _previousResults.map((e) => e.id).toSet();
    for (final r in more) {
      if (!seen.contains(r.id)) {
        seen.add(r.id);
        _previousResults.add(r);
      }
    }
  }

  Future<void> _loadMore() => _fetch(reset: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeAdaptive.warmPageBackground(context),
      appBar: CommonAppBar(title: 'class_test_title'.tr),
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
                    _buildSectionTitle('class_test_today'.tr),
                    const SizedBox(height: 8),
                    _buildSummaryRow(_todaySummary),
                    const SizedBox(height: 12),
                    if (_todayResults.isEmpty)
                      _buildEmptyHint('class_test_none_today'.tr)
                    else
                      ..._todayResults.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildResultCard(r),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('class_test_previous'.tr),
                    const SizedBox(height: 8),
                    _buildSummaryRow(_previousSummary),
                    const SizedBox(height: 12),
                    if (_previousResults.isEmpty)
                      _buildEmptyHint('class_test_none_previous'.tr)
                    else
                      ..._previousResults.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildResultCard(r),
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

  Widget _buildStudentHeader(ClassTestStudent s) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.accentOrange.withValues(alpha: 0.12)
              : const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.35),
          ),
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

  Widget _buildSummaryRow(ClassTestSummary s) {
    return Text(
      '${'common_total'.tr} ${s.totalTests} · ${'common_present'.tr} ${s.presentTests} · '
      '${'common_absent'.tr} ${s.absentTests} · N/A ${s.naTests}',
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildEmptyHint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildResultCard(ClassTestResult r) {
    final scheme = Theme.of(context).colorScheme;
    final title = r.subject.name.isNotEmpty
        ? '${r.subject.name} · Class test'
        : r.classTestName;
    final dateLabel = r.formattedTestDate.isNotEmpty
        ? r.formattedTestDate
        : r.testDate;
    final obtained = r.isAbsent
        ? 'common_absent'.tr
        : (r.isNa ? 'N/A' : r.obtainedMarks);
    final pct = r.isAbsent || r.isNa ? '' : ' (${r.percentage.toStringAsFixed(1)}%)';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: r.isAbsent || r.isNa
                  ? scheme.outline
                  : AppColors.accentOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(
              r.isAbsent
                  ? Icons.event_busy
                  : (r.isNa ? Icons.help_outline : Icons.checklist),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
                  '${'class_test_date'.tr}: $dateLabel',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (r.marksStatus.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    r.marksStatus,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'class_test_max_marks'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${r.maxMarks}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'exam_result_obtained'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$obtained$pct',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    r.formattedCreatedOn.isNotEmpty
                        ? r.formattedCreatedOn
                        : r.createdOn,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
