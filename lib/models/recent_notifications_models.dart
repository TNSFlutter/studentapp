class RecentNotificationsApiResponse {
  final bool success;
  final String message;
  final List<StudentNotificationItem> data;
  final NotificationsPagination pagination;

  RecentNotificationsApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory RecentNotificationsApiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <StudentNotificationItem>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(StudentNotificationItem.fromJson(e));
        }
      }
    }
    final pRaw = json['pagination'];
    return RecentNotificationsApiResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: list,
      pagination: pRaw is Map<String, dynamic>
          ? NotificationsPagination.fromJson(pRaw)
          : NotificationsPagination.empty(),
    );
  }
}

class NotificationsPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  NotificationsPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory NotificationsPagination.empty() => NotificationsPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory NotificationsPagination.fromJson(Map<String, dynamic> json) {
    return NotificationsPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class StudentNotificationItem {
  final int id;
  final String? subject;
  final String message;
  final String sendDate;
  final int notificationType;
  final int classSectionId;
  final String createdBy;
  final String? fileImage;
  final NotificationMessageType messageType;
  final int studentId;
  final String studentIdsCsv;

  StudentNotificationItem({
    required this.id,
    this.subject,
    required this.message,
    required this.sendDate,
    required this.notificationType,
    required this.classSectionId,
    required this.createdBy,
    this.fileImage,
    required this.messageType,
    required this.studentId,
    required this.studentIdsCsv,
  });

  factory StudentNotificationItem.fromJson(Map<String, dynamic> json) {
    final mtRaw = json['message_type'];
    return StudentNotificationItem(
      id: _asInt(json['id']),
      subject: json['subject']?.toString(),
      message: json['message']?.toString() ?? '',
      sendDate: json['send_date']?.toString() ?? '',
      notificationType: _asInt(json['notification_type']),
      classSectionId: _asInt(json['class_section_id']),
      createdBy: json['created_by']?.toString() ?? '',
      fileImage: json['file_image']?.toString(),
      messageType: mtRaw is Map<String, dynamic>
          ? NotificationMessageType.fromJson(mtRaw)
          : NotificationMessageType.empty(),
      studentId: _asInt(json['student_id']),
      studentIdsCsv: json['student_ids_csv']?.toString() ?? '',
    );
  }

  /// Title shown in cards / rows.
  String get displayTitle {
    final s = subject?.trim();
    if (s != null && s.isNotEmpty) return s;
    final n = messageType.name?.trim();
    if (n != null && n.isNotEmpty) return n;
    return 'Notification';
  }

  /// Short description for compact rows (single line friendly).
  String bodyPreview({int maxChars = 140}) {
    final text = message
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join(' ');
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars)}…';
  }

  IconHint get iconHint {
    final combined =
        '${messageType.name ?? ''} ${subject ?? ''} $message'.toLowerCase();
    if (combined.contains('result') || combined.contains('exam')) {
      return IconHint.results;
    }
    if (combined.contains('attend')) return IconHint.attendance;
    if (combined.contains('homework') || combined.contains('home work')) {
      return IconHint.homework;
    }
    if (combined.contains('fee')) return IconHint.fees;
    return IconHint.general;
  }
}

enum IconHint { general, results, attendance, homework, fees }

class NotificationMessageType {
  final int id;
  final String? name;

  NotificationMessageType({required this.id, this.name});

  factory NotificationMessageType.empty() =>
      NotificationMessageType(id: 0, name: null);

  factory NotificationMessageType.fromJson(Map<String, dynamic> json) {
    return NotificationMessageType(
      id: _asInt(json['id']),
      name: json['name']?.toString(),
    );
  }
}

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? fallback;
}
