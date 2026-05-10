import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helpers/theme_adaptive.dart';
import 'profile_theme.dart';

class ProfileNotificationSettingsScreen extends StatefulWidget {
  const ProfileNotificationSettingsScreen({super.key});

  @override
  State<ProfileNotificationSettingsScreen> createState() =>
      _ProfileNotificationSettingsScreenState();
}

class _ProfileNotificationSettingsScreenState
    extends State<ProfileNotificationSettingsScreen> {
  bool _fees = true;
  bool _attendance = true;
  bool _notices = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: AppBar(
        backgroundColor: ProfileTheme.headerOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('notifications_title'.tr),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'profile_notifications_subtitle'.tr,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _tile(context, 'notif_fee_reminders'.tr, _fees, (v) => setState(() => _fees = v)),
          _tile(context, 'more_attendance'.tr, _attendance, (v) => setState(() => _attendance = v)),
          _tile(context, 'notif_school_notices'.tr, _notices, (v) => setState(() => _notices = v)),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ProfileTheme.headerOrange,
          ),
        ],
      ),
    );
  }
}
