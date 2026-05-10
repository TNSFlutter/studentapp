import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:studentapp/constants/string_constants.dart';
import 'package:studentapp/helpers/app_snackbar.dart';
import 'package:studentapp/helpers/network/endpoints.dart';
import 'package:studentapp/helpers/status_helper.dart';
import 'package:studentapp/models/login_models.dart';
import 'package:studentapp/services/navigation_service.dart';

/// The NetworkManager class provide an API network requests
class NetworkManager {
  static final NetworkManager _apiService = NetworkManager._internal();

  Dio _dio = Dio();

  /// Avoid rebuilding [Dio] on every call — that can race with in-flight requests
  /// and confuse multipart handling when uploads run back-to-back.
  bool _dioClientReady = false;

  bool isContentTypeJson = true;
  bool _isHttpRequest = false;
  bool _urlEncode = false;
  bool sendCS = true;
  String baseUrl = Endpoints.baseURL;
  String? appUrl;

  factory NetworkManager() {
    return _apiService;
  }

  NetworkManager._internal();

  Dio getDio({isJsonType = true, isHttpRequest = false, isUrlEncoded = false}) {
    isContentTypeJson = isJsonType;
    _urlEncode = isUrlEncoded;
    _isHttpRequest = isHttpRequest;
    _ensureDioClient();
    return _dio;
  }

  static NetworkManager get instance => _apiService;

  /// Routes that must not receive a stale JWT (credentials / refresh flows).
  bool _shouldSkipAuthorizationHeader(String path) {
    final p = path.toLowerCase();
    if (p.contains(Endpoints.refreshToken.toLowerCase())) return true;
    if (p.contains(Endpoints.login.toLowerCase())) return true;
    if (p.contains('auth/login-otp')) return true;
    if (p.contains(Endpoints.forgetPassword.toLowerCase())) return true;
    if (p.contains('auth/forgot-password')) return true;
    if (p.contains('auth/reset-password')) return true;
    if (p.contains('auth/verify-otp')) return true;
    if (p.contains(Endpoints.resendOtp.toLowerCase())) return true;
    return false;
  }

  /// Refresh payload may be flat tokens or `{ user, session }` (same as login).
  ({String? access, String? refresh}) _tokensFromRefreshData(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return (access: null, refresh: null);
    Map<String, dynamic>? session;
    final s = data['session'];
    if (s is Map<String, dynamic>) session = s;
    final src = session ?? data;
    final accessRaw = src['token'] ?? src['access_token'];
    final refreshRaw = src['refresh_token'];
    final access = accessRaw?.toString().trim();
    final refresh = refreshRaw?.toString().trim();
    return (
      access: access != null && access.isNotEmpty ? access : null,
      refresh: refresh != null && refresh.isNotEmpty ? refresh : null,
    );
  }

  void _persistRefreshSessionExtras(Map<String, dynamic> data) {
    try {
      final sessionRaw = data['session'];
      if (sessionRaw is Map<String, dynamic>) {
        final exp =
            sessionRaw['access_token_expires_at'] ??
            sessionRaw['expires_at'];
        if (exp != null) {
          final box = GetStorage();
          final prev = box.read('SessionData');
          final sm = prev is Map
              ? Map<String, dynamic>.from(prev)
              : <String, dynamic>{};
          sm['expires_at'] = exp.toString();
          box.write('SessionData', sm);
        }
      }
      final userRaw = data['user'];
      if (userRaw is Map<String, dynamic>) {
        GetStorage().write(
          'UserData',
          User.fromJson(userRaw).toJson(),
        );
      }
    } catch (_) {}
  }

  void _ensureDioClient() {
    if (_dioClientReady) return;

    _dio = Dio();
    _dio.options.baseUrl = baseUrl;
    _dio.options.contentType = Headers.jsonContentType;
    _dio.interceptors.add(LogInterceptor());
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        // Logging multipart bodies touches [FormData.files] and can interact badly
        // with Dio's transformer when uploads run one after another.
        requestBody: false,
        responseBody: true,
        responseHeader: true,
        compact: false,
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attach Bearer token whenever it exists in storage. Do not rely on
          // login_status alone — it can race or desync while the JWT is valid.
          if (!_shouldSkipAuthorizationHeader(options.path)) {
            final rawToken = GetStorage().read(Constants.token);
            final token = rawToken?.toString().trim();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }

          // Let Dio set multipart boundary for file uploads; forcing JSON breaks FormData.
          if (options.data is FormData) {
            options.contentType = null;
            options.headers.remove(Headers.contentTypeHeader);
          } else if (isContentTypeJson) {
            options.headers["Content-Type"] = "application/json";
          }

          if (_urlEncode && options.data is! FormData) {
            options.headers["Content-Type"] =
                "application/x-www-form-urlencoded";
          }

          if (_isHttpRequest) {
            options.headers["X-Requested-With"] = "XMLHttpRequest";
          }
          return handler.next(options); //continue
        },
        onResponse: (response, handler) {
          return handler.next(response); // continue
        },
        onError: (DioException e, handler) async {
          // Handle token expiration (401 Unauthorized or 403 Forbidden)
          final statusCode = e.response?.statusCode;
          final isTokenExpired = statusCode == 401 || statusCode == 403;

          // Check if error message indicates token expiration
          final responseData = e.response?.data;
          bool isExpiredMessage = false;
          if (responseData is Map<String, dynamic>) {
            final message =
                responseData['message']?.toString().toLowerCase() ?? '';
            isExpiredMessage =
                message.contains('expired') ||
                message.contains('token has expired') ||
                (message.contains('token') && message.contains('expired'));
          }

          // Only handle token refresh if it's not already a refresh token request
          if ((isTokenExpired || isExpiredMessage) &&
              !_shouldSkipAuthorizationHeader(e.requestOptions.path)) {
            try {
              String? refreshToken = GetStorage().read(Constants.refreshToken);

              // Check if refresh token exists
              if (refreshToken == null || refreshToken.isEmpty) {
                // No refresh token available, cannot refresh - navigate to login
                _clearSessionAndNavigateToLogin();
                return handler.next(e);
              }

              var input = {"refresh_token": refreshToken};

              // Create a new Dio instance without interceptors for refresh token call
              // to avoid infinite loop
              final refreshDio = Dio();
              refreshDio.options.baseUrl = baseUrl;
              refreshDio.options.contentType = Headers.jsonContentType;

              // Call refresh token API without Authorization header
              Response<dynamic>? refreshResponse;
              try {
                refreshResponse = await refreshDio.post(
                  Endpoints.refreshToken,
                  data: input,
                  options: Options(
                    headers: {"Content-Type": "application/json"},
                    validateStatus: (status) {
                      // Accept all status codes to handle them manually
                      return true;
                    },
                  ),
                );
              } catch (refreshError) {
                // Refresh token API call failed - navigate to login
                if (!kReleaseMode) {
                  debugPrint('Refresh token API call failed: $refreshError');
                }
                _clearSessionAndNavigateToLogin();
                return handler.next(e);
              }

              // Check if refresh token API returned an error (401, 403, or success: false)
              if (refreshResponse.statusCode == 401 ||
                  refreshResponse.statusCode == 403 ||
                  (refreshResponse.data != null &&
                      refreshResponse.data is Map<String, dynamic> &&
                      refreshResponse.data['success'] == false)) {
                // Refresh token is expired or invalid - navigate to login
                if (!kReleaseMode) {
                  debugPrint(
                    'Refresh token expired or invalid. Status: ${refreshResponse.statusCode}',
                  );
                }
                _clearSessionAndNavigateToLogin();
                return handler.next(e);
              }

              // Check if refresh was successful
              if (refreshResponse.statusCode == 200 &&
                  refreshResponse.data != null &&
                  refreshResponse.data['success'] == true &&
                  refreshResponse.data['data'] != null) {
                // Extract new tokens (flat or nested under `session`, same as login/OTP)
                final data = refreshResponse.data['data'];
                final dataMap = data is Map<String, dynamic> ? data : null;
                if (dataMap != null) {
                  _persistRefreshSessionExtras(dataMap);
                }
                final tokens = _tokensFromRefreshData(dataMap);
                final newToken = tokens.access;
                final newRefreshToken = tokens.refresh;

                // Validate tokens before storing
                if (newToken != null && newToken.toString().isNotEmpty) {
                  // Store new tokens immediately (GetStorage.write is synchronous)
                  GetStorage().write(Constants.token, newToken.toString());

                  if (newRefreshToken != null &&
                      newRefreshToken.toString().isNotEmpty) {
                    GetStorage().write(
                      Constants.refreshToken,
                      newRefreshToken.toString(),
                    );
                  }

                  // Verify token was stored correctly by reading it back
                  final storedToken = GetStorage().read(Constants.token);

                  if (storedToken != null &&
                      storedToken.toString().isNotEmpty) {
                    // Update the original request headers with new token
                    e.requestOptions.headers["Authorization"] =
                        "Bearer $storedToken";

                    // Retry the original request with new token
                    final opts = Options(
                      method: e.requestOptions.method,
                      headers: e.requestOptions.headers,
                    );

                    // First multipart attempt may have finalized [FormData]; retry must
                    // use a fresh copy or the file part is empty on the wire.
                    dynamic retryData = e.requestOptions.data;
                    if (retryData is FormData) {
                      retryData = retryData.clone();
                    }

                    final cloneReq = await _dio.request(
                      e.requestOptions.path,
                      options: opts,
                      data: retryData,
                      queryParameters: e.requestOptions.queryParameters,
                    );

                    return handler.resolve(cloneReq);
                  } else {
                    // Token storage failed - navigate to login
                    _clearSessionAndNavigateToLogin();
                    return handler.next(e);
                  }
                } else {
                  // Invalid token in response - navigate to login
                  _clearSessionAndNavigateToLogin();
                  return handler.next(e);
                }
              } else {
                // Refresh token API failed - navigate to login
                _clearSessionAndNavigateToLogin();
                return handler.next(e);
              }
            } catch (error) {
              // Log error for debugging
              if (!kReleaseMode) {
                debugPrint('Token refresh error: $error');
              }
              // Clear session and navigate to login when token refresh fails
              _clearSessionAndNavigateToLogin();
              // Return the original error if token refresh fails
              return handler.next(e);
            }
          } else if (e.response?.statusCode == 400) {
            // Do not use Get.snackbar here: 400s are common validation errors and
            // GetX snackbars require a GetMaterialApp overlay — nested routes can crash
            // with "No Overlay widget found". Callers should show errors with
            // ScaffoldMessenger or handle via ApiErrorHelper / returned message.
            if (!kReleaseMode && e.response?.data != null) {
              debugPrint('API 400: ${e.response!.data}');
            }
            return handler.next(e);
          } else {
            // For all other errors, pass them through to the calling code
            // This ensures that 200 responses with success: false are handled properly
            return handler.next(e);
          }
        },
      ),
    );

    _dio.options.receiveTimeout = Duration(seconds: 3000);
    _dioClientReady = true;
  }

  /// Clear session data and navigate to login screen
  void _clearSessionAndNavigateToLogin() {
    try {
      final getBox = GetStorage();
      final statusHelper = StatusHelper();

      // Clear all stored data
      getBox.remove('UserData');
      getBox.remove('SessionData');
      getBox.remove(Constants.token);
      getBox.remove(Constants.refreshToken);
      getBox.remove(Constants.userNameSaved);

      // Update login status
      statusHelper.setLoginStatus(false);

      // Show message to user
      AppSnackbar.showSnackbar(
        "Session Expired",
        "Your session has expired. Please login again.",
        AlertType.error,
        duration: const Duration(seconds: 3),
      );

      // Navigate to login screen
      // Use a small delay to ensure storage is cleared and message is shown
      Future.delayed(const Duration(milliseconds: 300), () {
        NavigationService.navigateToLogin();
      });
    } catch (e) {
      debugPrint('Error clearing session: $e');
      // Still try to navigate to login
      NavigationService.navigateToLogin();
    }
  }
}
