import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../constants/string_constants.dart';

/// Persists selected app language and drives GetX locale updates.
class LocaleController extends GetxController {
  final GetStorage _storage = GetStorage();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  @override
  void onInit() {
    super.onInit();
    final code = _storage.read<String>(Constants.appLanguageCode);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
    Intl.defaultLocale = _locale.languageCode;
    Get.updateLocale(_locale);
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    await _storage.write(Constants.appLanguageCode, languageCode);
    Intl.defaultLocale = languageCode;
    Get.updateLocale(_locale);
    update();
  }
}
