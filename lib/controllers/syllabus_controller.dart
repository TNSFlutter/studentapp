import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/syllabus_models.dart';

class SyllabusController extends GetxController {
  SyllabusController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<SyllabusApiResponse> fetchSyllabus({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor,
      };

      final response = await _networkManager.getDio().get(
        Endpoints.syllabus,
        queryParameters: qp,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return SyllabusApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return SyllabusApiResponse(
        success: false,
        message: 'Failed to load syllabus.',
        data: <SyllabusItem>[],
        pagination: SyllabusPagination.empty(),
      );
    } on DioException catch (e) {
      return SyllabusApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: <SyllabusItem>[],
        pagination: SyllabusPagination.empty(),
      );
    } catch (_) {
      return SyllabusApiResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        data: <SyllabusItem>[],
        pagination: SyllabusPagination.empty(),
      );
    }
  }
}
