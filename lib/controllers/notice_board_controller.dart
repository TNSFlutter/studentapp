import 'package:dio/dio.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/notice_board_models.dart';

class NoticeBoardController {
  NoticeBoardController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<NoticeBoardApiResponse> fetchNotices({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
      };

      final response = await _networkManager.getDio().get(
        Endpoints.notice,
        queryParameters: qp,
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data != null) {
        final body = response.data;
        if (body is Map) {
          return NoticeBoardApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return NoticeBoardApiResponse.failure('Failed to load notices.');
    } on DioException catch (e) {
      return NoticeBoardApiResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return NoticeBoardApiResponse.failure(
        'Something went wrong. Please try again.',
      );
    }
  }
}
