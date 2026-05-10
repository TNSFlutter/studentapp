import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

import '../models/login_models.dart';
import 'notification_service.dart';

class DeviceInfoHelper {
  static final DeviceInfoHelper _instance = DeviceInfoHelper._internal();
  factory DeviceInfoHelper() => _instance;
  DeviceInfoHelper._internal();

  static DeviceInfoHelper get instance => _instance;

  // Cache for device info to avoid repeated heavy operations
  DeviceInfo? _cachedDeviceInfo;
  final GetStorage _storage = GetStorage();

  Future<DeviceInfo> getDeviceInfo() async {
    // Return cached device info if available
    if (_cachedDeviceInfo != null) {
      return _cachedDeviceInfo!;
    }

    // Try to load from storage first
    final storedDeviceInfo = _loadDeviceInfoFromStorage();
    if (storedDeviceInfo != null) {
      _cachedDeviceInfo = storedDeviceInfo;
      return _cachedDeviceInfo!;
    }

    // Generate new device info
    _cachedDeviceInfo = await _generateDeviceInfo();

    // Cache in storage for future use
    _saveDeviceInfoToStorage(_cachedDeviceInfo!);

    return _cachedDeviceInfo!;
  }

  /// Load device info from storage
  DeviceInfo? _loadDeviceInfoFromStorage() {
    try {
      final deviceData = _storage.read('cached_device_info');
      if (deviceData != null) {
        return DeviceInfo.fromJson(deviceData);
      }
    } catch (e) {
      print('Error loading device info from storage: $e');
    }
    return null;
  }

  /// Save device info to storage
  void _saveDeviceInfoToStorage(DeviceInfo deviceInfo) {
    try {
      _storage.write('cached_device_info', deviceInfo.toJson());
    } catch (e) {
      print('Error saving device info to storage: $e');
    }
  }

  /// Generate device info with fallback values
  Future<DeviceInfo> _generateDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    String deviceName = '';
    String deviceModel = '';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.brand;
        deviceModel = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
      }
    } catch (e) {
      // Fallback values if device info fails
      deviceId = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
      deviceName = kIsWeb ? 'Web' : Platform.operatingSystem;
      deviceModel = 'Unknown Model';
    }

    // Get FCM token from notification service
    String deviceToken = await _getDeviceToken();

    return DeviceInfo(
      deviceId: deviceId,
      deviceType: kIsWeb
          ? 'web'
          : Platform.isAndroid
          ? 'android'
          : 'ios',
      deviceName: deviceName,
      deviceModel: deviceModel,
      deviceToken: deviceToken,
    );
  }

  Future<String> _getDeviceToken() async {
    try {
      final token = await NotificationService.instance.getFcmToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (_) {}
    return 'device_token_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> updateDeviceToken() async {
    try {
      // await NotificationService.instance.refreshToken();
      // Clear cache to force refresh
      _cachedDeviceInfo = null;
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear cached device info (useful for testing or when device info changes)
  void clearCache() {
    _cachedDeviceInfo = null;
    _storage.remove('cached_device_info');
  }
}
