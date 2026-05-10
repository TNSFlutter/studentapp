import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/attendance_models.dart';

class AttendanceController extends GetxController {
  AttendanceController({NetworkManager? networkManager})
    : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  /// `GET student/attendance?month=&year=&limit=` — optional `cursor` for pagination.
  Future<AttendanceApiResponse> fetchStudentAttendance({
    required int month,
    required int year,
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final dio = _networkManager.getDio();
      final monthText = month.toString().padLeft(2, '0');
      final req = <String, dynamic>{
        'month': monthText,
        'year': '$year',
        'limit': '$limit',
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
      };
      final appPlatform = switch (defaultTargetPlatform) {
        TargetPlatform.android => 'android',
        TargetPlatform.iOS => 'ios',
        TargetPlatform.macOS => 'macos',
        TargetPlatform.windows => 'windows',
        TargetPlatform.linux => 'linux',
        TargetPlatform.fuchsia => 'fuchsia',
      };
      final response = await dio.request(
        Endpoints.studentAttendance,
        options: Options(
          method: 'GET',
          headers: {
            'X-App-Platform': appPlatform,
            'X-App-Version': '1.0.0',
          },
        ),
        queryParameters: req,
        // Compatibility fallback: some backends incorrectly read GET body only.
        data: req,
      );

      if (response.statusCode != 200 || response.data == null) {
        return AttendanceApiResponse(
          success: false,
          message: 'Failed to load attendance.',
          data: null,
          pagination: AttendancePagination.empty(),
        );
      }

      final body = response.data;
      if (body is! Map) {
        return AttendanceApiResponse(
          success: false,
          message: 'Invalid response from server.',
          data: null,
          pagination: AttendancePagination.empty(),
        );
      }

      return AttendanceApiResponse.fromJson(Map<String, dynamic>.from(body));
    } on DioException catch (e) {
      return AttendanceApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: null,
        pagination: AttendancePagination.empty(),
      );
    } catch (e) {
      return AttendanceApiResponse(
        success: false,
        message: e.toString(),
        data: null,
        pagination: AttendancePagination.empty(),
      );
    }
  }
}
