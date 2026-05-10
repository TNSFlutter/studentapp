import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'controllers/auth_controller.dart';
import 'controllers/locale_controller.dart';
import 'controllers/theme_controller.dart';
import 'firebase_options.dart';
import 'helpers/notification_service.dart';
import 'helpers/themes.dart';
import 'l10n/app_translations.dart';
import 'routes/app_routes.dart';
import 'services/navigation_service.dart';
import 'views/auth/login_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/select_student/select_student_screen.dart';
import 'views/splash_screen.dart';
import 'views/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e, st) {
    debugPrint(
      'Firebase init skipped (unsupported platform or misconfigured): $e\n$st',
    );
  }
  await GetStorage.init();
  await GetStorage.init('app_prefs');
  await NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<LocaleController>()) {
      Get.put(LocaleController(), permanent: true);
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    return GetBuilder<LocaleController>(
      builder: (localeController) {
        return GetBuilder<ThemeController>(
          builder: (themeController) {
            return GetMaterialApp(
              navigatorKey: NavigationService.navigatorKey,
              title: 'app_title'.tr,
              debugShowCheckedModeBanner: false,
              locale: localeController.locale,
              fallbackLocale: const Locale('en'),
              translations: AppTranslations(),
              supportedLocales: AppTranslations.supportedLanguageCodes
                  .map((c) => Locale(c))
                  .toList(),
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              defaultTransition: Transition.cupertino,
              // Slightly longer than 300ms so named Get routes (splash, auth)
              // match the calmer feel of [AppNavigation] stack transitions.
              transitionDuration: const Duration(milliseconds: 480),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeController.themeMode,
              home: const SplashScreen(),
              getPages: [
                GetPage(
                  name: AppRoutes.welcome,
                  page: () => const WelcomeScreen(),
                ),
                GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
                GetPage(
                  name: AppRoutes.dashboard,
                  page: () => const DashboardScreen(selectedStudent: {}),
                ),
                GetPage(
                  name: AppRoutes.selectStudent,
                  page: () => const SelectStudentScreen(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
