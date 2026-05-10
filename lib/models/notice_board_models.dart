// Response for `GET notice?limit=&cursor=`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

String? _optionalString(dynamic v) {
  if (v == null) return null;
  final t = v.toString().trim();
  return t.isEmpty ? null : t;
}

class NoticeBoardApiResponse {
  final bool success;
  final String message;
  final List<NoticeItem> data;
  final NoticePagination pagination;
  final NoticeFilters? filters;

  NoticeBoardApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
    this.filters,
  });

  factory NoticeBoardApiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <NoticeItem>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(NoticeItem.fromJson(e));
        } else if (e is Map) {
          list.add(NoticeItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final pRaw = json['pagination'];
    final fRaw = json['filters'];
    return NoticeBoardApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: list,
      pagination: pRaw is Map
          ? NoticePagination.fromJson(Map<String, dynamic>.from(pRaw))
          : NoticePagination.empty(),
      filters: fRaw is Map
          ? NoticeFilters.fromJson(Map<String, dynamic>.from(fRaw))
          : null,
    );
  }

  factory NoticeBoardApiResponse.failure(String message) =>
      NoticeBoardApiResponse(
        success: false,
        message: message,
        data: const [],
        pagination: NoticePagination.empty(),
        filters: null,
      );
}

class NoticePagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  NoticePagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory NoticePagination.empty() => NoticePagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory NoticePagination.fromJson(Map<String, dynamic> json) {
    return NoticePagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: _optionalString(json['next_cursor']),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class NoticeFilters {
  final String? date;
  final String? currentTime;

  NoticeFilters({this.date, this.currentTime});

  factory NoticeFilters.fromJson(Map<String, dynamic> json) {
    return NoticeFilters(
      date: _optionalString(json['date']),
      currentTime: _optionalString(json['current_time']),
    );
  }
}

class NoticeItem {
  final int id;
  final String name;
  final String? description;
  final String? fileImage;
  final String? audioImage;
  final String? video;
  final String? pdfImage;
  final String? link;
  final String? navigate;
  final int sortOrder;
  final String createdOn;
  final String updatedOn;
  final String? createdBy;
  final String? updatedBy;

  NoticeItem({
    required this.id,
    required this.name,
    this.description,
    this.fileImage,
    this.audioImage,
    this.video,
    this.pdfImage,
    this.link,
    this.navigate,
    required this.sortOrder,
    required this.createdOn,
    required this.updatedOn,
    this.createdBy,
    this.updatedBy,
  });

  factory NoticeItem.fromJson(Map<String, dynamic> json) {
    return NoticeItem(
      id: _asInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      description: _optionalString(json['description']),
      fileImage: _optionalString(json['file_image']),
      audioImage: _optionalString(json['audio_image']),
      video: _optionalString(json['video']),
      pdfImage: _optionalString(json['pdf_image']),
      link: _optionalString(json['link']),
      navigate: _optionalString(json['navigate']),
      sortOrder: _asInt(json['sort_order']),
      createdOn: json['created_on']?.toString() ?? '',
      updatedOn: json['updated_on']?.toString() ?? '',
      createdBy: _optionalString(json['created_by']),
      updatedBy: _optionalString(json['updated_by']),
    );
  }

  /// First usable attachment URL for list thumbnail / primary open action.
  String? get primaryMediaUrl {
    if (fileImage != null && fileImage!.isNotEmpty) return fileImage;
    if (pdfImage != null && pdfImage!.isNotEmpty) return pdfImage;
    if (video != null && video!.isNotEmpty) return video;
    if (audioImage != null && audioImage!.isNotEmpty) return audioImage;
    return null;
  }
}
