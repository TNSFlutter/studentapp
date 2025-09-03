import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/common_app_bar.dart';
import 'select_fee_screen.dart';
import 'view_detail_screen.dart';

class FeeScreen extends StatefulWidget {
  final bool showBackButton;
  const FeeScreen({super.key, required this.showBackButton});

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7ED), // Light orange background
        ),
        child: Column(
          children: [
            // Top Header Section
            CommonAppBar(title: 'Fees', showBackButton: widget.showBackButton),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Action Needed: Pay Now Section
                      const Text(
                        'Action Needed: Pay Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
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
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.attach_money,
                                color: AppColors.textBlack,
                                size: 25,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Monthly + Transport Fee + Registration Fee',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Due Date is 10 April, 2025',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.statusRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textDarkGrey,
                                    ),
                                  ),
                                  const Text(
                                    '₹ 29000',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textBlack,
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
                                    builder: (context) =>
                                        const SelectFeeScreen(),
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
                      const SizedBox(height: 32),
                      // Transaction History Section
                      const Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // TODAY Section
                      _buildTransactionSection(
                        title: 'TODAY',
                        transactions: [
                          {
                            'month': 'APR',
                            'description': 'Admission Fee',
                            'dateTime': '13 Apr, 09:45 PM',
                            'amount': '₹ 12,000',
                            'status': 'Received',
                            'isSuccess': true,
                          },
                        ],
                      ),
                      const SizedBox(height: 24),
                      // PREVIOUS MONTH Section
                      _buildTransactionSection(
                        title: 'PREVIOUS MONTH',
                        transactions: [
                          {
                            'month': 'MAR',
                            'description': 'Transport Fee',
                            'dateTime': '25 Mar, 10:07 AM',
                            'amount': '₹ 2,000',
                            'status': 'Received',
                            'isSuccess': true,
                          },
                          {
                            'month': 'MAR',
                            'description': 'Monthly Fee',
                            'dateTime': '13 Mar, 09:45 PM',
                            'amount': '₹ 12,000',
                            'status': 'Received',
                            'isSuccess': true,
                          },
                          {
                            'month': 'MAR',
                            'description': 'Monthly Fee',
                            'dateTime': '13 Mar, 09:45 PM',
                            'amount': '₹ 12,000',
                            'status': 'Failed',
                            'isSuccess': false,
                          },
                        ],
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

  Widget _buildTransactionSection({
    required String title,
    required List<Map<String, dynamic>> transactions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title with line
        Row(
          children: [
            Expanded(
              child: Container(height: 1, color: AppColors.doodleLightGrey),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDarkGrey,
                ),
              ),
            ),
            Expanded(
              child: Container(height: 1, color: AppColors.doodleLightGrey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Transaction items
        ...transactions.map(
          (transaction) => _buildTransactionItem(transaction),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewDetailScreen()),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            // Month badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  transaction['month'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accentOrange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction['dateTime'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textDarkGrey,
                    ),
                  ),
                ],
              ),
            ),
            // Amount and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction['amount'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: transaction['isSuccess']
                        ? AppColors.statusGreen.withValues(alpha: 0.1)
                        : AppColors.statusRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    transaction['status'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: transaction['isSuccess']
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

// Custom painter for header doodles
class FeeHeaderDoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.doodleLightGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Globe
    _drawGlobe(canvas, paint, Offset(size.width * 0.1, size.height * 0.3));

    // Number 1
    _drawNumber1(canvas, paint, Offset(size.width * 0.2, size.height * 0.6));

    // Test tubes
    _drawTestTubes(canvas, paint, Offset(size.width * 0.7, size.height * 0.2));

    // Rocket
    _drawRocket(canvas, paint, Offset(size.width * 0.8, size.height * 0.7));

    // Stars
    _drawStars(canvas, paint, Offset(size.width * 0.3, size.height * 0.8));
  }

  void _drawGlobe(Canvas canvas, Paint paint, Offset center) {
    canvas.drawCircle(center, 15, paint);
    canvas.drawLine(
      Offset(center.dx - 15, center.dy),
      Offset(center.dx + 15, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy + 15),
      paint,
    );
  }

  void _drawNumber1(Canvas canvas, Paint paint, Offset center) {
    canvas.drawLine(
      Offset(center.dx, center.dy - 10),
      Offset(center.dx, center.dy + 10),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - 5, center.dy - 8),
      Offset(center.dx, center.dy - 10),
      paint,
    );
  }

  void _drawTestTubes(Canvas canvas, Paint paint, Offset center) {
    // First test tube
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 8, height: 20),
        const Radius.circular(4),
      ),
      paint,
    );
    // Second test tube
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx + 15, center.dy),
          width: 8,
          height: 20,
        ),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  void _drawRocket(Canvas canvas, Paint paint, Offset center) {
    // Rocket body
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 12, height: 20),
      paint,
    );
    // Rocket tip
    final path = Path()
      ..moveTo(center.dx - 6, center.dy - 10)
      ..lineTo(center.dx, center.dy - 20)
      ..lineTo(center.dx + 6, center.dy - 10)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawStars(Canvas canvas, Paint paint, Offset center) {
    for (int i = 0; i < 3; i++) {
      final starCenter = Offset(center.dx + i * 8, center.dy);
      _drawStar(canvas, paint, starCenter, 3);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * 2 * 3.14159 / 5;
      final x = center.dx + size * cos(angle);
      final y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
