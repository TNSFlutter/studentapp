import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/exam_result_models.dart';

class ExamResultController extends GetxController {
  ExamResultController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<ExamResultsApiResponse> fetchExamResults({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor,
      };

      final response = await _networkManager.getDio().get(
        Endpoints.examResults,
        queryParameters: qp,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return ExamResultsApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return ExamResultsApiResponse(
        success: false,
        message: 'Failed to load exam results.',
        data: null,
        pagination: ExamResultsPagination.empty(),
      );
    } on DioException catch (e) {
      return ExamResultsApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: null,
        pagination: ExamResultsPagination.empty(),
      );
    } catch (_) {
      return ExamResultsApiResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        data: null,
        pagination: ExamResultsPagination.empty(),
      );
    }
  }
}
