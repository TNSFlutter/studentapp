import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Localized greeting from current time: morning / afternoon / evening.
String timeOfDayGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'greeting_morning'.tr;
  if (hour < 17) return 'greeting_afternoon'.tr;
  return 'greeting_evening'.tr;
}

class DateTimeHelper {
  // Standard date format for display: dd/mm/yyyy
  static const String standardDateFormat = "dd/MM/yyyy";

  // API date format: yyyy-MM-dd (for backend compatibility)
  static const String apiDateFormat = "yyyy-MM-dd";

  // Long formats for timestamps
  static const String longFormat = "yyyy-MM-dd'T'HH:mm:ss";
  static const String longTimeFormat = "yyyy-MM-dd HH:mm:ssZ";
  static const String longFormatWithTZ = "yyyy-MM-dd'T'HH:mm:ss+0000";

  /// Format date in standard dd/mm/yyyy format
  static String formatStandardDate(DateTime dateTime) {
    return DateFormat(standardDateFormat).format(dateTime);
  }

  /// Format date for API calls (yyyy-MM-dd)
  static String formatDateForApi(DateTime dateTime) {
    return DateFormat(apiDateFormat).format(dateTime);
  }

  /// Format date with custom format
  static String stringFromDate(
    DateTime dateTime, {
    String format = standardDateFormat,
  }) {
    return DateFormat(format).format(dateTime);
  }

  /// Format date for API (backward compatibility)
  static String dateForApi(DateTime dateTime, {String format = apiDateFormat}) {
    return DateFormat(format).format(dateTime);
  }

  /// Get present time string
  static String getPresentTimeString({
    String format = longFormat,
    bool local = false,
  }) {
    return stringFromDate(
      local ? DateTime.now().toLocal() : DateTime.now().toUtc(),
      format: format,
    );
  }

  /// Change string date format
  static String changeStringDateFormat(
    String dateStr, {
    String inDateFormat = longTimeFormat,
    outDateFormat = standardDateFormat,
  }) {
    DateTime inDate = dateFromString(dateStr, format: inDateFormat);
    return stringFromDate(inDate, format: outDateFormat);
  }

  /// Parse date string
  static DateTime dateFromString(
    String dateString, {
    String format = "yyyy-MM-dd HH:mm:ssZ",
  }) {
    return DateFormat(format).parse(dateString);
  }

  /// Get relative display time
  static String getRelativeDisplayTime(String dateStr) {
    DateTime date = dateFromString(dateStr);
    DateTime date2 = DateTime.now().subtract(Duration(hours: 5, minutes: 30));

    var diff = date2.difference(date).inDays;
    if (diff > 1) {
      return DateTimeHelper.changeStringDateFormat(dateStr);
    } else if (diff == 1) {
      return "Yesterday";
    }

    return timeago.format(date, clock: date2);
  }

  /// Format date in dd/mm/yyyy format from string
  static String formatDateString(
    String dateString, {
    String inputFormat = "yyyy-MM-dd",
  }) {
    try {
      DateTime date = dateFromString(dateString, format: inputFormat);
      return formatStandardDate(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }
}
