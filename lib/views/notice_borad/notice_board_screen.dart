import 'package:flutter/material.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import 'notice_board_detail_screen.dart';

class NoticeBoardScreen extends StatefulWidget {
  const NoticeBoardScreen({super.key});

  @override
  State<NoticeBoardScreen> createState() => _NoticeBoardScreenState();
}

class _NoticeBoardScreenState extends State<NoticeBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Notice Board'),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Main Notice Card
              Padding(
                padding: const EdgeInsets.all(20),
                child: _buildNoticeCard(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NoticeBoardDetailScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
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
            // Illustration Area
            _buildIllustrationArea(),

            // Service Title and Tagline
            _buildServiceTitle(),

            // Features Section
            _buildFeaturesSection(),

            // Branding Section
            _buildBrandingSection(),

            // Notice Content
            _buildNoticeContent(),

            // Footer Action Bar
            _buildFooterActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustrationArea() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
        ),
      ),
      child: Stack(
        children: [
          // School Building Background
          Positioned(
            left: 20,
            top: 40,
            child: Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'SCHOLAR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

          // School Bus
          Positioned(
            left: 30,
            bottom: 60,
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.directions_bus,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),

          // Location Pin
          Positioned(
            left: 25,
            bottom: 45,
            child: const Icon(Icons.location_on, color: Colors.red, size: 16),
          ),

          // Boy with RFID Card
          Positioned(
            right: 40,
            bottom: 40,
            child: Column(
              children: [
                // Boy
                Container(
                  width: 40,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.accentOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(height: 8),
                // RFID Card
                Container(
                  width: 20,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          // RFID Reader
          Positioned(
            right: 20,
            bottom: 80,
            child: Container(
              width: 30,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Icon(Icons.wifi, color: Colors.white, size: 12),
              ),
            ),
          ),

          // Scholar Logo (Top Right)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: AppColors.accentOrange,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'X',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Dashed Lines
          Positioned(
            left: 80,
            bottom: 75,
            child: CustomPaint(
              size: const Size(100, 2),
              painter: DashedLinePainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTitle() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RFID CARD SERVICE',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Smart ID Card Solution for Schools',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enhance Safety, Automate Attendance, and Stay Connected',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildFeatureItem(
            icon: Icons.phone_android,
            title: 'Parents & Staff Mobile Apps',
            description:
                'Instant push notifications when their child enters or leaves school',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.dashboard,
            title: 'School ERP Portal',
            description:
                'Centralized dashboard for managing student records, reports, and attendance.',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.credit_card,
            title: 'RFID Card & Machine',
            description:
                'Enables quick, contactless check-in and check-out. Durable, easy to use, and fully integrated with the ERP system.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.accentOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.accentOrange, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandingSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'LEVNEXT Private Limited',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                'ISO 9001-2015 Certified',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
          const Text(
            'Powered by LevNext',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Row(
            children: const [
              Text(
                'For More Visit: www.xscholar.com',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              SizedBox(width: 4),
              Icon(Icons.circle, color: Colors.pink, size: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Smart Card for your Child',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Our School is now Digital for your children, we tried each and everything to provide your child best.',
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterActionBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 16),
              SizedBox(width: 8),
              Text(
                'Add Comment',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const Text(
            '10 May 2025, 03:30 PM',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
