import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/recent_notifications_models.dart';

class NotificationsController extends GetxController {
  NotificationsController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<RecentNotificationsApiResponse> fetchRecentNotifications({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await _networkManager.getDio().get(
        Endpoints.recentNotifications,
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return RecentNotificationsApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return RecentNotificationsApiResponse(
        success: false,
        message: 'Failed to load notifications.',
        data: <StudentNotificationItem>[],
        pagination: NotificationsPagination.empty(),
      );
    } on DioException catch (e) {
      return RecentNotificationsApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: <StudentNotificationItem>[],
        pagination: NotificationsPagination.empty(),
      );
    } catch (_) {
      return RecentNotificationsApiResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        data: <StudentNotificationItem>[],
        pagination: NotificationsPagination.empty(),
      );
    }
  }
}
