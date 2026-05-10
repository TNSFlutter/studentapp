import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/string_constants.dart';

/// GlobalKeys for [Showcase] targets; owned by [DashboardScreen] for stable identity.
final class AppFeatureGuideKeys {
  AppFeatureGuideKeys()
      : studentCard = GlobalKey(),
        payNowButton = GlobalKey(),
        quickActionKeys = List<GlobalKey>.generate(
          AppFeatureGuide.quickActionTileCount,
          (_) => GlobalKey(),
        ),
        recentNotifications = GlobalKey(),
        bottomNavigation = GlobalKey();

  final GlobalKey studentCard;

  /// Pending-fee card “Pay now” CTA (only mounted when there is an amount due).
  final GlobalKey payNowButton;

  /// One key per quick-action tile on the home grid (same order as dashboard tiles).
  final List<GlobalKey> quickActionKeys;

  final GlobalKey recentNotifications;
  final GlobalKey bottomNavigation;
}

/// Persists whether the first-time dashboard feature tour already ran.
abstract final class AppFeatureGuide {
  /// Must match the number of quick-action tiles built on the home dashboard grid.
  static const int quickActionTileCount = 15;

  /// Must match showcaseview's internal default scope (`Constants.defaultScope`).
  static const String dashboardShowcaseScope = '_showcaseDefaultScope';

  /// [ShowcaseView] scope for the pre-dashboard “tap a student card” tour.
  static const String selectStudentTourScope = '_selectStudentTour';

  /// When non-null (e.g. widget tests without [GetStorage.init]), skips disk reads.
  static bool? debugCompletionOverride;

  static bool get isCompleted {
    final o = debugCompletionOverride;
    if (o != null) return o;
    return GetStorage('app_prefs').read(Constants.featureGuideCompleted) == true;
  }

  static void markCompleted() {
    GetStorage('app_prefs').write(Constants.featureGuideCompleted, true);
  }

  /// Clears completion so the tour can run again (e.g. from settings).
  static void reset() {
    debugCompletionOverride = null;
    GetStorage('app_prefs').remove(Constants.featureGuideCompleted);
  }
}
