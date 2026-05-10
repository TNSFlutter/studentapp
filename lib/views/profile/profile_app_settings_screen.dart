import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/locale_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../helpers/app_navigation.dart';
import '../settings/change_language_screen.dart';

class ProfileAppSettingsScreen extends StatefulWidget {
  const ProfileAppSettingsScreen({super.key});

  @override
  State<ProfileAppSettingsScreen> createState() =>
      _ProfileAppSettingsScreenState();
}

class _ProfileAppSettingsScreenState extends State<ProfileAppSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text('profile_app_settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'profile_app_settings_subtitle'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            tileColor: scheme.surface,
            title: Text('more_change_language'.tr),
            subtitle: Text(
              Get.find<LocaleController>().locale.languageCode.toUpperCase(),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                AppNavigation.push(context, const ChangeLanguageScreen()),
          ),
          const SizedBox(height: 10),
          GetBuilder<ThemeController>(
            builder: (themeController) {
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                tileColor: scheme.surface,
                title: Text('theme_dark'.tr),
                subtitle: Text(
                  themeController.themeMode == ThemeMode.system
                      ? 'System'
                      : themeController.themeMode.name.capitalizeFirst ?? '',
                ),
                trailing: Switch(
                  value: themeController.isDarkMode,
                  onChanged: themeController.setDarkMode,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
