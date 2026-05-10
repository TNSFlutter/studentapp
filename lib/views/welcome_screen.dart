import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../helpers/app_navigation.dart';
import 'auth/login_screen.dart';

/// Welcome screen — matches the final mockup:
///   peach gradient hero  →  top sticker zone  →  logo + branding
///                        →  bottom sticker zone  →  white action footer
///
/// Stickers are positioned in dedicated zones above and below the centerpiece
/// so they never overlap the logo, headline, or tagline.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // ---- palette ----
  static const Color _navyHeading = Color(0xFF1E2A78);
  static const Color _gradientPeachTop = Color(0xFFFFEAD5); // top of bg
  static const Color _gradientPeachMid = Color(0xFFFFF4ED); // mid of bg
  static const Color _gradientCream = Color(0xFFFFFAF6); // near bottom
  static const Color _bodyGrey = Color(0xFF4B5563);
  static const Color _peachIconBg = Color(0xFFFFF4ED);
  static const Color _greenFillBg = Color(0xFFE1F5EE);
  static const Color _greenIcon = Color(0xFF0F6E56);
  static const Color _badgeBorder = Color(0xFFFFD4B8);

  late final AnimationController _stickerController;
  double _scale = 1.0;

  double _rs(double value) => value * _scale;

  @override
  void initState() {
    super.initState();
    _stickerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _stickerController.dispose();
    super.dispose();
  }

  /// Staggered fade + scale per sticker (0..3)
  double _stickerProgress(int index) {
    const start = 0.04;
    const stagger = 0.14;
    const window = 0.42;
    final t = ((_stickerController.value - start - index * stagger) / window)
        .clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(t);
  }

  Widget _animatedSticker({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _stickerController,
      builder: (context, _) {
        final p = _stickerProgress(index);
        return Opacity(
          opacity: p,
          child: Transform.scale(
            scale: 0.9 + 0.1 * p,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    _scale = (screenWidth / 393.0).clamp(0.88, 1.18);

    return Scaffold(
      // Background gradient drawn at Scaffold level so it shows through
      // both the scrollable hero AND the negative-space areas around stickers.
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 0.70, 1.0],
            colors: [
              _gradientPeachTop,
              _gradientPeachMid,
              _gradientCream,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // ===== SCROLLABLE HERO =====
            Expanded(
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ----- TOP STICKER ZONE -----
                      // Fixed-height band that holds the two top stickers.
                      // Centerpiece sits BELOW this — never overlapped.
                      SizedBox(
                        height: _rs(140),
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Decorative blobs behind everything
                            Positioned(
                              top: -_rs(60),
                              right: -_rs(60),
                              child: _blob(_rs(210), 0.08, AppColors.accentOrange),
                            ),
                            Positioned(
                              top: _rs(20),
                              left: -_rs(40),
                              child: _blob(_rs(120), 0.05, _navyHeading),
                            ),

                            // Sticker 1: Attendance (top-left, -7°)
                            Positioned(
                              left: _rs(16),
                              top: _rs(14),
                              child: _animatedSticker(
                                index: 0,
                                child: Transform.rotate(
                                  angle: -7 * math.pi / 180,
                                  child: _stickerAttendance(),
                                ),
                              ),
                            ),

                            // Sticker 2: Grade A+ (top-right, +9°)
                            Positioned(
                              right: _rs(18),
                              top: _rs(22),
                              child: _animatedSticker(
                                index: 1,
                                child: Transform.rotate(
                                  angle: 9 * math.pi / 180,
                                  child: _stickerGrade(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ----- CENTERPIECE -----
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: _rs(24)),
                        child: Column(
                          children: [
                            // Logo with soft glow
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow halo
                                Container(
                                  width: _rs(170),
                                  height: _rs(170),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.accentOrange.withValues(
                                          alpha: 0.14,
                                        ),
                                        AppColors.accentOrange.withValues(
                                          alpha: 0.0,
                                        ),
                                      ],
                                      stops: const [0.0, 0.7],
                                    ),
                                  ),
                                ),
                                // Logo card
                                Container(
                                  width: _rs(112),
                                  height: _rs(112),
                                  padding: EdgeInsets.all(_rs(16)),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.accentOrange
                                            .withValues(alpha: 0.18),
                                        blurRadius: 40,
                                        offset: const Offset(0, 16),
                                      ),
                                      BoxShadow(
                                        color: _navyHeading.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/big_logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: _rs(20)),

                            // Wordmark
                            Text(
                              'XScholar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _rs(36),
                                fontWeight: FontWeight.w700,
                                color: _navyHeading,
                                letterSpacing: -0.6,
                                height: 1.05,
                              ),
                            ),
                            SizedBox(height: _rs(10)),

                            // PARENTS APP pill
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: _rs(16),
                                vertical: _rs(6),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: _badgeBorder,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'PARENTS APP',
                                style: TextStyle(
                                  fontSize: _rs(11),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                  color: AppColors.accentOrange,
                                ),
                              ),
                            ),
                            SizedBox(height: _rs(14)),

                            // Tagline
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 240),
                              child: Text(
                                "Stay close to every moment of your child's school day.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _rs(16),
                                  fontWeight: FontWeight.w600,
                                  height: 1.55,
                                  color: _bodyGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ----- BOTTOM STICKER ZONE -----
                      SizedBox(
                        height: _rs(140),
                        width: double.infinity,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Sticker 3: Fees (bottom-left, -5°)
                            Positioned(
                              left: _rs(20),
                              top: _rs(26),
                              child: _animatedSticker(
                                index: 2,
                                child: Transform.rotate(
                                  angle: -5 * math.pi / 180,
                                  child: _stickerFees(),
                                ),
                              ),
                            ),

                            // Sticker 4: Notification (bottom-right, +6°)
                            Positioned(
                              right: _rs(18),
                              top: _rs(46),
                              child: _animatedSticker(
                                index: 3,
                                child: Transform.rotate(
                                  angle: 6 * math.pi / 180,
                                  child: _stickerNotify(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ===== ACTION FOOTER (solid white) =====
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -34,
                  left: 0,
                  right: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.55, 1.0],
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.35),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white),
                  padding: EdgeInsets.fromLTRB(_rs(24), _rs(16), _rs(24), _rs(16) + bottomInset),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: _rs(56),
                        child: ElevatedButton(
                          onPressed: () {
                            AppNavigation.push<void>(
                              context,
                              const LoginScreen(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_rs(16)),
                            ),
                          ),
                          child: Text(
                            'Login to your account',
                            style: TextStyle(
                              fontSize: _rs(18),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                  // const SizedBox(height: 14),
                  // Wrap(
                  //   alignment: WrapAlignment.center,
                  //   crossAxisAlignment: WrapCrossAlignment.center,
                  //   children: [
                  //     Text(
                  //       'First time here? ',
                  //       style: TextStyle(
                  //         fontSize: 13,
                  //         height: 1.35,
                  //         color: _bodyGrey,
                  //       ),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.push<void>(
                  //           context,
                  //           MaterialPageRoute<void>(
                  //             builder: (_) => const RegisterScreen(),
                  //           ),
                  //         );
                  //       },
                  //       child: const Text(
                  //         'Create account',
                  //         style: TextStyle(
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.w600,
                  //           color: AppColors.accentOrange,
                  //           height: 1.35,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                      SizedBox(height: _rs(14)),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: _rs(12),
                            height: 1.35,
                            color: Color(0xFF6B7280),
                          ),
                          children: [
                            const TextSpan(text: 'Powered by '),
                            TextSpan(
                              text: 'LevNext',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _bodyGrey,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============ helpers ============

  Widget _blob(double size, double alpha, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
      ),
    );
  }

  // ---------- stickers ----------

  /// White rounded sticker base — used by all white stickers
  Widget _whiteSticker({required Widget child, double radius = 18}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _rs(12), vertical: _rs(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_rs(radius)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentOrange.withValues(alpha: 0.10),
            blurRadius: _rs(24),
            offset: Offset(0, _rs(8)),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Sticker 1 — "PRESENT TODAY / All 3 kids ✨"
  Widget _stickerAttendance() {
    return _whiteSticker(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _rs(34),
            height: _rs(34),
            decoration: BoxDecoration(
              color: _peachIconBg,
              borderRadius: BorderRadius.circular(_rs(10)),
            ),
            child: Icon(
              Icons.task_alt_rounded,
              color: AppColors.accentOrange,
              size: _rs(18),
            ),
          ),
          SizedBox(width: _rs(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PRESENT TODAY',
                style: TextStyle(
                  fontSize: _rs(10.5),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: _rs(2)),
              Text(
                'All 3 kids ✨',
                style: TextStyle(
                  fontSize: _rs(13),
                  fontWeight: FontWeight.w700,
                  color: _navyHeading,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sticker 2 — Navy grade card "SCIENCE / A+ / Riya"
  Widget _stickerGrade() {
    return Container(
      constraints: BoxConstraints(minWidth: _rs(72)),
      padding: EdgeInsets.symmetric(horizontal: _rs(14), vertical: _rs(10)),
      decoration: BoxDecoration(
        color: _navyHeading,
        borderRadius: BorderRadius.circular(_rs(18)),
        boxShadow: [
          BoxShadow(
            color: _navyHeading.withValues(alpha: 0.28),
            blurRadius: _rs(24),
            offset: Offset(0, _rs(8)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'SCIENCE',
            style: TextStyle(
              fontSize: _rs(10.5),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          SizedBox(height: _rs(2)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A+',
                style: TextStyle(
                  fontSize: _rs(24),
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1,
                ),
              ),
              SizedBox(width: _rs(5)),
              Padding(
                padding: EdgeInsets.only(bottom: _rs(2)),
                child: Text(
                  'Riya',
                  style: TextStyle(
                    fontSize: _rs(11),
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentOrange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sticker 3 — "FEES PAID / ₹12,500" with green check
  Widget _stickerFees() {
    return _whiteSticker(
      radius: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _rs(32),
            height: _rs(32),
            decoration: BoxDecoration(
              color: _greenFillBg,
              borderRadius: BorderRadius.circular(_rs(9)),
            ),
            child: Icon(Icons.check_rounded, color: _greenIcon, size: _rs(18)),
          ),
          SizedBox(width: _rs(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FEES PAID',
                style: TextStyle(
                  fontSize: _rs(10.5),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: _rs(1)),
              Text(
                '₹12,500',
                style: TextStyle(
                  fontSize: _rs(14),
                  fontWeight: FontWeight.w800,
                  color: _navyHeading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Sticker 4 — "NEW / Holiday Friday"
  Widget _stickerNotify() {
    return _whiteSticker(
      radius: 16,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _rs(150)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _rs(30),
              height: _rs(30),
              decoration: BoxDecoration(
                color: _peachIconBg,
                borderRadius: BorderRadius.circular(_rs(9)),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AppColors.accentOrange,
                size: _rs(16),
              ),
            ),
            SizedBox(width: _rs(8)),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: _rs(10.5),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: _rs(1)),
                  Text(
                    'Holiday Friday',
                    style: TextStyle(
                      fontSize: _rs(12),
                      fontWeight: FontWeight.w700,
                      color: _navyHeading,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
