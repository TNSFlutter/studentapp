import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../models/fee_payment_models.dart';
import '../models/fee_payment_gateway_models.dart';
import '../models/fee_structure_models.dart';
import '../models/pending_fee_models.dart';
import '../services/fee_payment_config_store.dart';

class FeeController extends GetxController {
  FeeController({NetworkManager? networkManager})
      : _networkManager = networkManager ?? NetworkManager.instance;

  final NetworkManager _networkManager;

  Future<FeeStructureApiResponse> fetchFeeStructure() async {
    try {
      final response = await _networkManager.getDio().get(
        Endpoints.feeFeeStructure,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return FeeStructureApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return FeeStructureApiResponse(
        success: false,
        message: 'Failed to load fee structure.',
        data: null,
      );
    } on DioException catch (e) {
      return FeeStructureApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: null,
      );
    } catch (_) {
      return FeeStructureApiResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        data: null,
      );
    }
  }

  Future<FeePeriodDetailApiResponse> fetchFeePeriodDetail(int feePeriodId) async {
    try {
      final response = await _networkManager.getDio().get(
        Endpoints.feeDetails(feePeriodId),
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return FeePeriodDetailApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return FeePeriodDetailApiResponse(
        success: false,
        message: 'Failed to load fee details.',
        data: null,
      );
    } on DioException catch (e) {
      return FeePeriodDetailApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: null,
      );
    } catch (_) {
      return FeePeriodDetailApiResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        data: null,
      );
    }
  }

  Future<FeePaymentHistoryApiResponse> fetchPaymentHistory({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await _networkManager.getDio().get(
        Endpoints.feePaymentHistory,
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return FeePaymentHistoryApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return FeePaymentHistoryApiResponse(
        success: false,
        message: 'Failed to load payment history.',
        data: <FeePaymentHistoryItem>[],
        pagination: FeePaymentHistoryPagination.empty(),
      );
    } on DioException catch (e) {
      return FeePaymentHistoryApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: <FeePaymentHistoryItem>[],
        pagination: FeePaymentHistoryPagination.empty(),
      );
    } catch (_) {
      return FeePaymentHistoryApiResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        data: <FeePaymentHistoryItem>[],
        pagination: FeePaymentHistoryPagination.empty(),
      );
    }
  }

  Future<PendingFeeApiResponse> fetchPendingFee({
    int limit = 10,
    String? cursor,
  }) async {
    try {
      final qp = <String, dynamic>{
        'limit': limit,
        if (cursor != null && cursor.trim().isNotEmpty) 'cursor': cursor,
      };

      final response = await _networkManager.getDio().get(
        Endpoints.studentPendingFee,
        queryParameters: qp,
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        if (body is Map) {
          return PendingFeeApiResponse.fromJson(
            Map<String, dynamic>.from(body),
          );
        }
      }

      return PendingFeeApiResponse(
        success: false,
        message: 'Failed to load pending fee.',
        data: null,
        pagination: PendingFeePagination.empty(),
      );
    } on DioException catch (e) {
      return PendingFeeApiResponse(
        success: false,
        message: ApiErrorHelper.dioOrFallback(e),
        data: null,
        pagination: PendingFeePagination.empty(),
      );
    } catch (_) {
      return PendingFeeApiResponse(
        success: false,
        message: 'Something went wrong. Please try again.',
        data: null,
        pagination: PendingFeePagination.empty(),
      );
    }
  }

  Future<FeePaymentConfigResponse> fetchPaymentConfig() async {
    try {
      final response = await _networkManager.getDio().get(Endpoints.feePaymentConfig);
      if (response.statusCode == 200 && response.data is Map) {
        final parsed = FeePaymentConfigResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        if (parsed.success) {
          FeePaymentConfigStore.setConfig(parsed.data);
        }
        return parsed;
      }
      return FeePaymentConfigResponse.failure('Failed to load payment config.');
    } on DioException catch (e) {
      return FeePaymentConfigResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return FeePaymentConfigResponse.failure(
        'Something went wrong while loading payment config.',
      );
    }
  }

  Future<FeeInitiatePaymentResponse> initiatePayment({
    required String studentAccountIdCsv,
    required String orderId,
    required String amount,
  }) async {
    try {
      final body = <String, dynamic>{
        'StudentAccountIDCSV': studentAccountIdCsv,
        'OrderID': orderId,
        'Amount': amount,
      };
      final response = await _networkManager.getDio().post(
            Endpoints.feeInitiatePayment,
            data: body,
          );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return FeeInitiatePaymentResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return FeeInitiatePaymentResponse.failure('Failed to initiate payment.');
    } on DioException catch (e) {
      return FeeInitiatePaymentResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return FeeInitiatePaymentResponse.failure(
        'Something went wrong while initiating payment.',
      );
    }
  }

  Future<FeeUpdatePaymentResponse> updatePayment(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _networkManager.getDio().post(
            Endpoints.feeUpdatePayment,
            data: payload,
          );
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data is Map) {
        return FeeUpdatePaymentResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      return FeeUpdatePaymentResponse.failure('Failed to update payment status.');
    } on DioException catch (e) {
      return FeeUpdatePaymentResponse.failure(ApiErrorHelper.dioOrFallback(e));
    } catch (_) {
      return FeeUpdatePaymentResponse.failure(
        'Something went wrong while updating payment.',
      );
    }
  }
}
