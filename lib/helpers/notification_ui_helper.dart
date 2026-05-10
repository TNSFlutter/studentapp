import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/recent_notifications_models.dart';

(DateTime? date, String relativeLabel) notificationTime(String sendDateIso) {
  final d = DateTime.tryParse(sendDateIso)?.toLocal();
  if (d == null) return (null, '');
  return (d, timeago.format(d, locale: 'en'));
}

/// Relative time for UI; falls back to a short ISO snippet if parsing fails.
String notificationTimeLabel(String sendDateIso) {
  final (d, t) = notificationTime(sendDateIso);
  if (t.isNotEmpty) return t;
  if (sendDateIso.length >= 10) return sendDateIso.substring(0, 10);
  return '';
}

IconData notificationIcon(IconHint hint) {
  switch (hint) {
    case IconHint.results:
      return Icons.assignment_turned_in_rounded;
    case IconHint.attendance:
      return Icons.calendar_month_rounded;
    case IconHint.homework:
      return Icons.menu_book_rounded;
    case IconHint.fees:
      return Icons.payments_outlined;
    case IconHint.general:
      return Icons.notifications_none_rounded;
  }
}

(Color bg, Color fg) notificationAccent(IconHint hint) {
  switch (hint) {
    case IconHint.results:
      return (const Color(0xFFEEF2FF), const Color(0xFF4338CA));
    case IconHint.attendance:
      return (const Color(0xFFFFE8EB), const Color(0xFFE11D48));
    case IconHint.homework:
      return (const Color(0xFFE8F4FD), const Color(0xFF2563EB));
    case IconHint.fees:
      return (const Color(0xFFFFF9E6), const Color(0xFFD97706));
    case IconHint.general:
      return (const Color(0xFFFFF9E6), const Color(0xFFD97706));
  }
}

bool isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
