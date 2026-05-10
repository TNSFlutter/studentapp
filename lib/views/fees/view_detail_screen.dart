import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../../controllers/fee_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/fee_payment_models.dart';
import '../../models/pending_fee_models.dart';

class ViewDetailScreen extends StatefulWidget {
  /// Loads [Endpoints.feeDetails] when set (recommended from fee list).
  final int? feePeriodId;

  const ViewDetailScreen({super.key, this.feePeriodId});

  static String formatMoney(num n) {
    final fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return fmt.format(n);
  }

  static String feePeriodRange(FeePeriodDetailBlock p) {
    final s = DateTime.tryParse(p.startDate)?.toLocal();
    final e = DateTime.tryParse(p.endDate)?.toLocal();
    if (s == null) return '';
    final full = DateFormat('d MMM yyyy');
    if (e == null) return full.format(s);
    return '${DateFormat('d MMM').format(s)} – ${full.format(e)}';
  }

  @override
  State<ViewDetailScreen> createState() => _ViewDetailScreenState();
}

class _ViewDetailScreenState extends State<ViewDetailScreen> {
  final FeeController _feeController = FeeController();

  FeePeriodDetailPayload? _detail;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final id = widget.feePeriodId;
    if (id != null) {
      _load(id);
    }
  }

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _load(int feePeriodId) async {
    setState(() {
      _loading = true;
      _error = null;
      _detail = null;
    });

    final parsed = await _feeController.fetchFeePeriodDetail(feePeriodId);
    if (!mounted) return;

    if (parsed.success && parsed.data != null) {
      setState(() {
        _detail = parsed.data;
        _loading = false;
      });
      return;
    }

    setState(() {
      _error = parsed.message.isNotEmpty
          ? parsed.message
          : 'Unable to load fee details.';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.feePeriodId;

    final periodTitle = _detail != null && _detail!.feePeriod.name.trim().isNotEmpty
        ? _detail!.feePeriod.name.trim()
        : 'fees_title'.tr;

    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: CommonAppBar(
        title: periodTitle,
        showBackButton: true,
      ),
      body: Column(
          children: [
            Expanded(
              child: id == null
                  ? const _PendingFeeLegacyDetail()
                  : RefreshIndicator(
                      color: AppColors.accentOrange,
                      onRefresh: () => _load(id),
                      child: _buildBody(id),
                    ),
            ),
          ],
        ),
    );
  }

  Widget _buildBody(int feePeriodId) {
    if (_loading && _detail == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: CircularProgressIndicator(color: AppColors.accentOrange),
          ),
        ],
      );
    }

    if (_error != null && _detail == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _load(feePeriodId),
              child: const Text('Retry'),
            ),
          ),
        ],
      );
    }

    final d = _detail;
    if (d == null) {
      return const SizedBox.shrink();
    }

    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (d.student.name.isNotEmpty)
              Text(
                d.student.name,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            if (d.student.name.isNotEmpty) const SizedBox(height: 8),
            Text(
              d.paymentSummary.paymentStatus,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: d.paymentSummary.isPaid
                    ? Colors.green.shade700
                    : Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ViewDetailScreen.feePeriodRange(d.feePeriod),
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total amount',
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              d.paymentSummary.formattedTotal.isNotEmpty
                  ? d.paymentSummary.formattedTotal
                  : ViewDetailScreen.formatMoney(d.paymentSummary.totalAmount),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Paid ${d.paymentSummary.formattedPaid.isNotEmpty ? d.paymentSummary.formattedPaid : ViewDetailScreen.formatMoney(d.paymentSummary.paidAmount)} · Pending ${d.paymentSummary.formattedPending.isNotEmpty ? d.paymentSummary.formattedPending : ViewDetailScreen.formatMoney(d.paymentSummary.pendingAmount)}',
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 28),
            Text(
              'Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            ...d.accountHeads.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.accountHeadName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            h.isPaid ? 'Paid' : 'Pending',
                            style: TextStyle(
                              fontSize: 12,
                              color: h.isPaid
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          h.isPaid
                              ? h.displayAmountWhenPaid
                              : (h.formattedAmount.isNotEmpty
                                  ? h.formattedAmount
                                  : h.amount),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        if (!h.isPaid && h.formattedPendingAmount.isNotEmpty)
                          Text(
                            'Due ${h.formattedPendingAmount}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (d.paymentsRaw.isNotEmpty) ...[
              const Divider(height: 28),
              Text(
                'Payments',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...d.paymentsRaw.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    p.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pending for period',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  d.paymentSummary.formattedPending.isNotEmpty
                      ? d.paymentSummary.formattedPending
                      : ViewDetailScreen.formatMoney(
                          d.paymentSummary.pendingAmount,
                        ),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

/// When opened without [feePeriodId], show pending fee from `student/pending-fee`.
class _PendingFeeLegacyDetail extends StatefulWidget {
  const _PendingFeeLegacyDetail();

  @override
  State<_PendingFeeLegacyDetail> createState() =>
      _PendingFeeLegacyDetailState();
}

class _PendingFeeLegacyDetailState extends State<_PendingFeeLegacyDetail> {
  final FeeController _feeController = FeeController();

  PendingFeeData? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final parsed = await _feeController.fetchPendingFee(limit: 10);
    if (!mounted) return;
    if (parsed.success && parsed.data != null) {
      setState(() {
        _data = parsed.data;
        _loading = false;
      });
      return;
    }
    setState(() {
      _error = parsed.message.isNotEmpty
          ? parsed.message
          : 'Could not load pending fee.';
      _loading = false;
    });
  }

  String _componentsLine(PendingFeeData d) {
    final unique = d.accountHeads
        .map((h) => h.accountHeadName)
        .toSet()
        .toList();
    if (unique.isEmpty) return 'Pending fee';
    if (unique.length <= 2) return unique.join(' + ');
    return '${unique[0]} + ${unique[1]} + ${unique.length - 2} more';
  }

  String _periodsLine(PendingFeeData d) {
    final names = d.accountHeads.map((h) => h.feePeriodName).toSet().toList()
      ..sort();
    if (names.isNotEmpty) return names.join(', ');
    return d.feePeriodName;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accentOrange),
      );
    }
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red.shade700),
          ),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }

    final d = _data;
    if (d == null || d.isPaid || d.pendingFee <= 0) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 48),
          Text(
            d?.isPaid == true
                ? 'No pending fee for the current period.'
                : 'You have no outstanding fee right now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    final totalLabel = ViewDetailScreen.formatMoney(d.pendingFee);
    final scheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      color: AppColors.accentOrange,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total pending',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  totalLabel,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                Divider(height: 30, color: scheme.outlineVariant),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.currency_rupee_rounded,
                        color: AppColors.accentOrange,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _componentsLine(d),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Periods: ${_periodsLine(d)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
