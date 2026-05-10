import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/string_constants.dart';
import '../firebase_options.dart';
import '../routes/app_routes.dart';
import '../services/crashlytics_service.dart';
import '../services/navigation_service.dart';

/// Registers background processing **before** `runApp`.
///
/// Must be a top-level function; keep logic minimal (separate isolate).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.displayRemoteMessageAsLocal(message);
}

/// Push + local notifications for Android / iOS.
///
/// Call [initialize] after [Firebase.initializeApp] and [GetStorage.init].
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static const String defaultChannelId = 'xscholar_general';
  static const String defaultChannelName = 'General';
  static const String defaultChannelDescription =
      'School updates, notices, and messages';

  static const String announcementChannelId = 'xscholar_announcements';
  static const String messageChannelId = 'xscholar_messages';
  static const String alertChannelId = 'xscholar_alerts';

  bool _initialized = false;

  /// Same artwork as splash (`assets/images/big_logo.png`): Android uses
  /// `@drawable/notification_large_icon`; iOS uses a temp copy for attachments.
  static String? _cachedIosLogoPath;

  static Future<NotificationDetails> _platformNotificationDetails({
    required String channelId,
  }) async {
    final iosLogoPath = await _resolveIosNotificationLogoPath();

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelNameForId(channelId),
        channelDescription: _channelDescriptionForId(channelId),
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap(
          '@drawable/notification_large_icon',
        ),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        attachments: iosLogoPath != null
            ? [DarwinNotificationAttachment(iosLogoPath)]
            : null,
      ),
    );
  }

  /// Writes the bundled splash logo to a temp file for UNNotificationAttachment.
  static Future<String?> _resolveIosNotificationLogoPath() async {
    if (!Platform.isIOS) return null;
    final cached = _cachedIosLogoPath;
    if (cached != null) {
      try {
        if (await File(cached).exists()) return cached;
      } catch (_) {}
    }
    try {
      final data = await rootBundle.load('assets/images/big_logo.png');
      final file = File(
        '${Directory.systemTemp.path}/xscholar_notification_logo.png',
      );
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      _cachedIosLogoPath = file.path;
      return file.path;
    } catch (_) {
      return null;
    }
  }

  /// Shows a system notification from FCM content (foreground + data-only background).
  static Future<void> displayRemoteMessageAsLocal(RemoteMessage message) async {
    final plugin = FlutterLocalNotificationsPlugin();
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(settings: init);

    if (Platform.isAndroid) {
      await _createChannelsOn(plugin);
    }

    final (title, body) = _resolveTitleBody(message);
    if (title.isEmpty && body.isEmpty) return;

    final channelId = _channelIdForData(message.data);
    final details = await _platformNotificationDetails(channelId: channelId);

    final rawId = message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    final id = rawId.abs() % 2147483647;

    final payload = message.data.isNotEmpty ? jsonEncode(message.data) : null;

    await plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  static Future<void> _createChannelsOn(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    Future<void> add(AndroidNotificationChannel c) =>
        android.createNotificationChannel(c);

    await add(
      const AndroidNotificationChannel(
        defaultChannelId,
        defaultChannelName,
        description: defaultChannelDescription,
        importance: Importance.high,
      ),
    );
    await add(
      const AndroidNotificationChannel(
        announcementChannelId,
        'Announcements',
        description: 'Notices and announcements',
        importance: Importance.high,
      ),
    );
    await add(
      const AndroidNotificationChannel(
        messageChannelId,
        'Messages',
        description: 'Messages from school',
        importance: Importance.high,
      ),
    );
    await add(
      const AndroidNotificationChannel(
        alertChannelId,
        'Alerts',
        description: 'Important alerts',
        importance: Importance.high,
      ),
    );
  }

  static (String, String) _resolveTitleBody(RemoteMessage message) {
    final n = message.notification;
    String title = (n?.title ?? message.data['title'] ?? '').trim();
    String body = (n?.body ?? message.data['body'] ?? '').trim();
    if (title.isEmpty && body.isEmpty && message.data.containsKey('message')) {
      body = '${message.data['message']}'.trim();
    }
    return (title.isEmpty ? 'XScholar' : title, body);
  }

  static String _channelIdForData(Map<String, dynamic> data) {
    final type = '${data['type'] ?? data['category'] ?? ''}'.toLowerCase();
    switch (type) {
      case 'announcement':
      case 'notice':
        return announcementChannelId;
      case 'message':
      case 'sms':
        return messageChannelId;
      case 'alert':
      case 'warning':
        return alertChannelId;
      default:
        return defaultChannelId;
    }
  }

  static String _channelNameForId(String id) {
    switch (id) {
      case announcementChannelId:
        return 'Announcements';
      case messageChannelId:
        return 'Messages';
      case alertChannelId:
        return 'Alerts';
      default:
        return defaultChannelName;
    }
  }

  static String _channelDescriptionForId(String id) {
    switch (id) {
      case announcementChannelId:
        return 'Notices and announcements';
      case messageChannelId:
        return 'Messages from school';
      case alertChannelId:
        return 'Important alerts';
      default:
        return defaultChannelDescription;
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      await CrashlyticsService.log('NotificationService: skipped on web');
      _initialized = true;
      return;
    }

    if (Firebase.apps.isEmpty) {
      await CrashlyticsService.log('NotificationService: Firebase not initialized');
      _initialized = true;
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      await CrashlyticsService.log('NotificationService: mobile platforms only');
      _initialized = true;
      return;
    }

    try {
      await _initLocalPlugin();
      if (Platform.isAndroid) {
        await _createChannelsOn(_localNotifications);
        await Permission.notification.request();
      }
      if (Platform.isIOS) {
        await _resolveIosNotificationLogoPath();
      }

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (Platform.isIOS) {
        await _messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
      }

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpened);
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      final token = await _messaging.getToken();
      await _persistToken(token);

      await _handleInitialMessage();

      _initialized = true;
      await CrashlyticsService.log('NotificationService initialized');
    } catch (e, st) {
      await CrashlyticsService.recordError(e, st);
    }
  }

  Future<void> _initLocalPlugin() async {
    const init = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: init,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    await CrashlyticsService.log(
      'FCM foreground: ${message.messageId ?? 'no-id'}',
    );

    await displayRemoteMessageAsLocal(message);

    final loggedIn = GetStorage().read(Constants.loginStatus) == true;
    if (!loggedIn) return;

    final (_, body) = _resolveTitleBody(message);
    if (body.isEmpty) return;

    // Avoid Get.snackbar here: FCM can fire before/with no valid GetX overlay.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = NavigationService.navigatorKey.currentContext;
      if (ctx == null || !ctx.mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      messenger?.showSnackBar(
        SnackBar(
          content: Text(body),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _onNotificationOpened(RemoteMessage message) {
    _routeFromPayload(message.data);
  }

  Future<void> _handleInitialMessage() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _routeFromPayload(initial.data);
    }
  }

  void _onLocalNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _routeFromPayload(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
  }

  void _routeFromPayload(Map<String, dynamic> data) {
    final screen = '${data['screen'] ?? ''}'.trim();
    if (screen.isEmpty) return;

    void go() {
      switch (screen) {
        case 'dashboard':
        case 'home':
          NavigationService.navigateToAndRemoveUntil(AppRoutes.dashboard);
          break;
        case 'login':
          NavigationService.navigateToLogin();
          break;
        case 'select_student':
          NavigationService.navigateToAndRemoveUntil(AppRoutes.selectStudent);
          break;
        case 'welcome':
          NavigationService.navigateToAndRemoveUntil(AppRoutes.welcome);
          break;
        default:
          break;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => go());
  }

  void _onTokenRefresh(String token) {
    _persistToken(token);
  }

  Future<void> _persistToken(String? token) async {
    if (token == null || token.isEmpty) return;
    try {
      await GetStorage().write(Constants.fcmToken, token);
      await CrashlyticsService.log('FCM token updated');
    } catch (e, st) {
      await CrashlyticsService.recordError(e, st);
    }
  }

  /// Last token from FCM (also in storage under [Constants.fcmToken]).
  Future<String?> getFcmToken() async {
    try {
      final cached = GetStorage().read<String>(Constants.fcmToken);
      if (cached != null && cached.isNotEmpty) return cached;
      final token = await _messaging.getToken();
      await _persistToken(token);
      return token;
    } catch (e, st) {
      await CrashlyticsService.recordError(e, st);
      return null;
    }
  }

  /// Manual local notification (tests / scheduled use later).
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = defaultChannelId,
  }) async {
    if (kIsWeb) return;

    final details = await _platformNotificationDetails(channelId: channelId);

    final id = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }
}
