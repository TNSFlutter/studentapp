// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// import '../controllers/auth_controller.dart';
// import '../helpers/status_helper.dart';
// import '../models/login_models.dart';
// import '../routes/app_routes.dart';

// class SessionManager {
//   static final GetStorage _storage = GetStorage();
//   static final StatusHelper _statusHelper = StatusHelper();

//   /// Check if user is logged in and navigate accordingly
//   static String getInitialRoute() {
//     try {
//       // Check login status
//       bool isLoggedIn = _statusHelper.getLoginStatus;

//       if (!isLoggedIn) {
//         return AppRoutes.login;
//       }

//       // Additional validation: check if session is actually valid
//       if (!isSessionValid()) {
//         // Clear invalid session and go to login
//         _clearSession();
//         return AppRoutes.login;
//       }

//       // User is logged in and session is valid
//       return AppRoutes.dashboard;
//     } catch (e) {
//       // If any error occurs, clear session and go to login
//       _clearSession();
//       return AppRoutes.login;
//     }
//   }

//   /// Check if token is expired
//   static bool _isTokenExpired() {
//     try {
//       final sessionMap = _storage.read('SessionData') ?? {};
//       String? expiresAt = sessionMap['expires_at'];

//       if (expiresAt == null) return true;

//       DateTime expiryDate = DateTime.parse(expiresAt);
//       return DateTime.now().isAfter(expiryDate);
//     } catch (e) {
//       return true;
//     }
//   }

//   /// Clear session data
//   static void _clearSession() {
//     try {
//       _storage.remove('UserData');
//       _storage.remove('SessionData');
//       _storage.remove('TOKEN');
//       _storage.remove('REFRESH_TOKEN');
//       _storage.remove('USERNAME_SAVED');
//       _statusHelper.setLoginStatus(false);

//       // Also clear the auth controller state
//       try {
//         final authController = Get.find<AuthController>();
//         authController.isLoggedIn.value = false;
//         authController.currentUser = null;
//         authController.currentSession = null;
//       } catch (e) {
//         // Controller might not be initialized yet
//       }
//     } catch (e) {
//       // Handle error silently
//     }
//   }

//   /// Clear login status only
//   static void clearLoginStatus() {
//     try {
//       _statusHelper.setLoginStatus(false);

//       // Also clear the auth controller state
//       try {
//         final authController = Get.find<AuthController>();
//         authController.isLoggedIn.value = false;
//       } catch (e) {
//         // Controller might not be initialized yet
//       }
//     } catch (e) {
//       // Handle error silently
//     }
//   }

//   /// Initialize session and load user data into controllers
//   static void initializeSession() {
//     try {
//       final authController = Get.find<AuthController>();

//       // Check if user is actually logged in
//       bool isLoggedIn = _statusHelper.getLoginStatus;

//       if (isLoggedIn) {
//         // Load user data from storage
//         final userMap = _storage.read('UserData') ?? {};
//         if (userMap.isNotEmpty) {
//           // Create User object from stored data
//           authController.currentUser = User.fromJson(userMap);
//         }

//         // Load session data from storage
//         final sessionMap = _storage.read('SessionData') ?? {};
//         if (sessionMap.isNotEmpty) {
//           // Create Session object from stored data
//           authController.currentSession = Session(
//             token: _storage.read('TOKEN') ?? '',
//             refreshToken: _storage.read('REFRESH_TOKEN') ?? '',
//             expiresAt: sessionMap['expires_at'] ?? '',
//             device: SessionDevice(
//               deviceId: sessionMap['device']?['device_id'] ?? '',
//               deviceToken: sessionMap['device']?['device_token'] ?? '',
//               deviceType: sessionMap['device']?['device_type'] ?? '',
//               deviceName: sessionMap['device']?['device_name'] ?? '',
//             ),
//           );
//         }
//       }

//       // Update login status in controller
//       authController.isLoggedIn.value = isLoggedIn;
//     } catch (e) {
//       // If any error occurs, clear session and set logged out
//       _clearSession();
//       final authController = Get.find<AuthController>();
//       authController.isLoggedIn.value = false;
//     }
//   }

//   /// Validate current session
//   static bool isSessionValid() {
//     try {
//       // Check login status
//       bool isLoggedIn = _statusHelper.getLoginStatus;
//       if (!isLoggedIn) return false;

//       // Check if token exists
//       String? token = _storage.read('TOKEN');
//       if (token == null || token.isEmpty) return false;

//       // Check if user data exists
//       final userData = _storage.read('UserData');
//       if (userData == null || userData.isEmpty) return false;

//       // Check if token is expired
//       if (_isTokenExpired()) return false;

//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// Refresh session data
//   static Future<void> refreshSession() async {
//     try {
//       final authController = Get.find<AuthController>();
//       authController.checkLoginStatus();
//     } catch (e) {
//       // Handle error silently
//     }
//   }

//   /// Debug method to check session state
//   static void debugSessionState() {
//     try {
//       print('=== Session Debug Info ===');
//       print('Login Status: ${_statusHelper.getLoginStatus}');
//       print('Token exists: ${_storage.read('TOKEN') != null}');
//       print('UserData exists: ${_storage.read('UserData') != null}');
//       print('SessionData exists: ${_storage.read('SessionData') != null}');
//       print('Token expired: ${_isTokenExpired()}');
//       print('Session valid: ${isSessionValid()}');
//       print('========================');
//     } catch (e) {
//       print('Error in debugSessionState: $e');
//     }
//   }

//   /// Force logout - clear everything
//   static void forceLogout() {
//     _clearSession();
//     clearLoginStatus();
//   }

//   /// Reset app state completely - for testing purposes
//   static void resetAppState() {
//     try {
//       // Clear all storage
//       _storage.erase();

//       // Clear login status
//       _statusHelper.setLoginStatus(false);

//       // Clear auth controller state
//       try {
//         final authController = Get.find<AuthController>();
//         authController.isLoggedIn.value = false;
//         authController.currentUser = null;
//         authController.currentSession = null;
//         authController.usernameController.clear();
//         authController.passwordController.clear();
//         authController.usernameError.value = '';
//         authController.passwordError.value = '';
//       } catch (e) {
//         // Controller might not be initialized yet
//       }

//       print('App state reset completed');
//     } catch (e) {
//       print('Error resetting app state: $e');
//     }
//   }
// }
