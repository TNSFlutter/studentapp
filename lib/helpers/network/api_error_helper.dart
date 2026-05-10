import 'package:dio/dio.dart';

/// Shared extraction of API error text from [DioException] responses.
class ApiErrorHelper {
  ApiErrorHelper._();

  static String? dioResponseMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }
    return null;
  }

  static String dioOrFallback(
    DioException e, [
    String fallback = 'Something went wrong. Please try again.',
  ]) {
    return dioResponseMessage(e) ?? e.message ?? fallback;
  }
}
