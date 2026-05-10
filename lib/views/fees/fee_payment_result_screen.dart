import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common_app_bar.dart';

/// Shown after Razorpay (or similar) checkout with a clear success or failure state.
class FeePaymentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String? amountLabel;
  final String? studentLine;
  final String? transactionId;
  final String? orderId;
  final String? message;

  const FeePaymentResultScreen({
    super.key,
    required this.isSuccess,
    this.amountLabel,
    this.studentLine,
    this.transactionId,
    this.orderId,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = isSuccess
        ? 'fee_payment_result_success_title'.tr
        : 'fee_payment_result_failure_title'.tr;
    final body = message?.trim().isNotEmpty == true
        ? message!.trim()
        : (isSuccess
            ? 'fee_payment_result_success_body'.tr
            : 'fee_payment_result_failure_body'.tr);

    return Scaffold(
      appBar: CommonAppBar(title: title),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: (isSuccess ? Colors.green : AppColors.statusRed)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSuccess ? Icons.check_rounded : Icons.close_rounded,
                              size: 48,
                              color: isSuccess ? const Color(0xFF15803D) : AppColors.statusRed,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.45,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (studentLine != null && studentLine!.trim().isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Text(
                              studentLine!.trim(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                          if (amountLabel != null && amountLabel!.trim().isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              amountLabel!.trim(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ],
                          if (transactionId != null && transactionId!.trim().isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${'fee_payment_result_transaction_id'.tr} ${transactionId!.trim()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                          if (orderId != null && orderId!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '${'fee_payment_result_order_id'.tr} ${orderId!.trim()}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'fee_payment_result_done'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
