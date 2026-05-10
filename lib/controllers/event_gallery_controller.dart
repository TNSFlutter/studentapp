import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/event_gallery_models.dart';

class EventGalleryController extends GetxController {
  EventGalleryController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<EventGalleryApiResponse> fetchEvents({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
      };

      final response = await _networkManager.getDio().get(
        Endpoints.eventGallery,
        queryParameters: qp,
      );

      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return EventGalleryApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return EventGalleryApiResponse.failure('Failed to load event gallery.');
    } on DioException catch (e) {
      return EventGalleryApiResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return EventGalleryApiResponse.failure(
        'Something went wrong. Please try again.',
      );
    }
  }
}
