// Firebase Crashlytics commented out - not using Firebase for now
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  // static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Record a non-fatal error
  static Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) async {
    // Firebase Crashlytics commented out
    // await _crashlytics.recordError(error, stackTrace, fatal: fatal);
    print('Error (Crashlytics disabled): $error');
  }

  /// Log a custom message
  static Future<void> log(String message) async {
    // Firebase Crashlytics commented out
    // await _crashlytics.log(message);
    print('Log (Crashlytics disabled): $message');
  }

  /// Set user identifier
  static Future<void> setUserIdentifier(String userId) async {
    // Firebase Crashlytics commented out
    // await _crashlytics.setUserIdentifier(userId);
    print('User ID (Crashlytics disabled): $userId');
  }

  /// Set custom key-value pair
  static Future<void> setCustomKey(String key, dynamic value) async {
    // Firebase Crashlytics commented out
    // await _crashlytics.setCustomKey(key, value);
    print('Custom Key (Crashlytics disabled): $key = $value');
  }

  /// Check if Crashlytics is enabled
  static bool get isCrashlyticsCollectionEnabled {
    // Firebase Crashlytics commented out
    // return _crashlytics.isCrashlyticsCollectionEnabled;
    return false;
  }

  /// Enable/disable Crashlytics collection
  static Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    // Firebase Crashlytics commented out
    // await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
    print('Crashlytics collection (disabled): $enabled');
  }
}
