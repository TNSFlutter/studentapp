import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/theme_adaptive.dart';
import 'profile_theme.dart';

class ProfileLogoutScreen extends StatefulWidget {
  final String parentName;
  final String phone;
  final String initials;

  const ProfileLogoutScreen({
    super.key,
    required this.parentName,
    required this.phone,
    required this.initials,
  });

  @override
  State<ProfileLogoutScreen> createState() => _ProfileLogoutScreenState();
}

class _ProfileLogoutScreenState extends State<ProfileLogoutScreen> {
  bool _allDevices = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: AppBar(
        backgroundColor: ProfileTheme.headerOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('more_sign_out'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: ThemeAdaptive.softTint(
                  context,
                  const Color(0xFFFFE4E6),
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                size: 48,
                color: scheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'logout_confirm_title'.tr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'logout_confirm_subtitle'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.accentOrange.withValues(
                      alpha: 0.18,
                    ),
                    child: Text(
                      widget.initials,
                      style: const TextStyle(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile_signed_in_as'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          widget.parentName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: scheme.onSurface,
                          ),
                        ),
                        Text(
                          widget.phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  await Get.find<AuthController>().logout();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('more_sign_out'.tr),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.onSurface,
                  side: BorderSide(color: scheme.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text('common_cancel'.tr),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'logout_all_devices_title'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: scheme.onErrorContainer,
                          ),
                        ),
                        Text(
                          'logout_all_devices_subtitle'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: scheme.onErrorContainer.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Switch(
                        value: _allDevices,
                        onChanged: (v) => setState(() => _allDevices = v),
                      ),
                      Text(
                        'logout_all_devices_label'.tr,
                        style: TextStyle(
                          fontSize: 10,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
