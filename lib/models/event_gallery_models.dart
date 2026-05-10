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

class EventGalleryApiResponse {
  final bool success;
  final String message;
  final List<EventGalleryItem> data;
  final EventGalleryPagination pagination;

  EventGalleryApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory EventGalleryApiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <EventGalleryItem>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(EventGalleryItem.fromJson(e));
        } else if (e is Map) {
          list.add(EventGalleryItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    final pRaw = json['pagination'];
    return EventGalleryApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: list,
      pagination: pRaw is Map
          ? EventGalleryPagination.fromJson(Map<String, dynamic>.from(pRaw))
          : EventGalleryPagination.empty(),
    );
  }

  factory EventGalleryApiResponse.failure(String message) =>
      EventGalleryApiResponse(
        success: false,
        message: message,
        data: const [],
        pagination: EventGalleryPagination.empty(),
      );
}

class EventGalleryPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  EventGalleryPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory EventGalleryPagination.empty() => EventGalleryPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory EventGalleryPagination.fromJson(Map<String, dynamic> json) {
    return EventGalleryPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: _optionalString(json['next_cursor']),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class EventGalleryItem {
  final int id;
  final String name;
  final String? description;
  final String? eventDate;
  final int totalImages;
  final List<EventGalleryImageItem> images;

  EventGalleryItem({
    required this.id,
    required this.name,
    this.description,
    this.eventDate,
    required this.totalImages,
    required this.images,
  });

  factory EventGalleryItem.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    final imgs = <EventGalleryImageItem>[];
    if (rawImages is List) {
      for (final e in rawImages) {
        if (e is Map<String, dynamic>) {
          imgs.add(EventGalleryImageItem.fromJson(e));
        } else if (e is Map) {
          imgs.add(EventGalleryImageItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    return EventGalleryItem(
      id: _asInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      description: _optionalString(json['description']),
      eventDate: _optionalString(json['event_date']),
      totalImages: _asInt(json['total_images'], fallback: imgs.length),
      images: imgs,
    );
  }

  String? get coverImage {
    for (final img in images) {
      final u = img.fileImage?.trim() ?? '';
      if (u.isNotEmpty) return u;
    }
    return null;
  }
}

class EventGalleryImageItem {
  final int id;
  final String? fileImage;

  EventGalleryImageItem({required this.id, this.fileImage});

  factory EventGalleryImageItem.fromJson(Map<String, dynamic> json) {
    return EventGalleryImageItem(
      id: _asInt(json['id']),
      fileImage: _optionalString(json['file_image']),
    );
  }
}
