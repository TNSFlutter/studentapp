// Outputs JSON of [appStringsEn] for tooling (regional l10n generation).
import 'dart:convert';
import 'dart:io';

import 'package:studentapp/l10n/translations/app_strings_en.dart';

void main() {
  stdout.writeln(jsonEncode(appStringsEn));
}
