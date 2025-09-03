import 'package:flutter/material.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';

class GatePassScreen extends StatefulWidget {
  const GatePassScreen({super.key});

  @override
  State<GatePassScreen> createState() => _GatePassScreenState();
}

class _GatePassScreenState extends State<GatePassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Gate Pass'),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF5F5F5)),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Main Gate Pass Card
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildGatePassCard(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGatePassCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // School Logo and Name Section
            _buildSchoolSection(),
            const SizedBox(height: 24),

            // Student Information Section
            _buildStudentSection(),
            const SizedBox(height: 32),

            // QR Code Section
            _buildQRCodeSection(),
            const SizedBox(height: 16),

            // Instruction Text
            _buildInstructionText(),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolSection() {
    return Row(
      children: [
        // School Logo
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Outer Ring
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'JANTA SHIKSHA SADAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Inner Ring
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.school, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // School Name and Session
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Janta Shiksha Sadan School',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '2025-26 Session',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                'A School with Difference',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStudentSection() {
    return Column(
      children: [
        const Text(
          'Himanshi Mehra',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Class 5-B | Roll No: 3 | Adm No: 5478',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Stack(
        children: [
          // QR Code Pattern
          CustomPaint(size: const Size(200, 200), painter: QRCodePainter()),
          // Student Photo in Center
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                image: const DecorationImage(
                  image: AssetImage('assets/images/student_photo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return const Text(
      'Please scan this QR Code at Gate to enter the school premises.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class QRCodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final double cellSize = size.width / 25; // 25x25 grid

    // Draw QR code pattern
    for (int row = 0; row < 25; row++) {
      for (int col = 0; col < 25; col++) {
        // Create a simple QR-like pattern
        bool shouldFill = _shouldFillCell(row, col);

        if (shouldFill) {
          canvas.drawRect(
            Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  bool _shouldFillCell(int row, int col) {
    // Create a deterministic pattern that looks like a QR code
    // This is a simplified version - real QR codes have specific patterns

    // Finder patterns (corners)
    if ((row < 7 && col < 7) || // Top-left
        (row < 7 && col > 17) || // Top-right
        (row > 17 && col < 7)) {
      // Bottom-left
      return (row + col) % 2 == 0;
    }

    // Center area (where photo goes) - leave empty
    if (row >= 9 && row <= 15 && col >= 9 && col <= 15) {
      return false;
    }

    // Random pattern for the rest
    return (row * 3 + col * 7) % 3 == 0;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
