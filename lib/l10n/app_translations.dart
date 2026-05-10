import 'package:get/get.dart';

import 'translations/app_strings_as.dart';
import 'translations/app_strings_bn.dart';
import 'translations/app_strings_en.dart';
import 'translations/app_strings_gu.dart';
import 'translations/app_strings_hi.dart';
import 'translations/app_strings_kn.dart';
import 'translations/app_strings_ml.dart';
import 'translations/app_strings_mr.dart';
import 'translations/app_strings_or.dart';
import 'translations/app_strings_pa.dart';
import 'translations/app_strings_ta.dart';
import 'translations/app_strings_te.dart';
import 'translations/app_strings_ur.dart';

/// GetX translations for supported Indian languages.
///
/// **English** (`app_strings_en.dart`) and **Hindi** (`app_strings_hi.dart`) each
/// define the **same keys** (full app coverage). Keep them in sync when adding
/// new `.tr` keys.
///
/// **Regional** locales each use a **full map** (e.g. `app_strings_bn.dart`): every
/// key matches English/Hindi coverage so **all static UI** is in that language.
/// Regenerate from English via `tool/generate_regional_l10n.py` when adding keys;
/// machine translations should be reviewed for school-facing copy.
class AppTranslations extends Translations {
  static const supportedLanguageCodes = <String>[
    'en',
    'hi',
    'bn',
    'pa',
    'te',
    'or',
    'mr',
    'gu',
    'kn',
    'ur',
    'ml',
    'ta',
    'as',
  ];

  static String displayNameForCode(String code) {
    const m = {
      'en': 'English',
      'hi': 'Hindi',
      'bn': 'Bengali',
      'pa': 'Punjabi',
      'te': 'Telugu',
      'or': 'Odia',
      'mr': 'Marathi',
      'gu': 'Gujarati',
      'kn': 'Kannada',
      'ur': 'Urdu',
      'ml': 'Malayalam',
      'ta': 'Tamil',
      'as': 'Assamese',
    };
    return m[code] ?? code;
  }

  @override
  Map<String, Map<String, String>> get keys => {
        'en': appStringsEn,
        'hi': {...appStringsEn, ...appStringsHi},
        'bn': appStringsBn,
        'pa': appStringsPa,
        'te': appStringsTe,
        'or': appStringsOr,
        'mr': appStringsMr,
        'gu': appStringsGu,
        'kn': appStringsKn,
        'ur': appStringsUr,
        'ml': appStringsMl,
        'ta': appStringsTa,
        'as': appStringsAs,
      };
}
