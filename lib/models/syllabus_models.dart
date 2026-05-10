// Response for `GET syllabus?limit=&cursor=`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

class SyllabusApiResponse {
  final bool success;
  final String message;
  final List<SyllabusItem> data;
  final SyllabusPagination pagination;

  SyllabusApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory SyllabusApiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <SyllabusItem>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(SyllabusItem.fromJson(e));
        } else if (e is Map) {
          list.add(SyllabusItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final pRaw = json['pagination'];
    return SyllabusApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: list,
      pagination: pRaw is Map
          ? SyllabusPagination.fromJson(
              Map<String, dynamic>.from(pRaw),
            )
          : SyllabusPagination.empty(),
    );
  }
}

class SyllabusPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  SyllabusPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory SyllabusPagination.empty() => SyllabusPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory SyllabusPagination.fromJson(Map<String, dynamic> json) {
    return SyllabusPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class SyllabusUpload {
  final String fileImage;
  final String? audioImage;
  final String? pdfImage;
  final String video;

  SyllabusUpload({
    required this.fileImage,
    this.audioImage,
    this.pdfImage,
    required this.video,
  });

  factory SyllabusUpload.empty() => SyllabusUpload(
        fileImage: '',
        audioImage: null,
        pdfImage: null,
        video: '',
      );

  factory SyllabusUpload.fromJson(Map<String, dynamic> json) {
    String? opt(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return SyllabusUpload(
      fileImage: json['file_image']?.toString() ?? '',
      audioImage: opt(json['audio_image']),
      pdfImage: opt(json['pdf_image']),
      video: json['video']?.toString() ?? '',
    );
  }
}

class SyllabusItem {
  final int id;
  final String name;
  final String subjectName;
  final String className;
  final String examName;
  final String description;
  final String fileImages;
  final String? audioImage;
  final String? pdfImage;
  final String video;
  final String date;
  final String createdOn;
  final SyllabusUpload upload;

  SyllabusItem({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.className,
    required this.examName,
    required this.description,
    required this.fileImages,
    this.audioImage,
    this.pdfImage,
    required this.video,
    required this.date,
    required this.createdOn,
    required this.upload,
  });

  factory SyllabusItem.fromJson(Map<String, dynamic> json) {
    final upRaw = json['upload'];
    return SyllabusItem(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      subjectName: json['subject_name']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      examName: json['exam_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      fileImages: json['file_images']?.toString() ?? '',
      audioImage: () {
        final v = json['audio_image'];
        if (v == null) return null;
        final s = v.toString().trim();
        return s.isEmpty ? null : s;
      }(),
      pdfImage: () {
        final v = json['pdf_image'];
        if (v == null) return null;
        final s = v.toString().trim();
        return s.isEmpty ? null : s;
      }(),
      video: json['video']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      createdOn: json['created_on']?.toString() ?? '',
      upload: upRaw is Map<String, dynamic>
          ? SyllabusUpload.fromJson(upRaw)
          : upRaw is Map
              ? SyllabusUpload.fromJson(Map<String, dynamic>.from(upRaw))
              : SyllabusUpload.empty(),
    );
  }

  /// Prefer nested [upload] file, then top-level [fileImages].
  String get primaryFileUrl {
    final u = upload.fileImage.trim();
    if (u.isNotEmpty) return u;
    return fileImages.trim();
  }

  String? get primaryPdfUrl {
    final u = upload.pdfImage?.trim();
    if (u != null && u.isNotEmpty) return u;
    final t = pdfImage?.trim();
    if (t != null && t.isNotEmpty) return t;
    return null;
  }
}
