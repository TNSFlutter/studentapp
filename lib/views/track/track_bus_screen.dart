import 'package:flutter/material.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';

class TrackBusScreen extends StatelessWidget {
  const TrackBusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Track Bus'),
      body: Stack(
        children: [
          // Map Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5), // Light grey background for map
            ),
            child: CustomPaint(painter: MapPainter()),
          ),

          // Bus Arrival Banner
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Arriving in 15 min',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'On-Time',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Information Panel at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow('Bus No.', 'DL-16-3368'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Bus Route', 'Vikas Puri Bus Stand'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Pickup Time', '6:45 Am'),
                  const SizedBox(height: 16),
                  _buildInfoRow('Bus Attendant', 'Nelam Devi'),
                  const SizedBox(height: 16),
                  _buildInfoRowWithIcon('Phone No.', '+91-99999-9999'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithIcon(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.phone, color: AppColors.accentOrange, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accentOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom painter for the map background
class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final roadPaint = Paint()
      ..color = Colors.blue.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final greenPaint = Paint()
      ..color = Colors.green.shade300
      ..style = PaintingStyle.fill;

    // Draw roads (horizontal and vertical)
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.3),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.6),
      Offset(size.width, size.height * 0.6),
      paint,
    );

    // Main vertical road (blue)
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );

    // Draw green areas (parks)
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 80, 60),
      greenPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.7, 80, 60),
      greenPaint,
    );

    // Draw map labels
    _drawText(
      canvas,
      'URBAN ESTATE',
      Offset(size.width * 0.1, size.height * 0.15),
      12,
    );
    _drawText(
      canvas,
      'अर्बन एस्टेट',
      Offset(size.width * 0.1, size.height * 0.18),
      10,
    );
    _drawText(
      canvas,
      'SECTOI',
      Offset(size.width * 0.7, size.height * 0.15),
      12,
    );
    _drawText(
      canvas,
      'सेक्टर',
      Offset(size.width * 0.7, size.height * 0.18),
      10,
    );
    _drawText(
      canvas,
      'Subhri - Karnal Rd',
      Offset(size.width * 0.1, size.height * 0.35),
      10,
    );
    _drawText(
      canvas,
      'करनाल डेंटल केयर',
      Offset(size.width * 0.6, size.height * 0.35),
      10,
    );
    _drawText(
      canvas,
      'Veenees, Teeth',
      Offset(size.width * 0.6, size.height * 0.38),
      8,
    );
    _drawText(
      canvas,
      'Shiv Ma',
      Offset(size.width * 0.1, size.height * 0.65),
      10,
    );
    _drawText(canvas, 'शिव', Offset(size.width * 0.1, size.height * 0.68), 8);

    // Draw icons
    _drawHospitalIcon(canvas, Offset(size.width * 0.65, size.height * 0.35));
    _drawBusIcon(canvas, Offset(size.width * 0.3, size.height * 0.45));
    _drawSchoolIcon(canvas, Offset(size.width * 0.8, size.height * 0.75));
  }

  void _drawText(Canvas canvas, String text, Offset offset, double fontSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.black87,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  void _drawHospitalIcon(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // Draw red 'H' circle
    canvas.drawCircle(center, 8, paint);

    // Draw white 'H'
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'H',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 4, center.dy - 8));
  }

  void _drawBusIcon(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    // Draw yellow square with "44"
    canvas.drawRect(
      Rect.fromCenter(center: center, width: 20, height: 20),
      paint,
    );

    // Draw "44" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '44',
        style: TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 8, center.dy - 6));
  }

  void _drawSchoolIcon(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    // Draw graduation cap icon
    final path = Path()
      ..moveTo(center.dx - 8, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..lineTo(center.dx + 6, center.dy - 8)
      ..lineTo(center.dx, center.dy - 12)
      ..lineTo(center.dx - 6, center.dy - 8)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
