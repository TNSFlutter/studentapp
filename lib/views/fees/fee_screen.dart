import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../controllers/fee_controller.dart';
import '../../controllers/student_controller.dart';
import '../../helpers/app_navigation.dart';
import '../../models/fee_payment_models.dart';
import '../../models/pending_fee_models.dart';
import '../../models/student_models.dart';
import '../../widgets/common_app_bar.dart';
import 'fee_transaction_detail_screen.dart';
import 'select_fee_screen.dart';
import 'view_detail_screen.dart';

class _PeriodGroup {
  const _PeriodGroup({
    required this.feePeriodId,
    required this.feePeriodName,
    required this.heads,
  });

  final int feePeriodId;
  final String feePeriodName;
  final List<PendingFeeAccountHead> heads;

  bool get hasUnpaid => heads.any((h) => !h.isPaid);

  num get unpaidTotal =>
      heads.where((h) => !h.isPaid).fold<num>(0, (s, h) => s + h.amountAsNum);
}

class FeeScreen extends StatefulWidget {
  final bool showBackButton;
  const FeeScreen({super.key, required this.showBackButton});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  static const int _pendingPageLimit = 10;

  final FeeController _feeController = FeeController();

  PendingFeeData? _pendingMeta;
  final List<PendingFeeAccountHead> _accountHeads = [];
  PendingFeePagination _pendingPagination = PendingFeePagination.empty();
  String? _pendingNextCursor;

  bool _pendingLoading = true;
  bool _pendingLoadingMore = false;
  String? _pendingError;

  static const int _historyLimit = 10;
  final List<FeePaymentHistoryItem> _historyItems = [];
  FeePaymentHistoryPagination _historyPagination =
      FeePaymentHistoryPagination.empty();
  int _historyNextOffset = 0;
  bool _historyLoading = true;
  bool _historyLoadingMore = false;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    _loadPendingFee(reset: true);
    _loadPaymentHistory();
  }

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }

  String _formatMoney(num n) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(n);
  }

  List<_PeriodGroup> _groupPeriods() {
    final map = <int, List<PendingFeeAccountHead>>{};
    for (final h in _accountHeads) {
      map.putIfAbsent(h.feePeriodId, () => []).add(h);
    }
    final ids = map.keys.toList()..sort();
    return ids
        .map(
          (id) => _PeriodGroup(
            feePeriodId: id,
            feePeriodName: map[id]!.first.feePeriodName,
            heads: map[id]!,
          ),
        )
        .toList();
  }

  num _pendingTotal() => _pendingMeta?.pendingFee ?? 0;

  num _paidTotalFromHeads() {
    return _accountHeads
        .where((h) => h.isPaid)
        .fold<num>(0, (s, h) => s + h.amountAsNum);
  }

  bool get _hasPendingAmount {
    final m = _pendingMeta;
    if (m == null) return false;
    if (m.isPaid) return false;
    return m.pendingFee > 0 || _accountHeads.any((h) => !h.isPaid);
  }

  Future<void> _loadPendingFee({required bool reset}) async {
    if (_pendingLoadingMore) return;
    if (!reset) {
      if (!_pendingPagination.hasNextPage) return;
      final c = _pendingNextCursor?.trim();
      if (c == null || c.isEmpty) return;
    }

    if (reset) {
      setState(() {
        _pendingLoading = true;
        _pendingError = null;
        _accountHeads.clear();
        _pendingMeta = null;
        _pendingNextCursor = null;
      });
    } else {
      setState(() => _pendingLoadingMore = true);
    }

    final parsed = await _feeController.fetchPendingFee(
      limit: _pendingPageLimit,
      cursor: reset ? null : _pendingNextCursor,
    );

    if (!mounted) return;

    if (!parsed.success || parsed.data == null) {
      setState(() {
        _pendingError = parsed.message.isNotEmpty
            ? parsed.message
            : 'fees_error_pending'.tr;
        if (reset) {
          _accountHeads.clear();
          _pendingMeta = null;
        }
        _pendingLoading = false;
        _pendingLoadingMore = false;
      });
      return;
    }

    final d = parsed.data!;
    setState(() {
      _pendingMeta = d;
      if (reset) {
        _accountHeads
          ..clear()
          ..addAll(d.accountHeads);
      } else {
        _appendHeadsDeduped(d.accountHeads);
      }
      _pendingPagination = parsed.pagination;
      _pendingNextCursor = parsed.pagination.nextCursor;
      _pendingLoading = false;
      _pendingLoadingMore = false;
    });
  }

  void _appendHeadsDeduped(List<PendingFeeAccountHead> more) {
    final seen = _accountHeads.map((h) => h.dedupeKey).toSet();
    for (final h in more) {
      if (!seen.contains(h.dedupeKey)) {
        seen.add(h.dedupeKey);
        _accountHeads.add(h);
      }
    }
  }

  Future<void> _loadPaymentHistory({bool reset = true}) async {
    if (_historyLoadingMore) return;
    if (!reset && !_historyPagination.hasNextPage) return;

    if (reset) {
      setState(() {
        _historyLoading = true;
        _historyError = null;
        _historyItems.clear();
        _historyPagination = FeePaymentHistoryPagination.empty();
        _historyNextOffset = 0;
      });
    } else {
      setState(() => _historyLoadingMore = true);
    }

    final parsed = await _feeController.fetchPaymentHistory(
      limit: _historyLimit,
      offset: reset ? 0 : _historyNextOffset,
    );
    if (!mounted) return;
    if (parsed.success) {
      setState(() {
        if (reset) {
          _historyItems
            ..clear()
            ..addAll(parsed.data);
        } else {
          _historyItems.addAll(parsed.data);
        }
        _historyPagination = parsed.pagination;
        _historyNextOffset = parsed.pagination.offset + parsed.pagination.limit;
        _historyLoading = false;
        _historyLoadingMore = false;
      });
      return;
    }
    setState(() {
      if (reset) {
        _historyItems.clear();
      }
      _historyError = parsed.message.isNotEmpty
          ? parsed.message
          : 'fees_error_history'.tr;
      _historyLoading = false;
      _historyLoadingMore = false;
    });
  }

  Future<void> _onRefreshFees() async {
    await _loadPendingFee(reset: true);
    await _loadPaymentHistory(reset: true);
  }

  void _onPayNow() {
    AppNavigation.push(context, const SelectFeeScreen());
  }

  int get _periodListChildCount {
    final n = _groupPeriods().length;
    return n + (_pendingPagination.hasNextPage ? 1 : 0);
  }

  Widget _buildPeriodListItem(int i) {
    final groups = _groupPeriods();
    if (i == groups.length) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Center(
          child: _pendingLoadingMore
              ? const CircularProgressIndicator(color: AppColors.accentOrange)
              : TextButton(
                  onPressed: () => _loadPendingFee(reset: false),
                  child: Text('common_load_more'.tr),
                ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildPeriodTile(groups[i]),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    if (p.isEmpty) return '?';
    if (p.length == 1) {
      return p.first.length >= 2
          ? p.first.substring(0, 2).toUpperCase()
          : p.first.toUpperCase();
    }
    return (p.first[0] + p.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final loading = _pendingLoading && _historyLoading;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          CommonAppBar(
            title: 'fees_title'.tr,
            showBackButton: widget.showBackButton,
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentOrange,
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.accentOrange,
                    onRefresh: _onRefreshFees,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              if (Get.isRegistered<StudentController>())
                                Obx(() => _buildStudentCard()),
                              if (Get.isRegistered<StudentController>())
                                const SizedBox(height: 16),
                              if (_hasPendingAmount) _buildPayNowCard(),
                              if (_hasPendingAmount) const SizedBox(height: 20),
                              if (_pendingError == null &&
                                  (_hasPendingAmount ||
                                      _accountHeads.isNotEmpty)) ...[
                                Text(
                                  'fees_periods'.tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: scheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ]),
                          ),
                        ),
                        if (_pendingError != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pendingError!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _loadPendingFee(reset: true),
                                    child: Text('common_retry'.tr),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (_pendingLoading)
                          const SliverFillRemaining(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentOrange,
                              ),
                            ),
                          )
                        else if (!_hasPendingAmount)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                'fees_no_outstanding'.tr,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        else if (_periodListChildCount == 0)
                          const SliverToBoxAdapter(child: SizedBox.shrink())
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => _buildPeriodListItem(i),
                                childCount: _periodListChildCount,
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              'fees_transaction_history'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: scheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        if (_historyError != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _historyError!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _loadPaymentHistory(reset: true),
                                    child: Text('common_retry'.tr),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (_historyLoading)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.accentOrange,
                                ),
                              ),
                            ),
                          )
                        else if (_historyItems.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text('fees_no_transaction_history'.tr),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildTransactionItem(
                                    _historyItems[i],
                                  ),
                                ),
                                childCount: _historyItems.length,
                              ),
                            ),
                          ),
                        if (_historyPagination.hasNextPage)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                              child: Center(
                                child: _historyLoadingMore
                                    ? const CircularProgressIndicator(
                                        color: AppColors.accentOrange,
                                      )
                                    : TextButton(
                                        onPressed: () =>
                                            _loadPaymentHistory(reset: false),
                                        child: Text('common_load_more'.tr),
                                      ),
                              ),
                            ),
                          )
                        else
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sc = Get.find<StudentController>();
    if (sc.students.isEmpty) {
      return const SizedBox.shrink();
    }
    final idx = sc.selectedStudentIndex.value;
    if (idx < 0 || idx >= sc.students.length) {
      return const SizedBox.shrink();
    }
    final Student s = sc.students[idx];
    final name = s.student.trim().isEmpty ? '—' : s.student;
    final cls = s.classSection?.trim().isNotEmpty == true
        ? s.classSection!.trim()
        : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.28 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.accentOrange.withValues(alpha: 0.15),
            child: Text(
              _initials(name),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.accentOrange,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                if (cls.isNotEmpty)
                  Text(
                    cls,
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
    );
  }

  Widget _buildPayNowCard() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pending = _pendingTotal();
    final paid = _paidTotalFromHeads();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.selectedCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.28 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'fees_action_needed'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'fees_total_pending'.tr,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                _formatMoney(pending),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          if (paid > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'fees_tab_paid'.tr,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  _formatMoney(paid),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _onPayNow,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'fees_pay_now'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTile(_PeriodGroup g) {
    final scheme = Theme.of(context).colorScheme;
    final unpaid = g.hasUnpaid;
    final overdue = unpaid && g.unpaidTotal > 0;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: unpaid
            ? () => AppNavigation.push(
                context,
                ViewDetailScreen(feePeriodId: g.feePeriodId),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            g.feePeriodName,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        if (overdue)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.statusRed.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'fees_period_overdue'.tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      unpaid
                          ? '${_formatMoney(g.unpaidTotal)} · ${'common_due'.tr}'
                          : 'common_paid'.tr,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (unpaid)
                Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(FeePaymentHistoryItem item) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final month = item.paymentDate.isNotEmpty
        ? DateFormat('MMM').format(
            DateTime.tryParse(item.paymentDate)?.toLocal() ?? DateTime.now(),
          )
        : '---';
    final title = item.feePeriodsLabel.isNotEmpty
        ? item.feePeriodsLabel
        : (item.description.isNotEmpty
              ? item.description
              : 'fees_payment_label'.tr);
    final dateTime = item.formattedPaymentDate.isNotEmpty
        ? item.formattedPaymentDate
        : item.paymentDate;
    final amount = item.formattedAmount.isNotEmpty
        ? item.formattedAmount
        : '₹ ${item.paymentAmount}';
    final status = item.paymentStatus.isNotEmpty
        ? item.paymentStatus
        : 'common_completed'.tr;
    final isSuccess =
        status.toLowerCase() == 'completed' ||
        status.toLowerCase() == 'success' ||
        status.toLowerCase() == 'received';

    return GestureDetector(
      onTap: () {
        AppNavigation.push(context, FeeTransactionDetailScreen(item: item));
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.22 : 0.04,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  month.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    dateTime,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? AppColors.statusGreen.withValues(alpha: 0.15)
                        : AppColors.statusRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSuccess
                          ? AppColors.statusGreen
                          : AppColors.statusRed,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
