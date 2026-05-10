import 'package:dio/dio.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/leave_models.dart';

class LeaveController {
  LeaveController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<LeaveListResponse> fetchLeaveList({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
      };
      final response = await _networkManager.getDio().get(
        Endpoints.leaveList,
        queryParameters: qp,
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return LeaveListResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return LeaveListResponse.failure('Failed to load leave list.');
    } on DioException catch (e) {
      return LeaveListResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return LeaveListResponse.failure('Something went wrong. Please try again.');
    }
  }

  Future<LeaveTypesResponse> fetchLeaveTypes() async {
    try {
      final response = await _networkManager.getDio().get(Endpoints.leaveTypes);
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return LeaveTypesResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return LeaveTypesResponse.failure('Failed to load leave types.');
    } on DioException catch (e) {
      return LeaveTypesResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return LeaveTypesResponse.failure('Something went wrong. Please try again.');
    }
  }

  Future<LeaveDetailResponse> fetchLeaveDetail(int leaveId) async {
    try {
      final response = await _networkManager.getDio().get(
        Endpoints.leaveDetail(leaveId),
      );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return LeaveDetailResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return LeaveDetailResponse.failure('Failed to load leave details.');
    } on DioException catch (e) {
      return LeaveDetailResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return LeaveDetailResponse.failure(
        'Something went wrong while loading leave detail.',
      );
    }
  }

  Future<LeaveApplyResponse> applyLeave({
    required int leaveTypeId,
    required String fromDate,
    required String toDate,
    required String description,
    String? documentPath,
  }) async {
    try {
      final body = <String, dynamic>{
        'leave_type_id': leaveTypeId,
        'from_date': fromDate,
        'to_date': toDate,
        'description': description,
      };
      final form = FormData.fromMap({
        ...body,
        if (documentPath != null && documentPath.trim().isNotEmpty)
          'document': await MultipartFile.fromFile(documentPath.trim()),
      });

      final response = await _networkManager.getDio(isJsonType: false).post(
            Endpoints.leaveApply,
            data: form,
            options: Options(
              headers: const {'X-App-Version': '1.0.0'},
            ),
          );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return LeaveApplyResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }

      return LeaveApplyResponse.failure('Failed to submit leave application.');
    } on DioException catch (e) {
      return LeaveApplyResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return LeaveApplyResponse.failure(
        'Something went wrong while submitting leave.',
      );
    }
  }

  Future<LeaveActionResponse> deleteLeave(int leaveId) async {
    try {
      final response = await _networkManager.getDio().delete(
            Endpoints.leaveDetail(leaveId),
          );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return LeaveActionResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return LeaveActionResponse.failure('Could not delete leave.');
    } on DioException catch (e) {
      return LeaveActionResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return LeaveActionResponse.failure(
        'Something went wrong while deleting leave.',
      );
    }
  }
}
