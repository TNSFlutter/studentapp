import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../constants/string_constants.dart';
import '../helpers/app_snackbar.dart';
import '../helpers/device_info_helper.dart';
import '../helpers/network/api_error_helper.dart';
import '../helpers/network/endpoints.dart';
import '../helpers/network/network_manager.dart';
import '../helpers/status_helper.dart';
import '../helpers/validators.dart';
import '../models/auth_session_models.dart';
import '../models/login_models.dart';
import '../services/crashlytics_service.dart';
import '../services/navigation_service.dart';
import 'student_controller.dart';
import 'student_profile_controller.dart';

class AuthController extends GetxController {
  final _statusHelper = StatusHelper();

  // Observable variables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;

  // Form controllers
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // Error messages
  final usernameError = ''.obs;
  final passwordError = ''.obs;

  /// Consumed by [LoginScreen] after navigation — avoids Get.snackbar + route tear-down races.
  String? _pendingLoginSuccessMessage;

  String? takePendingLoginSuccessMessage() {
    final m = _pendingLoginSuccessMessage;
    _pendingLoginSuccessMessage = null;
    return m;
  }

  // User data
  User? currentUser;
  Session? currentSession;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  /// Check if user is already logged in
  void checkLoginStatus() {
    bool loginStatus = _statusHelper.getLoginStatus;
    isLoggedIn.value = loginStatus;

    if (loginStatus) {
      // Load user data from storage
      _loadUserDataFromStorage();
    }
  }

  /// Load user data from GetStorage
  void _loadUserDataFromStorage() {
    try {
      final getBox = GetStorage();

      // Restore user data
      final userMap = getBox.read('UserData') ?? {};
      if (userMap.isNotEmpty) {
        currentUser = User.fromJson(userMap);
      }

      // Restore session data
      final sessionMap = getBox.read('SessionData') ?? {};
      if (sessionMap.isNotEmpty) {
        currentSession = Session(
          token: getBox.read(Constants.token) ?? '',
          refreshToken: getBox.read(Constants.refreshToken) ?? '',
          expiresAt: sessionMap['expires_at'] ?? '',
          devices: [
            SessionDevice(
              deviceId: sessionMap['device']?['device_id'] ?? '',
              deviceToken: sessionMap['device']?['device_token'] ?? '',
              deviceType: sessionMap['device']?['device_type'] ?? '',
              deviceName: sessionMap['device']?['device_name'] ?? '',
            ),
          ],
        );
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Validate login form
  bool validateLoginForm() {
    bool isValid = true;

    // Clear previous errors
    usernameError.value = '';
    passwordError.value = '';

    // Validate username/email
    String username = usernameController.text.trim();
    if (username.isEmpty) {
      usernameError.value = 'Username or email is required';
      isValid = false;
    } else if (username.contains('@')) {
      // If it contains @, validate as email
      if (!validateEmail(username)) {
        usernameError.value = 'Please enter a valid email address';
        isValid = false;
      }
    } else {
      // If no @, validate as username (minimum 3 characters)
      if (username.length < 3) {
        usernameError.value = 'Username must be at least 3 characters';
        isValid = false;
      }
    }

    // Validate password
    String? passwordValidation = getValidationError(
      passwordController.text,
      'Password',
      isRequired: true,
      minLength: 6,
    );
    if (passwordValidation != null) {
      passwordError.value = passwordValidation;
      isValid = false;
    }

    return isValid;
  }

  /// Perform login
  Future<bool> login() async {
    _pendingLoginSuccessMessage = null;
    if (!validateLoginForm()) {
      return false;
    }

    isLoading.value = true;

    try {
      // Get device information with FCM token
      DeviceInfo deviceInfo = await DeviceInfoHelper.instance.getDeviceInfo();

      // Create login request using proper model
      final loginRequest = LoginRequest(
        phone: usernameController.text.trim(),
        password: passwordController.text,
        device: DeviceInfo(
          deviceId: deviceInfo.deviceId,
          deviceType: deviceInfo.deviceType,
          deviceName: deviceInfo.deviceName,
          deviceModel: deviceInfo.deviceModel,
          deviceToken: deviceInfo.deviceToken,
        ),
      );

      // Make API call
      final response = await NetworkManager.instance.getDio().post(
        Endpoints.login,
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        LoginResponse loginResponse = LoginResponse.fromJson(response.data);

        if (loginResponse.success && loginResponse.data != null) {
          // Store user data
          await _storeUserData(loginResponse.data!);

          // Update login status
          _statusHelper.setLoginStatus(true);
          isLoggedIn.value = true;

          // Set user identifier in Crashlytics
          await CrashlyticsService.setUserIdentifier(
            loginResponse.data!.user.userName,
          );
          await CrashlyticsService.setCustomKey(
            'user_role',
            loginResponse.data!.user.roleId,
          );
          await CrashlyticsService.log(
            'User logged in successfully: ${loginResponse.data!.user.userName}',
          );

          // Clear form
          usernameController.clear();
          passwordController.clear();

          // Defer snackbar to [LoginScreen] after pushReplacement so Overlay is stable
          // (Get.snackbar here + Get.offAllNamed caused "No Overlay widget found").
          _pendingLoginSuccessMessage = loginResponse.message;

          return true;
        } else {
          // Log failed login attempt
          await CrashlyticsService.log(
            'Login failed for user: ${usernameController.text.trim()}',
          );
          await CrashlyticsService.recordError(
            Exception('Login failed: ${loginResponse.message}'),
            StackTrace.current,
          );

          AppSnackbar.showSnackbar(
            'Login Failed',
            loginResponse.message,
            AlertType.error,
          );
          return false;
        }
      } else if (response.statusCode == 401) {
        // Unauthorized - invalid credentials
        AppSnackbar.showSnackbar(
          'Authentication Failed',
          'Invalid username/email or password. Please check your credentials and try again.',
          AlertType.error,
        );
        return false;
      } else if (response.statusCode == 400) {
        // Bad Request - invalid request format
        AppSnackbar.showSnackbar(
          'Invalid Request',
          'The request format is invalid. Please try again.',
          AlertType.error,
        );
        return false;
      } else {
        // Other HTTP errors
        AppSnackbar.showSnackbar(
          'Server Error',
          'An error occurred on the server. Please try again later.',
          AlertType.error,
        );
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          // Unauthorized - invalid credentials
          AppSnackbar.showSnackbar(
            'Authentication Failed',
            'Invalid username/email or password. Please check your credentials and try again.',
            AlertType.error,
          );
          return false;
        }
      }
      // Log error to Crashlytics
      await CrashlyticsService.recordError(e, StackTrace.current);
      await CrashlyticsService.log(
        'Login error for user: ${usernameController.text.trim()}',
      );

      // Handle specific network exceptions
      if (e is SocketException) {
        AppSnackbar.showSnackbar(
          'Network Error',
          'No internet connection. Please check your network and try again.',
          AlertType.error,
        );
      } else if (e.toString().contains('TimeoutException')) {
        AppSnackbar.showSnackbar(
          'Timeout Error',
          'Request timed out. Please try again.',
          AlertType.error,
        );
      } else {
        AppSnackbar.showSnackbar(
          'Error',
          'An unexpected error occurred. Please try again.',
          AlertType.error,
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Store user data in GetStorage
  Future<void> _storeUserData(LoginData loginData) async {
    try {
      final getBox = GetStorage();

      // Store complete user data as single object
      getBox.write('UserData', loginData.user.toJson());

      // Store complete session data as single object
      // Store the first device for backward compatibility
      final firstDevice = loginData.session.devices.isNotEmpty
          ? loginData.session.devices.first
          : null;

      getBox.write('SessionData', {
        'expires_at': loginData.session.expiresAt,
        'device': firstDevice != null
            ? {
                'device_id': firstDevice.deviceId,
                'device_token': firstDevice.deviceToken,
                'device_type': firstDevice.deviceType,
                'device_name': firstDevice.deviceName,
              }
            : null,
      });

      // Store token and refresh token separately
      getBox.write(Constants.token, loginData.session.token);
      getBox.write(Constants.refreshToken, loginData.session.refreshToken);
      getBox.write(Constants.userNameSaved, loginData.user.userName);

      // Update current user and session
      currentUser = loginData.user;
      currentSession = loginData.session;
    } catch (e) {
      // Handle storage error
      throw Exception('Failed to store user data: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      // First, try to call the logout API
      try {
        final response = await NetworkManager.instance.getDio().post(
          Endpoints.logout,
          data: <String, dynamic>{},
        );

        final code = response.statusCode ?? 0;
        if (code >= 200 && code < 300 && response.data is Map) {
          final logoutResponse = LogoutResponse.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          );

          if (logoutResponse.success && logoutResponse.message.isNotEmpty) {
            AppSnackbar.showSnackbar(
              'Success',
              logoutResponse.message,
              AlertType.success,
            );
          }
        }
      } catch (e) {
        // If API call fails, we still proceed with local logout
        // Log error to Crashlytics instead of print
        await CrashlyticsService.log('Logout API call failed: $e');
      }

      // Clear other controllers data
      try {
        // Clear dashboard controller if it exists
        // TODO: Implement when DashboardController is created
        // if (Get.isRegistered<DashboardController>()) {
        //   final dashboardController = Get.find<DashboardController>();
        //   dashboardController.clearAllData();
        // }
      } catch (e) {
        // Ignore if controller doesn't exist
      }
    } catch (e) {
      // Log logout error
      await CrashlyticsService.recordError(e, StackTrace.current);
      await CrashlyticsService.log('Logout error occurred');

      AppSnackbar.showSnackbar(
        'Error',
        'Failed to logout. Please try again.',
        AlertType.error,
      );
    }

    // Always proceed with local logout regardless of API response
    // Log logout event
    if (currentUser != null) {
      await CrashlyticsService.log('User logged out: ${currentUser!.userName}');
    }

    DeviceInfoHelper.instance.clearCache();

    if (Get.isRegistered<StudentController>()) {
      Get.delete<StudentController>(force: true);
    }

    if (Get.isRegistered<StudentProfileController>()) {
      Get.delete<StudentProfileController>(force: true);
    }

    await GetStorage().erase();

    _statusHelper.setLoginStatus(false);
    isLoggedIn.value = false;

    currentUser = null;
    currentSession = null;

    usernameController.clear();
    passwordController.clear();
    phoneController.clear();

    usernameError.value = '';
    passwordError.value = '';
    phoneError.value = '';

    await Future.delayed(const Duration(milliseconds: 200));

    await NavigationService.navigateToLogin();

    Get.forceAppUpdate();
  }

  /// Get current user
  User? getCurrentUser() {
    return currentUser;
  }

  /// Get current session
  Session? getCurrentSession() {
    return currentSession;
  }

  /// Check if token is expired
  bool isTokenExpired() {
    try {
      final getBox = GetStorage();
      final sessionMap = getBox.read('SessionData') ?? {};
      String? expiresAt = sessionMap['expires_at'];

      if (expiresAt == null) return true;

      DateTime expiryDate = DateTime.parse(expiresAt);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return true;
    }
  }

  // Forgot Password Methods
  final phoneController = TextEditingController();
  final phoneError = ''.obs;

  /// Validate phone number
  bool validatePhone() {
    phoneError.value = '';

    if (phoneController.text.trim().isEmpty) {
      phoneError.value = 'Phone number is required';
      return false;
    }

    if (phoneController.text.trim().length < 10) {
      phoneError.value = 'Please enter a valid phone number';
      return false;
    }

    return true;
  }

  /// Send forgot password request
  Future<bool> sendForgotPasswordRequest() async {
    if (!validatePhone()) {
      return false;
    }

    isLoading.value = true;

    try {
      final request = ForgotPasswordRequest(phone: phoneController.text.trim());

      final response = await NetworkManager.instance.getDio().post(
        Endpoints.forgotPassword,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        ForgotPasswordResponse forgotPasswordResponse =
            ForgotPasswordResponse.fromJson(response.data);

        if (forgotPasswordResponse.success) {
          AppSnackbar.showSnackbar(
            'Success',
            forgotPasswordResponse.message,
            AlertType.success,
          );

          // Navigate to OTP screen
          //NavigationService.navigateToOtp(phoneController.text.trim());
          return true;
        } else {
          AppSnackbar.showSnackbar(
            'Error',
            forgotPasswordResponse.message,
            AlertType.error,
          );
          return false;
        }
      } else {
        AppSnackbar.showSnackbar(
          'Error',
          'Failed to send OTP. Please try again.',
          AlertType.error,
        );
        return false;
      }
    } catch (e) {
      await CrashlyticsService.recordError(e, StackTrace.current);

      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          AppSnackbar.showSnackbar(
            'Invalid Request',
            'Please check your phone number and try again.',
            AlertType.error,
          );
        } else if (e.response?.statusCode == 404) {
          AppSnackbar.showSnackbar(
            'Not Found',
            'Phone number not found in our records.',
            AlertType.error,
          );
        } else {
          AppSnackbar.showSnackbar(
            'Error',
            'Failed to send OTP. Please try again.',
            AlertType.error,
          );
        }
      } else {
        AppSnackbar.showSnackbar(
          'Error',
          'An unexpected error occurred. Please try again.',
          AlertType.error,
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Send forgot-password OTP using explicit phone.
  Future<bool> sendForgotPasswordOtp(String phone) async {
    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty || cleanPhone.length < 10) {
      AppSnackbar.showSnackbar(
        'Invalid Phone',
        'Please enter a valid phone number.',
        AlertType.error,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await NetworkManager.instance.getDio().post(
        Endpoints.forgetPassword,
        data: <String, dynamic>{'phone': cleanPhone},
      );

      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300 && response.data is Map) {
        final res = ForgotPasswordResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        if (res.success) {
          AppSnackbar.showSnackbar(
            'Success',
            res.message.isEmpty
                ? 'If an account exists for this number, an OTP has been sent.'
                : res.message,
            AlertType.success,
          );
          return true;
        }
        AppSnackbar.showSnackbar(
          'Error',
          res.message.isEmpty ? 'Unable to send OTP.' : res.message,
          AlertType.error,
        );
        return false;
      }

      AppSnackbar.showSnackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        AlertType.error,
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.showSnackbar(
        'Error',
        ApiErrorHelper.dioOrFallback(e),
        AlertType.error,
      );
      return false;
    } catch (e) {
      await CrashlyticsService.recordError(e, StackTrace.current);
      AppSnackbar.showSnackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        AlertType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP sent during forgot-password flow.
  Future<bool> verifyForgotPasswordOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    final cleanPhone = phoneNumber.trim();
    final cleanOtp = otp.trim();
    if (cleanPhone.isEmpty || cleanOtp.isEmpty) {
      AppSnackbar.showSnackbar(
        'Invalid Input',
        'Phone number and OTP are required.',
        AlertType.error,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await NetworkManager.instance.getDio().post(
        Endpoints.verifyOtp,
        data: <String, dynamic>{'phone_number': cleanPhone, 'otp': cleanOtp},
      );

      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300 && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final success = map['success'] == true;
        final msg = map['message']?.toString() ?? '';
        if (success) {
          AppSnackbar.showSnackbar(
            'Success',
            msg.isEmpty ? 'OTP verified successfully.' : msg,
            AlertType.success,
          );
          return true;
        }
        AppSnackbar.showSnackbar(
          'Error',
          msg.isEmpty ? 'Invalid or expired OTP.' : msg,
          AlertType.error,
        );
        return false;
      }

      AppSnackbar.showSnackbar(
        'Error',
        'Failed to verify OTP. Please try again.',
        AlertType.error,
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.showSnackbar(
        'Error',
        ApiErrorHelper.dioOrFallback(e),
        AlertType.error,
      );
      return false;
    } catch (e) {
      await CrashlyticsService.recordError(e, StackTrace.current);
      AppSnackbar.showSnackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        AlertType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend forgot-password OTP.
  Future<bool> resendForgotPasswordOtp(String phone) async {
    final cleanPhone = phone.trim();
    if (cleanPhone.isEmpty || cleanPhone.length < 10) {
      AppSnackbar.showSnackbar(
        'Invalid Phone',
        'Please enter a valid phone number.',
        AlertType.error,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await NetworkManager.instance.getDio().post(
        Endpoints.resendOtp,
        data: <String, dynamic>{'phone': cleanPhone},
      );
      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300 && response.data is Map) {
        final map = Map<String, dynamic>.from(response.data as Map);
        final success = map['success'] == true;
        final msg = map['message']?.toString() ?? '';
        if (success) {
          AppSnackbar.showSnackbar(
            'Success',
            msg.isEmpty ? 'OTP resent successfully.' : msg,
            AlertType.success,
          );
          return true;
        }
        AppSnackbar.showSnackbar(
          'Error',
          msg.isEmpty ? 'Failed to resend OTP.' : msg,
          AlertType.error,
        );
        return false;
      }

      AppSnackbar.showSnackbar(
        'Error',
        'Failed to resend OTP. Please try again.',
        AlertType.error,
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.showSnackbar(
        'Error',
        ApiErrorHelper.dioOrFallback(e),
        AlertType.error,
      );
      return false;
    } catch (e) {
      await CrashlyticsService.recordError(e, StackTrace.current);
      AppSnackbar.showSnackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        AlertType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password with OTP
  Future<bool> resetPassword(String phone, int otp, String newPassword) async {
    isLoading.value = true;

    try {
      final request = ResetPasswordRequest(
        phone: phone,
        otp: otp,
        password: newPassword,
      );

      final response = await NetworkManager.instance.getDio().post(
        Endpoints.resetPassword,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        ResetPasswordResponse resetPasswordResponse =
            ResetPasswordResponse.fromJson(response.data);

        if (resetPasswordResponse.success) {
          AppSnackbar.showSnackbar(
            'Success',
            resetPasswordResponse.message,
            AlertType.success,
          );

          // Clear phone controller
          phoneController.clear();

          // Navigate back to login
          NavigationService.navigateToLogin();
          return true;
        } else {
          AppSnackbar.showSnackbar(
            'Error',
            resetPasswordResponse.message,
            AlertType.error,
          );
          return false;
        }
      } else {
        AppSnackbar.showSnackbar(
          'Error',
          'Failed to reset password. Please try again.',
          AlertType.error,
        );
        return false;
      }
    } catch (e) {
      await CrashlyticsService.recordError(e, StackTrace.current);

      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          AppSnackbar.showSnackbar(
            'Invalid Request',
            'Please check your OTP and password.',
            AlertType.error,
          );
        } else if (e.response?.statusCode == 401) {
          AppSnackbar.showSnackbar(
            'Invalid OTP',
            'The OTP you entered is invalid or expired.',
            AlertType.error,
          );
        } else {
          AppSnackbar.showSnackbar(
            'Error',
            'Failed to reset password. Please try again.',
            AlertType.error,
          );
        }
      } else {
        AppSnackbar.showSnackbar(
          'Error',
          'An unexpected error occurred. Please try again.',
          AlertType.error,
        );
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password using phone + OTP string from forgot-password flow.
  Future<bool> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    final cleanPhone = phone.trim();
    final cleanOtp = otp.trim();
    final cleanPassword = newPassword.trim();
    if (cleanPhone.isEmpty || cleanOtp.isEmpty || cleanPassword.isEmpty) {
      AppSnackbar.showSnackbar(
        'Invalid Input',
        'Phone number, OTP and password are required.',
        AlertType.error,
      );
      return false;
    }

    isLoading.value = true;
    try {
      final response = await NetworkManager.instance.getDio().post(
        Endpoints.resetPassword,
        data: <String, dynamic>{
          'phone': cleanPhone,
          'otp': cleanOtp,
          'password': cleanPassword,
        },
      );

      final code = response.statusCode ?? 0;
      if (code >= 200 && code < 300 && response.data is Map) {
        final parsed = ResetPasswordResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        if (parsed.success) {
          AppSnackbar.showSnackbar(
            'Success',
            parsed.message.isEmpty
                ? 'Password reset successfully.'
                : parsed.message,
            AlertType.success,
          );
          return true;
        }
        AppSnackbar.showSnackbar(
          'Error',
          parsed.message.isEmpty ? 'Failed to reset password.' : parsed.message,
          AlertType.error,
        );
        return false;
      }

      AppSnackbar.showSnackbar(
        'Error',
        'Failed to reset password. Please try again.',
        AlertType.error,
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.showSnackbar(
        'Error',
        ApiErrorHelper.dioOrFallback(e),
        AlertType.error,
      );
      return false;
    } catch (e) {
      await CrashlyticsService.recordError(e, StackTrace.current);
      AppSnackbar.showSnackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        AlertType.error,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// `POST auth/logout-all` — logs out all other devices; keeps this session.
  /// Returns `null` on success, else an error message.
  Future<String?> logoutAllOtherDevices() async {
    try {
      final dio = NetworkManager.instance.getDio();
      final res = await dio.post(
        Endpoints.authLogoutAll,
        data: <String, dynamic>{},
      );
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        return 'Request failed ($code).';
      }
      final data = res.data;
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        if (m['success'] == true) return null;
        final msg = m['message']?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
        return 'Could not sign out other devices.';
      }
      return null;
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// `GET auth/sessions` — devices / sessions for the current account.
  Future<({List<AuthSessionItem> sessions, String? error})>
  fetchAuthSessions() async {
    try {
      final dio = NetworkManager.instance.getDio();
      final res = await dio.get(Endpoints.authSessions);
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300 || res.data is! Map) {
        return (
          sessions: <AuthSessionItem>[],
          error: 'Could not load sessions.',
        );
      }
      final parsed = AuthSessionsApiResult.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
      if (!parsed.success) {
        final msg = parsed.message.trim().isNotEmpty
            ? parsed.message
            : 'Could not load sessions.';
        return (sessions: <AuthSessionItem>[], error: msg);
      }
      return (sessions: parsed.sessions, error: null);
    } on DioException catch (e) {
      return (
        sessions: <AuthSessionItem>[],
        error: ApiErrorHelper.dioOrFallback(e),
      );
    } catch (e) {
      return (sessions: <AuthSessionItem>[], error: e.toString());
    }
  }

  /// Logged-in parent: `POST auth/change-password` JSON body
  /// `{ old_password, new_password }`. Returns `null` on success.
  Future<String?> changePasswordAuthenticated({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final dio = NetworkManager.instance.getDio();
      final res = await dio.post(
        Endpoints.changePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );
      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        return 'Request failed ($code).';
      }
      final data = res.data;
      if (data is Map) {
        final m = Map<String, dynamic>.from(data);
        if (m['success'] == true) return null;
        final msg = m['message']?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
        return 'Could not update password.';
      }
      return null;
    } on DioException catch (e) {
      return ApiErrorHelper.dioOrFallback(e);
    } catch (e) {
      return e.toString();
    }
  }

  /// `POST auth/login-otp/send` — sends OTP to the registered mobile number.
  Future<bool> sendLoginOtp(String phone) async {
    final trimmed = phone.trim();
    if (trimmed.length < 10) {
      AppSnackbar.showSnackbar(
        'Invalid phone',
        'Please enter a valid 10-digit mobile number.',
        AlertType.warning,
      );
      return false;
    }

    try {
      final response = await NetworkManager.instance.getDio().post(
        Endpoints.loginOtpSend,
        data: {'phone': trimmed},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final m = Map<String, dynamic>.from(response.data as Map);
        if (m['success'] == true) {
          return true;
        }
        final msg = m['message']?.toString() ?? 'Could not send OTP.';
        AppSnackbar.showSnackbar('Could not send OTP', msg, AlertType.error);
        return false;
      }
      AppSnackbar.showSnackbar(
        'Could not send OTP',
        'Unexpected response from server.',
        AlertType.error,
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.showSnackbar(
        'Could not send OTP',
        ApiErrorHelper.dioOrFallback(e),
        AlertType.error,
      );
      return false;
    } catch (e, st) {
      await CrashlyticsService.recordError(e, st);
      AppSnackbar.showSnackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        AlertType.error,
      );
      return false;
    }
  }

  /// `POST auth/login-otp/verify` — same session payload as password login.
  Future<bool> verifyLoginOtp({
    required String phone,
    required String otp,
  }) async {
    _pendingLoginSuccessMessage = null;
    final trimmedPhone = phone.trim();
    final trimmedOtp = otp.trim();
    if (trimmedOtp.length < 4) {
      AppSnackbar.showSnackbar(
        'Invalid OTP',
        'Please enter the OTP you received.',
        AlertType.warning,
      );
      return false;
    }

    try {
      final deviceInfo = await DeviceInfoHelper.instance.getDeviceInfo();
      final device = DeviceInfo(
        deviceId: deviceInfo.deviceId,
        deviceType: deviceInfo.deviceType,
        deviceName: deviceInfo.deviceName,
        deviceModel: deviceInfo.deviceModel,
        deviceToken: deviceInfo.deviceToken,
      );

      final response = await NetworkManager.instance.getDio().post(
        Endpoints.loginOtpVerify,
        data: {
          'phone': trimmedPhone,
          'otp': trimmedOtp,
          'device': device.toJson(),
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final loginResponse = LoginResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );

        if (loginResponse.success && loginResponse.data != null) {
          await _storeUserData(loginResponse.data!);
          _statusHelper.setLoginStatus(true);
          isLoggedIn.value = true;

          await CrashlyticsService.setUserIdentifier(
            loginResponse.data!.user.userName,
          );
          await CrashlyticsService.setCustomKey(
            'user_role',
            loginResponse.data!.user.roleId,
          );
          await CrashlyticsService.log(
            'User logged in via OTP: ${loginResponse.data!.user.userName}',
          );

          usernameController.text = trimmedPhone;
          _pendingLoginSuccessMessage = loginResponse.message;

          return true;
        }

        AppSnackbar.showSnackbar(
          'Login failed',
          loginResponse.message.isNotEmpty
              ? loginResponse.message
              : 'Could not verify OTP.',
          AlertType.error,
        );
        return false;
      }

      AppSnackbar.showSnackbar(
        'Login failed',
        'Unexpected response from server.',
        AlertType.error,
      );
      return false;
    } on DioException catch (e) {
      AppSnackbar.showSnackbar(
        'Login failed',
        ApiErrorHelper.dioOrFallback(e),
        AlertType.error,
      );
      return false;
    } catch (e, st) {
      await CrashlyticsService.recordError(e, st);
      AppSnackbar.showSnackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        AlertType.error,
      );
      return false;
    }
  }
}
