class Constants {
  /// BCP-47 language code only (e.g. en, hi, ta). Used with [Locale].
  static const String appLanguageCode = 'app_language_code';
  static const String appThemeMode = 'app_theme_mode';

  // Storage Keys
  static const String token = 'token';
  static const String refreshToken = 'refresh_token';
  static const String userNameSaved = 'user_name_saved';
  static const String loginStatus = 'login_status';

  /// Set when the post-login feature showcase has been finished or skipped.
  static const String featureGuideCompleted = 'feature_guide_v1_completed';

  /// Firebase Cloud Messaging device token (not the auth JWT).
  static const String fcmToken = 'fcm_token';

  // API Response Keys
  static const String success = 'success';
  static const String message = 'message';
  static const String data = 'data';

  // User Data Keys
  static const String userData = 'UserData';
  static const String sessionData = 'SessionData';

  // Error Messages
  static const String networkError =
      'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';

  // Validation Messages
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String usernameTooShort =
      'Username must be at least 3 characters';
}
