import 'package:dio/dio.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/outpass_models.dart';

class OutpassController {
  OutpassController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<OutpassListResponse> fetchOutpassList({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor.trim(),
      };

      final response = await _networkManager.getDio().get(
            Endpoints.outpassList,
            queryParameters: qp,
          );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return OutpassListResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return OutpassListResponse.failure('Failed to load outpass list.');
    } on DioException catch (e) {
      return OutpassListResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return OutpassListResponse.failure(
        'Something went wrong while loading outpass list.',
      );
    }
  }

  Future<OutpassDetailResponse> fetchOutpassDetail(int outpassId) async {
    try {
      final response = await _networkManager.getDio().get(
            Endpoints.outpassDetail(outpassId),
          );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return OutpassDetailResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return OutpassDetailResponse.failure('Failed to load outpass details.');
    } on DioException catch (e) {
      return OutpassDetailResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return OutpassDetailResponse.failure(
        'Something went wrong while loading outpass details.',
      );
    }
  }

  Future<OutpassReasonsResponse> fetchReasons() async {
    try {
      final response = await _networkManager.getDio().get(Endpoints.outpassReasons);
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return OutpassReasonsResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return OutpassReasonsResponse.failure('Failed to load outpass reasons.');
    } on DioException catch (e) {
      return OutpassReasonsResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return OutpassReasonsResponse.failure(
        'Something went wrong while loading outpass reasons.',
      );
    }
  }

  Future<OutpassActionResponse> applyOutpass({
    required String outDateTime,
    int? reasonId,
    required String contactNo,
    required String relation,
    required String visitors,
    required String description,
    required String address,
    String? documentPath,
  }) async {
    try {
      final form = FormData.fromMap({
        'out_date_time': outDateTime,
        'reason_id': reasonId?.toString() ?? '',
        'contact_no': contactNo,
        'relation': relation,
        'visitors': visitors,
        'description': description,
        'address': address,
        if (documentPath != null && documentPath.trim().isNotEmpty)
          'document': await MultipartFile.fromFile(documentPath.trim()),
      });

      final response = await _networkManager.getDio(isJsonType: false).post(
            Endpoints.outpassApply,
            data: form,
            options: Options(headers: const {'X-App-Version': '1.0.0'}),
          );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return OutpassActionResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return OutpassActionResponse.failure('Could not apply outpass.');
    } on DioException catch (e) {
      return OutpassActionResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return OutpassActionResponse.failure(
        'Something went wrong while applying outpass.',
      );
    }
  }

  Future<OutpassActionResponse> cancelOutpass(int outpassId) async {
    try {
      final response = await _networkManager.getDio().delete(
            Endpoints.outpassDetail(outpassId),
          );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return OutpassActionResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return OutpassActionResponse.failure('Could not cancel outpass.');
    } on DioException catch (e) {
      return OutpassActionResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return OutpassActionResponse.failure(
        'Something went wrong while cancelling outpass.',
      );
    }
  }
}
