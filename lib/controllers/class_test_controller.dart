import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/class_test_models.dart';

class ClassTestController extends GetxController {
  ClassTestController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<ClassTestResultsResponse> fetchClassTests({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor,
      };

      final response = await _networkManager.getDio().get(
        Endpoints.classTestResults,
        queryParameters: qp,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return ClassTestResultsResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return ClassTestResultsResponse(
        success: false,
        message: 'Failed to load class tests.',
        data: null,
        pagination: ClassTestPagination.empty(),
      );
    } on DioException catch (e) {
      return ClassTestResultsResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: null,
        pagination: ClassTestPagination.empty(),
      );
    } catch (_) {
      return ClassTestResultsResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        data: null,
        pagination: ClassTestPagination.empty(),
      );
    }
  }
}
