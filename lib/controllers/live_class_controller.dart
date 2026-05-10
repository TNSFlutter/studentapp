import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/live_class_models.dart';

class LiveClassController extends GetxController {
  LiveClassController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<LiveClassApiResponse> fetchLiveClasses({
    required String yyyyMmDd,
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
      };

      final response = await _networkManager.getDio().get(
        Endpoints.liveClassByDate(yyyyMmDd),
        queryParameters: qp,
      );

      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300 && response.data is Map) {
        return LiveClassApiResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      return LiveClassApiResponse.failure('Failed to load live classes.');
    } on DioException catch (e) {
      return LiveClassApiResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return LiveClassApiResponse.failure(
        'Something went wrong. Please try again.',
      );
    }
  }
}
