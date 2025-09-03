import 'package:flutter/material.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../dashboard/dashboard_screen.dart';

class SelectStudentScreen extends StatefulWidget {
  const SelectStudentScreen({super.key});

  @override
  State<SelectStudentScreen> createState() => _SelectStudentScreenState();
}

class _SelectStudentScreenState extends State<SelectStudentScreen> {
  int _selectedStudentIndex = 0; // 0 for Himanshi (selected), 1 for Avikaa

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Himanshi Mehra',
      'class': 'Class 5-B',
      'rollNo': '3',
      'year': '2025-26',
      'status': 'Present',
      'isPresent': true,
      'profileImage': 'assets/images/student1.png', // Placeholder
    },
    {
      'name': 'Avikaa',
      'class': 'Class 7-B',
      'rollNo': '13',
      'year': '2025-26',
      'status': 'Absent',
      'isPresent': false,
      'profileImage': 'assets/images/student2.png', // Placeholder
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Select Student'),
      body: Column(
        children: [
          // Main content area
          Expanded(
            child: Container(
              color: AppColors.cardWhite,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Instructional text
                    const Text(
                      'Tap to view their Dashboard!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Student cards
                    Expanded(
                      child: ListView.builder(
                        itemCount: _students.length,
                        itemBuilder: (context, index) {
                          final student = _students[index];
                          final isSelected = index == _selectedStudentIndex;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedStudentIndex = index;
                              });
                              // Navigate to dashboard with selected student
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DashboardScreen(selectedStudent: student),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardWhite,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.selectedCardBorder
                                      : AppColors.unselectedCardBorder,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Selection indicator badge
                                  if (isSelected)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accentOrange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: AppColors.cardWhite,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  // Student content
                                  Row(
                                    children: [
                                      // Profile picture
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: AppColors.profilePictureBg,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          color: AppColors.cardWhite,
                                          size: 30,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Student details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student['name'],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              student['class'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textDarkGrey,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              student['rollNo'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textDarkGrey,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              student['year'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textDarkGrey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Status indicator
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: student['isPresent']
                                              ? AppColors.statusGreen
                                                    .withValues(alpha: 0.1)
                                              : AppColors.statusRed.withValues(
                                                  alpha: 0.1,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          student['status'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: student['isPresent']
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
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for header doodles
class HeaderDoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.doodleLightGrey
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw various educational doodles in the header
    _drawGlobe(canvas, paint, size.width * 0.1, size.height * 0.3);
    _drawNumber1(canvas, paint, size.width * 0.2, size.height * 0.2);
    _drawTestTubes(canvas, paint, size.width * 0.3, size.height * 0.4);
    _drawRocket(canvas, paint, size.width * 0.4, size.height * 0.3);
    _drawHeart(canvas, paint, size.width * 0.5, size.height * 0.2);
    _drawPencil(canvas, paint, size.width * 0.6, size.height * 0.4);
    _drawRuler(canvas, paint, size.width * 0.7, size.height * 0.3);
    _drawMusicalNotes(canvas, paint, size.width * 0.8, size.height * 0.2);
  }

  void _drawGlobe(Canvas canvas, Paint paint, double x, double y) {
    canvas.drawCircle(Offset(x, y), 12, paint);
    // Meridians
    canvas.drawLine(Offset(x - 12, y), Offset(x + 12, y), paint);
    canvas.drawLine(Offset(x, y - 12), Offset(x, y + 12), paint);
  }

  void _drawNumber1(Canvas canvas, Paint paint, double x, double y) {
    canvas.drawLine(Offset(x + 8, y), Offset(x + 8, y + 20), paint);
    canvas.drawLine(Offset(x + 4, y + 4), Offset(x + 8, y), paint);
    canvas.drawLine(Offset(x + 4, y + 20), Offset(x + 12, y + 20), paint);
  }

  void _drawTestTubes(Canvas canvas, Paint paint, double x, double y) {
    // Tube 1
    canvas.drawRect(Rect.fromLTWH(x, y, 6, 16), paint);
    // Tube 2
    canvas.drawRect(Rect.fromLTWH(x + 10, y, 6, 16), paint);
  }

  void _drawRocket(Canvas canvas, Paint paint, double x, double y) {
    // Body
    canvas.drawRect(Rect.fromLTWH(x, y, 8, 16), paint);
    // Nose cone
    final path = Path()
      ..moveTo(x + 4, y)
      ..lineTo(x, y - 6)
      ..lineTo(x + 8, y - 6)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Paint paint, double x, double y) {
    final path = Path()
      ..moveTo(x, y + 8)
      ..quadraticBezierTo(x - 6, y - 2, x - 8, y + 8)
      ..quadraticBezierTo(x - 6, y + 12, x, y + 16)
      ..quadraticBezierTo(x + 6, y + 12, x + 8, y + 8)
      ..quadraticBezierTo(x + 6, y - 2, x, y + 8);
    canvas.drawPath(path, paint);
  }

  void _drawPencil(Canvas canvas, Paint paint, double x, double y) {
    // Pencil body
    canvas.drawRect(Rect.fromLTWH(x, y, 3, 16), paint);
    // Pencil tip
    final path = Path()
      ..moveTo(x, y)
      ..lineTo(x + 1.5, y - 4)
      ..lineTo(x + 3, y)
      ..close();
    canvas.drawPath(path, paint);
    // Eraser
    canvas.drawRect(Rect.fromLTWH(x, y + 16, 3, 3), paint);
  }

  void _drawRuler(Canvas canvas, Paint paint, double x, double y) {
    // Ruler body
    canvas.drawRect(Rect.fromLTWH(x, y, 20, 4), paint);
    // Measurement marks
    for (int i = 0; i < 5; i++) {
      final markX = x + i * 4;
      canvas.drawLine(Offset(markX, y), Offset(markX, y + 4), paint);
    }
  }

  void _drawMusicalNotes(Canvas canvas, Paint paint, double x, double y) {
    // Note head
    canvas.drawCircle(Offset(x, y), 2, paint);
    // Stem
    canvas.drawLine(Offset(x + 2, y), Offset(x + 2, y - 8), paint);
    // Flag
    final path = Path()
      ..moveTo(x + 2, y - 8)
      ..quadraticBezierTo(x + 6, y - 8, x + 6, y - 6)
      ..quadraticBezierTo(x + 6, y - 4, x + 2, y - 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
