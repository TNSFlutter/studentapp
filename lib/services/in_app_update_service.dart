import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

/// Google Play in-app updates using the **immediate** flow only (full-screen).
///
/// Listing (must match [applicationId]):  
/// https://play.google.com/store/apps/details?id=com.levnext.myschool
///
/// Flexible updates are intentionally not used. If Play reports an update but
/// disallows immediate mode (e.g. policy/network), the app continues normally.
class InAppUpdateService {
  InAppUpdateService._();

  /// Runs only on Android; no-op on iOS, web, desktop.
  static Future<void> tryImmediateUpdateIfNeeded() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        await _performImmediateAndLog();
        return;
      }

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      if (!info.immediateUpdateAllowed) {
        if (kDebugMode) {
          debugPrint(
            'InAppUpdate: update available but immediate update not allowed '
            '(preconditions: ${info.immediateAllowedPreconditions})',
          );
        }
        return;
      }

      await _performImmediateAndLog();
    } on Object catch (e, st) {
      // sideloaded/debug builds, Play Store missing, etc.
      if (kDebugMode) {
        debugPrint('InAppUpdate: skipped or failed: $e\n$st');
      }
    }
  }

  static Future<void> _performImmediateAndLog() async {
    final result = await InAppUpdate.performImmediateUpdate();
    if (kDebugMode) {
      debugPrint('InAppUpdate: performImmediateUpdate -> $result');
    }
  }
}
