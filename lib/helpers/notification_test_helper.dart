// Firebase imports commented out - not using Firebase for now
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class for testing notifications during development
class NotificationTestHelper {
  static final NotificationTestHelper _instance =
      NotificationTestHelper._internal();
  factory NotificationTestHelper() => _instance;
  NotificationTestHelper._internal();

  static NotificationTestHelper get instance => _instance;

  /// Test notification with custom data (simplified without Firebase)
  Future<void> testNotification({
    required String title,
    required String body,
    String? screen,
    String? type,
    String? id,
  }) async {
    try {
      // Firebase RemoteMessage commented out - using simple notification instead
      // final mockMessage = RemoteMessage(
      //   notification: RemoteNotification(title: title, body: body),
      //   data: {
      //     if (screen != null) 'screen': screen,
      //     if (type != null) 'type': type,
      //     if (id != null) 'id': id,
      //   },
      //   messageId: 'test_${DateTime.now().millisecondsSinceEpoch}',
      // );

      // Show simple snackbar notification instead
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      Get.snackbar(
        'Test Notification',
        'Notification sent successfully (Firebase disabled)',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Test Error',
        'Failed to send test notification: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Test different notification types
  Future<void> testAllNotificationTypes() async {
    // Test announcement
    await testNotification(
      title: 'Announcement Test',
      body: 'This is a test announcement notification',
      screen: 'notice_board',
      type: 'announcement',
    );

    // Wait a bit
    await Future.delayed(const Duration(seconds: 2));

    // Test message
    await testNotification(
      title: 'Message Test',
      body: 'This is a test message notification',
      screen: 'messages',
      type: 'message',
    );

    // Wait a bit
    await Future.delayed(const Duration(seconds: 2));

    // Test alert
    await testNotification(
      title: 'Alert Test',
      body: 'This is a test alert notification',
      screen: 'dashboard',
      type: 'alert',
    );
  }

  /// Test navigation notifications
  Future<void> testNavigationNotifications() async {
    final screens = [
      {
        'screen': 'dashboard',
        'title': 'Dashboard',
        'body': 'Navigate to dashboard',
      },
      {
        'screen': 'notifications',
        'title': 'Notifications',
        'body': 'Navigate to notifications',
      },
      {
        'screen': 'messages',
        'title': 'Messages',
        'body': 'Navigate to messages',
      },
      {
        'screen': 'notice_board',
        'title': 'Notice Board',
        'body': 'Navigate to notice board',
      },
      {
        'screen': 'student_detail',
        'title': 'Student Detail',
        'body': 'Navigate to student detail',
        'id': '123',
      },
      {
        'screen': 'staff_detail',
        'title': 'Staff Detail',
        'body': 'Navigate to staff detail',
        'id': '456',
      },
    ];

    for (int i = 0; i < screens.length; i++) {
      final screen = screens[i];
      await testNotification(
        title: screen['title']!,
        body: screen['body']!,
        screen: screen['screen']!,
        type: 'test',
        id: screen['id'],
      );

      // Wait between notifications
      if (i < screens.length - 1) {
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  /// Get current FCM token for testing
  Future<String?> getCurrentToken() async {
    // try {
    //   return await NotificationService.instance.getCurrentToken();
    // } catch (e) {
    //   Get.snackbar(
    //     'Token Error',
    //     'Failed to get FCM token: $e',
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return null;
    // }
  }

  /// Refresh FCM token
  Future<String?> refreshToken() async {
    // try {
    //   return await NotificationService.instance.refreshToken();
    // } catch (e) {
    //   Get.snackbar(
    //     'Token Error',
    //     'Failed to refresh FCM token: $e',
    //     snackPosition: SnackPosition.TOP,
    //     backgroundColor: Colors.red,
    //     colorText: Colors.white,
    //   );
    //   return null;
    // }
  }

  /// Clear all notifications
  Future<void> clearNotifications() async {
    try {
      // await NotificationService.instance.clearAllNotifications();
      // Get.snackbar(
      //   'Success',
      //   'All notifications cleared',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.green,
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 2),
      // );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to clear notifications: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Firebase topic methods commented out - not using Firebase for now
  // /// Subscribe to test topic
  // Future<void> subscribeToTestTopic() async {
  //   try {
  //     await NotificationService.instance.subscribeToTopic('test_topic');
  //     Get.snackbar(
  //       'Success',
  //       'Subscribed to test_topic',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.green,
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 2),
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to subscribe to topic: $e',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }

  // /// Unsubscribe from test topic
  // Future<void> unsubscribeFromTestTopic() async {
  //   try {
  //     await NotificationService.instance.unsubscribeFromTopic('test_topic');
  //     Get.snackbar(
  //       'Success',
  //       'Unsubscribed from test_topic',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.green,
  //       colorText: Colors.white,
  //       duration: const Duration(seconds: 2),
  //     );
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Failed to unsubscribe from topic: $e',
  //       snackPosition: SnackPosition.TOP,
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }
}
