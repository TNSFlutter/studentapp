import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/timetable_models.dart';

class TimetableController extends GetxController {
  TimetableController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<TimetableResponse> fetchTimetable({
    required String yyyyMmDd,
    int limit = 10,
  }) async {
    try {
      final path = Endpoints.timetableByDate(yyyyMmDd);
      final response = await _networkManager.getDio().get(
        path,
        queryParameters: <String, dynamic>{'limit': limit},
      );

      if (response.statusCode == 200 && response.data is Map) {
        return TimetableResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      return TimetableResponse(
        success: false,
        message: 'Unexpected response',
        data: null,
        pagination: TimetablePagination.empty(),
      );
    } on DioException catch (e) {
      return TimetableResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e, 'Network error'),
        data: null,
        pagination: TimetablePagination.empty(),
      );
    } catch (_) {
      return TimetableResponse(
        success: false,
        message: 'Something went wrong.',
        data: null,
        pagination: TimetablePagination.empty(),
      );
    }
  }
}
