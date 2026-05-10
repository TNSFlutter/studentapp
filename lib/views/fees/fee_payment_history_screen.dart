import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/fee_controller.dart';
import '../../models/fee_payment_models.dart';
import '../../widgets/common_app_bar.dart';

class FeePaymentHistoryScreen extends StatefulWidget {
  const FeePaymentHistoryScreen({super.key});

  @override
  State<FeePaymentHistoryScreen> createState() =>
      _FeePaymentHistoryScreenState();
}

class _FeePaymentHistoryScreenState extends State<FeePaymentHistoryScreen> {
  static const int _limit = 10;

  final FeeController _feeController = FeeController();

  final List<FeePaymentHistoryItem> _items = [];
  int _offset = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  bool _hasNext = false;

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
  }

  @override
  void dispose() {
    _feeController.dispose();
    super.dispose();
  }

  Future<void> _fetch({required bool reset}) async {
    if (_loadingMore) return;
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _offset = 0;
        _items.clear();
        _hasNext = false;
      });
    } else {
      if (!_hasNext) return;
      setState(() => _loadingMore = true);
    }

    final requestOffset = reset ? 0 : _offset;

    final parsed = await _feeController.fetchPaymentHistory(
      limit: _limit,
      offset: requestOffset,
    );

    if (!mounted) return;

    if (parsed.success) {
      setState(() {
        if (reset) {
          _items
            ..clear()
            ..addAll(parsed.data);
        } else {
          _items.addAll(parsed.data);
        }
        final p = parsed.pagination;
        _hasNext = p.hasNextPage;
        _offset = requestOffset + _limit;
        _loading = false;
        _loadingMore = false;
      });
      return;
    }

    setState(() {
      _error = parsed.message.isNotEmpty
          ? parsed.message
          : 'fee_history_error_load'.tr;
      _loading = false;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'fee_history_title'.tr),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
        child: RefreshIndicator(
          color: AppColors.accentOrange,
          onRefresh: () => _fetch(reset: true),
          child: _loading && _items.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 120),
                    Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                )
              : _error != null && _items.isEmpty
                  ? ListView(
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
                            onPressed: () => _fetch(reset: true),
                            child: Text('common_retry'.tr),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        for (final item in _items) _PaymentTile(item: item),
                        if (_loadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
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
                          ),
                        if (_hasNext && !_loadingMore)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: OutlinedButton(
                              onPressed: () => _fetch(reset: false),
                              child: Text('common_load_more'.tr),
                            ),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final FeePaymentHistoryItem item;

  const _PaymentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${item.receiptNo}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentOrange,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                item.formattedAmount.isNotEmpty
                    ? item.formattedAmount
                    : '₹${item.paymentAmount}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.studentName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.classSection,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.formattedPaymentDate.isNotEmpty
                      ? item.formattedPaymentDate
                      : item.paymentDate,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.payment_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                item.paymentMode,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
          if (item.feePeriodsLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${'fees_periods'.tr}: ${item.feePeriodsLabel}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.paymentStatus,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
