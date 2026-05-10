import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helpers/app_feature_guide.dart';
import '../helpers/feature_guide_showcase_ui.dart';

/// Bottom bar: Home, Homework, Fees, Messages, Menu.
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// When non-null, wraps the bar with a [Showcase] for the feature tour.
  final AppFeatureGuideKeys? featureGuideKeys;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.featureGuideKeys,
  });

  static const Color _accent = Color(0xFFFF7A21);
  static const Color _muted = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navTheme = theme.bottomNavigationBarTheme;
    final scheme = theme.colorScheme;
    Widget bar = Material(
      elevation: 8,
      color: navTheme.backgroundColor ?? scheme.surface,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: scheme.outlineVariant)),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: navTheme.backgroundColor ?? scheme.surface,
            elevation: 0,
            selectedItemColor: navTheme.selectedItemColor ?? _accent,
            unselectedItemColor: navTheme.unselectedItemColor ?? _muted,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle:
                navTheme.selectedLabelStyle ??
                const TextStyle(fontWeight: FontWeight.w600),
            unselectedLabelStyle: navTheme.unselectedLabelStyle,
            showUnselectedLabels: true,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'nav_home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.description_outlined),
                activeIcon: Icon(Icons.description_rounded),
                label: 'nav_homework'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.currency_rupee_outlined),
                activeIcon: Icon(Icons.currency_rupee_rounded),
                label: 'nav_fees'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'nav_messages'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu_outlined),
                activeIcon: Icon(Icons.menu_rounded),
                label: 'nav_menu'.tr,
              ),
            ],
          ),
        ),
      ),
    );

    final g = featureGuideKeys;
    if (g != null) {
      bar = FeatureGuideShowcaseUi.dashboardShowcase(
        context: context,
        showcaseKey: g.bottomNavigation,
        title: 'guide_bottom_nav_title'.tr,
        description: 'guide_bottom_nav_desc'.tr,
        child: bar,
      );
    }

    return bar;
  }
}
