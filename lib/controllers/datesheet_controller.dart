import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/datesheet_models.dart';

class DatesheetController extends GetxController {
  DatesheetController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<DatesheetsApiResponse> fetchDatesheets({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor,
      };

      final response = await _networkManager.getDio().get(
        Endpoints.datesheets,
        queryParameters: qp,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return DatesheetsApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return DatesheetsApiResponse(
        success: false,
        message: 'Failed to load datesheets.',
        examTypes: <DatesheetExamType>[],
        nextExam: null,
        pagination: DatesheetPagination.empty(),
      );
    } on DioException catch (e) {
      return DatesheetsApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        examTypes: <DatesheetExamType>[],
        nextExam: null,
        pagination: DatesheetPagination.empty(),
      );
    } catch (_) {
      return DatesheetsApiResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        examTypes: <DatesheetExamType>[],
        nextExam: null,
        pagination: DatesheetPagination.empty(),
      );
    }
  }
}
