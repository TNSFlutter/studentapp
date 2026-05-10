import 'package:get/get.dart';
import 'package:studentapp/controllers/auth_controller.dart';
import 'package:studentapp/helpers/status_helper.dart';

class AppManager {
  static StatusHelper statusHelper = StatusHelper();
  static AuthController get authController => Get.find<AuthController>();
}
