// Response for `GET homework/{yyyy-MM-dd}` with optional cursor pagination.

class HomeworkListResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? meta;
  final List<HomeworkAssignment> data;
  final HomeworkPagination pagination;

  HomeworkListResponse({
    required this.success,
    required this.message,
    this.meta,
    required this.data,
    required this.pagination,
  });

  factory HomeworkListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <HomeworkAssignment>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(HomeworkAssignment.fromJson(e));
        }
      }
    }
    final pRaw = json['pagination'];
    return HomeworkListResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      meta: json['meta'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['meta'] as Map)
          : null,
      data: list,
      pagination: pRaw is Map<String, dynamic>
          ? HomeworkPagination.fromJson(pRaw)
          : HomeworkPagination.empty(),
    );
  }
}

class HomeworkPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  HomeworkPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory HomeworkPagination.empty() => HomeworkPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory HomeworkPagination.fromJson(Map<String, dynamic> json) {
    return HomeworkPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class HomeworkAssignment {
  final int id;
  final int assignmentStudentId;
  final String title;
  final String homework;
  final String? date;
  final String? homeworkDate;
  final String? submissionDate;
  final String description;
  final String? fileImage;
  final String? audioImage;
  final String? pdfImage;
  final String? video;
  final String? subject;
  final String createdBy;
  final String createdOn;
  final bool showUploadButton;
  final bool isSubmitted;
  final bool studentSubmitted;
  final String? formattedDate;
  final String? formattedHomeworkDate;
  final String? formattedSubmissionDate;
  final int studentViewId;
  final bool studentHasViewed;

  HomeworkAssignment({
    required this.id,
    required this.assignmentStudentId,
    required this.title,
    required this.homework,
    this.date,
    this.homeworkDate,
    this.submissionDate,
    required this.description,
    this.fileImage,
    this.audioImage,
    this.pdfImage,
    this.video,
    this.subject,
    required this.createdBy,
    required this.createdOn,
    required this.showUploadButton,
    required this.isSubmitted,
    required this.studentSubmitted,
    this.formattedDate,
    this.formattedHomeworkDate,
    this.formattedSubmissionDate,
    required this.studentViewId,
    required this.studentHasViewed,
  });

  factory HomeworkAssignment.fromJson(Map<String, dynamic> json) {
    return HomeworkAssignment(
      id: _asInt(json['id']),
      assignmentStudentId: _asInt(json['assignment_student_id']),
      title: json['title']?.toString() ?? '',
      homework: json['homework']?.toString() ?? '',
      date: json['date']?.toString(),
      homeworkDate: json['homework_date']?.toString(),
      submissionDate: json['submission_date']?.toString(),
      description: json['description']?.toString() ?? '',
      fileImage: json['file_image']?.toString(),
      audioImage: json['audio_image']?.toString(),
      pdfImage: json['pdf_image']?.toString(),
      video: json['video']?.toString(),
      subject: json['subject']?.toString(),
      createdBy: json['created_by']?.toString() ?? '',
      createdOn: json['created_on']?.toString() ?? '',
      showUploadButton: json['show_upload_button'] == true,
      isSubmitted: json['is_submitted'] == true,
      studentSubmitted: json['student_submitted'] == true,
      formattedDate: json['formatted_date']?.toString(),
      formattedHomeworkDate: json['formatted_homework_date']?.toString(),
      formattedSubmissionDate: json['formatted_submission_date']?.toString(),
      studentViewId: _asInt(json['student_view_id']),
      studentHasViewed: json['student_has_viewed'] == true,
    );
  }

  /// User-visible body: prefer homework, fall back to description.
  String get bodyText {
    final h = homework.trim();
    if (h.isNotEmpty) return h;
    return description.trim();
  }

  /// Short label for subject circle (e.g. ENG, MAT).
  String get subjectAbbrev {
    final s = subject?.trim();
    if (s != null && s.isNotEmpty) {
      final parts = s.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return s.length >= 3 ? s.substring(0, 3).toUpperCase() : s.toUpperCase();
    }
    final t = title.trim();
    if (t.length >= 3) return t.substring(0, 3).toUpperCase();
    return 'HW';
  }
}

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? fallback;
}
