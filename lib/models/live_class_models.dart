int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

bool _asBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return fallback;
}

String? _optionalString(dynamic v) {
  if (v == null) return null;
  final t = v.toString().trim();
  return t.isEmpty ? null : t;
}

class LiveClassApiResponse {
  final bool success;
  final String message;
  final List<LiveClassItem> data;
  final LiveClassPagination pagination;
  final String? currentTime;
  final String? date;

  LiveClassApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
    this.currentTime,
    this.date,
  });

  factory LiveClassApiResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = <LiveClassItem>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(LiveClassItem.fromJson(e));
        } else if (e is Map) {
          list.add(LiveClassItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final pRaw = json['pagination'];
    return LiveClassApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: list,
      pagination: pRaw is Map
          ? LiveClassPagination.fromJson(Map<String, dynamic>.from(pRaw))
          : LiveClassPagination.empty(),
      currentTime: _optionalString(json['current_time']),
      date: _optionalString(json['date']),
    );
  }

  factory LiveClassApiResponse.failure(String message) => LiveClassApiResponse(
        success: false,
        message: message,
        data: const [],
        pagination: LiveClassPagination.empty(),
      );
}

class LiveClassPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  LiveClassPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory LiveClassPagination.empty() => LiveClassPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory LiveClassPagination.fromJson(Map<String, dynamic> json) {
    return LiveClassPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: _optionalString(json['next_cursor']),
      hasNextPage: _asBool(json['has_next_page']),
      hasPrevPage: _asBool(json['has_prev_page']),
    );
  }
}

class LiveClassItem {
  final int id;
  final String name;
  final String description;
  final String heading;
  final String subjectName;
  final String classSectionName;
  final String? startTime;
  final int duration;
  final String? endTime;
  final String? link;
  final bool joinNow;
  final bool isLive;

  LiveClassItem({
    required this.id,
    required this.name,
    required this.description,
    required this.heading,
    required this.subjectName,
    required this.classSectionName,
    this.startTime,
    required this.duration,
    this.endTime,
    this.link,
    required this.joinNow,
    required this.isLive,
  });

  factory LiveClassItem.fromJson(Map<String, dynamic> json) {
    return LiveClassItem(
      id: _asInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      heading: json['heading']?.toString().trim() ?? '',
      subjectName: json['subject_name']?.toString().trim() ?? '',
      classSectionName: json['class_section_name']?.toString().trim() ?? '',
      startTime: _optionalString(json['start_time']),
      duration: _asInt(json['duration']),
      endTime: _optionalString(json['end_time']),
      link: _optionalString(json['link']),
      joinNow: _asBool(json['join_now']),
      isLive: _asBool(json['is_live']),
    );
  }
}
