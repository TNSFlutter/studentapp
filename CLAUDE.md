# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**XScholar ERP Parents App** — a Flutter mobile app for parents to monitor their children's school activities (attendance, homework, fees, messages, notices, etc.).

## Common Commands

```bash
# Run the app
flutter run

# Build APK
flutter build apk

# Build iOS
flutter build ios

# Analyze code
flutter analyze

# Run tests
flutter test

# Get dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade
```

## Architecture

The app uses **GetX** as the state management, dependency injection, and navigation framework.

### Flow

```
SplashScreen → WelcomeScreen → LoginScreen → SelectStudentScreen → DashboardScreen
```

- `SplashScreen` checks auth state via `AuthController.checkLoginStatus()` then routes accordingly.
- `DashboardScreen` is a tab shell (index 2 = Home by default) containing: Fee, Homework, Home, Message, More.

### Key Layers

**Controllers** (`lib/controllers/`)
- `AuthController` — login, logout, forgot/reset password, token expiry checks. Registered as a permanent singleton in `main.dart` via `Get.put()`.
- `StudentController` — fetches student list, handles student selection. Created lazily after login.

**Networking** (`lib/helpers/network/`)
- `NetworkManager` — singleton Dio wrapper. Call `NetworkManager.instance.getDio()` to get a configured Dio instance.
- Auth interceptor automatically attaches `Bearer` token from `GetStorage`. On 401/403, it silently attempts a token refresh, retries the original request, and falls back to clearing the session and navigating to login.
- `Endpoints` — all API base URL and path constants. Base URL: `https://api-mys-prod.levnext.com/parents/`

**Services** (`lib/services/`)
- `NavigationService` — uses a global `navigatorKey` for navigation outside of widget tree (e.g., from the network interceptor).
- `CrashlyticsService` — stub that wraps crash/error logging (Firebase Crashlytics imports are commented out).

**Helpers** (`lib/helpers/`)
- `StatusHelper` — thin wrapper around `GetStorage` for persisting login boolean.
- `AppSnackbar` — GetX snackbar helper with `AlertType` (success/error/warning).
- `DeviceInfoHelper` — collects device ID, type, name, model for login requests.
- `Validators` — common field validation functions.
- `themes.dart` — app theme definitions.

**Models** (`lib/models/`)
- Plain Dart classes with `fromJson`/`toJson`. No code generation — all serialization is hand-written.

**Storage keys** (`lib/constants/string_constants.dart`)
- `Constants.token`, `Constants.refreshToken`, `Constants.userNameSaved` — keys used with `GetStorage`.

### Routes

Defined in `lib/routes/app_routes.dart` as static string constants; registered in `GetMaterialApp.getPages` in `main.dart`.

## Notable Constraints

- Firebase (Messaging, Crashlytics) dependencies are **commented out** in `pubspec.yaml`. `CrashlyticsService` is a no-op stub — do not add Firebase calls without re-enabling the dependencies.
- `session_manager.dart` is fully commented out; session logic lives in `AuthController`.
- `NetworkManager._init()` is called on every `getDio()` call, which recreates the `Dio` instance each time — keep this in mind when chaining requests.
- Assets live in `assets/images/`; add new image assets there and register them in `pubspec.yaml` under `flutter.assets`.
