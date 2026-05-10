import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../helpers/theme_adaptive.dart';
import '../../models/fee_payment_models.dart';
import '../../widgets/common_app_bar.dart';

class FeeTransactionDetailScreen extends StatelessWidget {
  final FeePaymentHistoryItem item;

  const FeeTransactionDetailScreen({super.key, required this.item});

  Widget _row(BuildContext context, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '—',
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = item.paymentStatus.isNotEmpty
        ? item.paymentStatus
        : 'common_completed'.tr;
    final amount = item.formattedAmount.isNotEmpty
        ? item.formattedAmount
        : '₹${item.paymentAmount}';
    final paidOn = item.formattedPaymentDate.isNotEmpty
        ? item.formattedPaymentDate
        : item.paymentDate;

    return Scaffold(
      backgroundColor: ThemeAdaptive.warmPageBackground(context),
      appBar: CommonAppBar(title: 'fee_transaction_detail_title'.tr),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
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
              Text(
                amount,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'completed'
                      ? AppColors.statusGreen.withValues(alpha: 0.12)
                      : AppColors.statusRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: status.toLowerCase() == 'completed'
                        ? AppColors.statusGreen
                        : AppColors.statusRed,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: scheme.outlineVariant),
              const SizedBox(height: 6),
              _row(context, 'fee_receipt_no'.tr, '#${item.receiptNo}'),
              _row(context, 'fee_student'.tr, item.studentName),
              _row(context, 'common_class'.tr, item.classSection),
              _row(context, 'fee_payment_date'.tr, paidOn),
              _row(context, 'fee_payment_mode'.tr, item.paymentMode),
              _row(context, 'fee_periods'.tr, item.feePeriodsLabel),
              _row(
                context,
                'fee_discount'.tr,
                item.discount.isNotEmpty ? '₹${item.discount}' : '₹0',
              ),
              _row(context, 'fee_payment_id'.tr, item.id.toString()),
              _row(context, 'fee_created_by'.tr, item.createdBy),
              _row(context, 'fee_created_on'.tr, item.createdOn),
            ],
          ),
        ),
      ),
    );
  }
}
