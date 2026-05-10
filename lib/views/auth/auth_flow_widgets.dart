import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

/// Reference mock primary orange (header / key actions in auth flow).
const Color kAuthFlowOrange = Color(0xFFFF7D1A);

/// Circular white translucent back control inside the orange header.
class AuthFlowHeaderBackPill extends StatelessWidget {
  const AuthFlowHeaderBackPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.22),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Large top orange header with rounded bottom and decorative circle (reference layout).
class AuthFlowOrangeHeader extends StatelessWidget {
  const AuthFlowOrangeHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBack = true,
    this.heightFraction = 0.30,
  });

  final String title;
  final String subtitle;
  final bool showBack;
  final double heightFraction;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final headerHeight = (media.height * heightFraction).clamp(200.0, 320.0);

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: kAuthFlowOrange),
              ),
            ),
            Positioned(
              right: -56,
              top: -48,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              right: 24,
              top: media.height * 0.08,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBack) const AuthFlowHeaderBackPill(),
                    if (showBack) const SizedBox(height: 20),
                    if (!showBack) const SizedBox(height: 12),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Back control for screens that are not using [AuthFlowOrangeHeader] (legacy / simple).
class AuthFlowBackButton extends StatelessWidget {
  const AuthFlowBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: AppColors.primaryBlue,
        tooltip: 'Back',
      ),
    );
  }
}
