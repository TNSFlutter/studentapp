import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common_app_bar.dart';
import 'pay_fee_screen.dart';
import 'view_detail_screen.dart';

class SelectFeeScreen extends StatefulWidget {
  const SelectFeeScreen({super.key});

  @override
  State<SelectFeeScreen> createState() => _SelectFeeScreenState();
}

class _SelectFeeScreenState extends State<SelectFeeScreen> {
  final List<_FeeItem> feeItems = [
    _FeeItem(
      month: 'April',
      monthCode: 'APR',
      date: '10 Apr, 2025',
      amount: '₹ 29,000',
    ),
    _FeeItem(
      month: 'May',
      monthCode: 'MAY',
      date: '10 Apr, 2025',
      amount: '₹ 9,000',
    ),
    _FeeItem(
      month: 'June',
      monthCode: 'JUN',
      date: '10 Apr, 2025',
      amount: '₹ 19,000',
    ),
    _FeeItem(
      month: 'July',
      monthCode: 'JUL',
      date: '10 Apr, 2025',
      amount: '₹ 2,000',
    ),
    _FeeItem(
      month: 'August',
      monthCode: 'AUG',
      date: '10 Apr, 2025',
      amount: '₹ 29,000',
    ),
    _FeeItem(
      month: 'September',
      monthCode: 'SEP',
      date: '10 Apr, 2025',
      amount: '₹ 29,000',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Select Fee'),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
        child: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Grand Total Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '₹ 29,000',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Grand Total',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textDarkGrey.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PayFeeScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                foregroundColor: AppColors.cardWhite,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Pay Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Fee Structure Section
                      const Text(
                        'Fee Structure',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Fee Items List
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: feeItems.length,
                        itemBuilder: (context, index) {
                          return _buildFeeItem(feeItems[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeItem(_FeeItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentOrange.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Month badge
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.accentOrange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.monthCode,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cardWhite,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Month details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.month,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.date,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textDarkGrey.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          // Amount and View Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewDetailScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeeItem {
  final String month;
  final String monthCode;
  final String date;
  final String amount;

  const _FeeItem({
    required this.month,
    required this.monthCode,
    required this.date,
    required this.amount,
  });
}
