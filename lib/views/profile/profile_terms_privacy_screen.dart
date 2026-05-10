import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/theme_adaptive.dart';
import 'profile_theme.dart';

class ProfileTermsPrivacyScreen extends StatelessWidget {
  const ProfileTermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: AppBar(
        backgroundColor: ProfileTheme.headerOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('profile_terms_privacy'.tr),
            Text(
              'App version 1.2.4',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _docTile(context, Icons.description_outlined, Colors.blue,
              'terms_service'.tr, 'terms_updated'.tr),
          _docTile(context, Icons.lock_outline, Colors.green,
              'terms_privacy_policy'.tr, null),
          _docTile(context, Icons.shield_outlined, Colors.orange,
              'terms_data_usage'.tr, null),
          _docTile(
              context, Icons.code, Colors.purple, 'terms_open_source'.tr, null),
          const SizedBox(height: 16),
          Text(
            'terms_app_info'.tr,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Table(
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              children: [
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'terms_app_version'.tr,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      '1.2.4 (build 204)',
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'terms_platform'.tr,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'terms_platform_value'.tr,
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'terms_last_updated'.tr,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      '15 Apr 2025',
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'terms_school_erp'.tr,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'myschool.levnext.com',
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: scheme.surface,
            leading: const Icon(Icons.system_update, color: ProfileTheme.headerOrange),
            title: Text(
              'terms_check_updates'.tr,
              style: TextStyle(color: scheme.onSurface),
            ),
            subtitle: Text(
              'terms_latest_version'.tr,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ThemeAdaptive.softTint(
                  context,
                  const Color(0xFFDCFCE7),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'terms_up_to_date'.tr,
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _docTile(
    BuildContext context,
    IconData icon,
    Color c,
    String title,
    String? subtitle,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ThemeAdaptive.softTint(
            context,
            Color.alphaBlend(c.withValues(alpha: 0.2), Colors.white),
          ),
          child: Icon(icon, color: c),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        onTap: () {},
      ),
    );
  }
}
