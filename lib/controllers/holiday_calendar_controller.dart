import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/calendar_models.dart';

class HolidayCalendarController extends GetxController {
  HolidayCalendarController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<CalendarHolidaysResponse> fetchHolidays({
    required int month,
    required int year,
    int limit = 100,
  }) async {
    try {
      final response = await _networkManager.getDio().get(
        Endpoints.calenderHolidays,
        queryParameters: <String, dynamic>{
          'month': month,
          'year': year,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        return CalendarHolidaysResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      return CalendarHolidaysResponse(
        success: false,
        message: 'Unexpected response',
        data: null,
        pagination: CalendarPagination.empty(),
      );
    } on DioException catch (e) {
      return CalendarHolidaysResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e, 'Network error'),
        data: null,
        pagination: CalendarPagination.empty(),
      );
    } catch (_) {
      return CalendarHolidaysResponse(
        success: false,
        message: 'Something went wrong.',
        data: null,
        pagination: CalendarPagination.empty(),
      );
    }
  }
}
