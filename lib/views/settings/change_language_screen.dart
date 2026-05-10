import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants/app_colors.dart';
import '../../controllers/locale_controller.dart';
import '../../helpers/theme_adaptive.dart';
import '../../l10n/app_translations.dart';
import '../../widgets/common_app_bar.dart';

class AppLanguageOption {
  const AppLanguageOption({
    required this.code,
    required this.nativeLabel,
    required this.englishLabel,
  });

  final String code;
  final String nativeLabel;
  final String englishLabel;
}

/// Language picker grid matching design: line-style icons, native + English names.
class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  static const List<AppLanguageOption> _options = [
    AppLanguageOption(
      code: 'en',
      nativeLabel: 'English',
      englishLabel: 'English',
    ),
    AppLanguageOption(
      code: 'hi',
      nativeLabel: 'हिंदी',
      englishLabel: 'Hindi',
    ),
    AppLanguageOption(
      code: 'bn',
      nativeLabel: 'বাংলা',
      englishLabel: 'Bengali',
    ),
    AppLanguageOption(
      code: 'pa',
      nativeLabel: 'Punjabi',
      englishLabel: 'Punjabi',
    ),
    AppLanguageOption(
      code: 'te',
      nativeLabel: 'తెలుగు',
      englishLabel: 'Telugu',
    ),
    AppLanguageOption(
      code: 'or',
      nativeLabel: 'ଓଡ଼ିଆ',
      englishLabel: 'Odia',
    ),
    AppLanguageOption(
      code: 'mr',
      nativeLabel: 'मराठी',
      englishLabel: 'Marathi',
    ),
    AppLanguageOption(
      code: 'gu',
      nativeLabel: 'ગુજરાતી',
      englishLabel: 'Gujarati',
    ),
    AppLanguageOption(
      code: 'kn',
      nativeLabel: 'ಕನ್ನಡ',
      englishLabel: 'Kannada',
    ),
    AppLanguageOption(
      code: 'ur',
      nativeLabel: 'اردو',
      englishLabel: 'Urdu',
    ),
    AppLanguageOption(
      code: 'ml',
      nativeLabel: 'മലയാളം',
      englishLabel: 'Malayalam',
    ),
    AppLanguageOption(
      code: 'ta',
      nativeLabel: 'தமிழ்',
      englishLabel: 'Tamil',
    ),
    AppLanguageOption(
      code: 'as',
      nativeLabel: 'অসমীয়া',
      englishLabel: 'Assamese',
    ),
  ];

  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    final current = Get.locale?.languageCode ?? 'en';
    _selectedCode = AppTranslations.supportedLanguageCodes.contains(current)
        ? current
        : 'en';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = colorScheme.outlineVariant;
    final secondaryTextColor = colorScheme.onSurfaceVariant;
    final iconStroke = colorScheme.onSurface;
    final iconBg = colorScheme.surfaceContainerHighest;
    return Scaffold(
      backgroundColor: ThemeAdaptive.pageBackground(context),
      appBar: CommonAppBar(
        title: 'change_language_title'.tr,
        titleColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurface,
        frostedLeadingBackground: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
              ),
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final o = _options[index];
                final selected = o.code == _selectedCode;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedCode = o.code),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeAdaptive.cardShadow(context, lightAlpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                        border: Border.all(
                          color: selected
                              ? AppColors.accentOrange
                              : borderColor,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (selected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppColors.accentOrange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 48,
                                  child: Center(
                                    child: _LanguageLineIcon(
                                      code: o.code,
                                      iconColor: iconStroke,
                                      background: iconBg,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  o.nativeLabel,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  o.englishLabel,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: secondaryTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await Get.find<LocaleController>().setLanguage(
                      _selectedCode,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'update_language'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Line-style / symbolic icon per language to mirror the design reference.
class _LanguageLineIcon extends StatelessWidget {
  const _LanguageLineIcon({
    required this.code,
    required this.iconColor,
    required this.background,
  });

  final String code;
  final Color iconColor;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5),
      ),
      child: Center(child: _iconChild()),
    );
  }

  Widget _iconChild() {
    const s = 22.0;
    switch (code) {
      case 'en':
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 28,
              color: iconColor,
            ),
            Text(
              'EN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: iconColor,
                height: 1,
              ),
            ),
          ],
        );
      case 'hi':
        return Icon(
          Icons.landscape_outlined,
          size: 28,
          color: iconColor,
        );
      case 'bn':
        return Text(
          'ব',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: iconColor,
            height: 1,
          ),
        );
      case 'pa':
        return Icon(
          Icons.people_alt_outlined,
          size: 26,
          color: iconColor,
        );
      case 'te':
        return Icon(
          Icons.temple_buddhist_outlined,
          size: 26,
          color: iconColor,
        );
      case 'or':
        return Text(
          'ଓ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: iconColor,
            height: 1,
          ),
        );
      case 'mr':
        return Text(
          'म',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: iconColor,
            height: 1,
          ),
        );
      case 'gu':
        return Text(
          'ગ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: iconColor,
            height: 1,
          ),
        );
      case 'kn':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle_outlined,
              size: 18,
              color: iconColor,
            ),
            Text(
              'kr',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: iconColor,
                height: 1,
              ),
            ),
          ],
        );
      case 'ur':
        return Icon(
          Icons.mosque_outlined,
          size: 26,
          color: iconColor,
        );
      case 'ml':
        return Text(
          'മ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: iconColor,
            height: 1,
          ),
        );
      case 'ta':
        return Icon(
          Icons.temple_hindu_outlined,
          size: 26,
          color: iconColor,
        );
      case 'as':
        return Icon(
          Icons.spa_outlined,
          size: 26,
          color: iconColor,
        );
      default:
        return Icon(Icons.language, size: s, color: iconColor);
    }
  }
}
