// Response for `GET results/exam?limit=&cursor=`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

double _asDouble(dynamic v, {double fallback = 0}) {
  if (v == null) return fallback;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

num _asNum(dynamic v, {num fallback = 0}) {
  if (v == null) return fallback;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? fallback;
}

class ExamResultsApiResponse {
  final bool success;
  final String message;
  final ExamResultsData? data;
  final ExamResultsPagination pagination;

  ExamResultsApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.pagination,
  });

  factory ExamResultsApiResponse.fromJson(Map<String, dynamic> json) {
    final dRaw = json['data'];
    final pRaw = json['pagination'];
    return ExamResultsApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dRaw is Map
          ? ExamResultsData.fromJson(Map<String, dynamic>.from(dRaw))
          : null,
      pagination: pRaw is Map
          ? ExamResultsPagination.fromJson(Map<String, dynamic>.from(pRaw))
          : ExamResultsPagination.empty(),
    );
  }
}

class ExamResultsPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  ExamResultsPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory ExamResultsPagination.empty() => ExamResultsPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory ExamResultsPagination.fromJson(Map<String, dynamic> json) {
    return ExamResultsPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class ExamResultsStudent {
  final int studentId;
  final String name;
  final String classSection;

  ExamResultsStudent({
    required this.studentId,
    required this.name,
    required this.classSection,
  });

  factory ExamResultsStudent.fromJson(Map<String, dynamic> json) {
    return ExamResultsStudent(
      studentId: _asInt(json['student_id']),
      name: json['name']?.toString() ?? '',
      classSection: json['class_section']?.toString() ?? '',
    );
  }
}

/// Summary on `today` / `previous` wrapper (totals across exams or day).
class ExamResultsListSummary {
  final int totalExams;
  final int totalSubjects;
  final num totalMarks;
  final num obtainedMarks;
  final double overallPercentage;

  ExamResultsListSummary({
    required this.totalExams,
    required this.totalSubjects,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.overallPercentage,
  });

  factory ExamResultsListSummary.fromJson(Map<String, dynamic> json) {
    return ExamResultsListSummary(
      totalExams: _asInt(json['total_exams']),
      totalSubjects: _asInt(json['total_subjects']),
      totalMarks: _asNum(json['total_marks']),
      obtainedMarks: _asNum(json['obtained_marks']),
      overallPercentage: _asDouble(json['overall_percentage']),
    );
  }

  factory ExamResultsListSummary.empty() => ExamResultsListSummary(
        totalExams: 0,
        totalSubjects: 0,
        totalMarks: 0,
        obtainedMarks: 0,
        overallPercentage: 0,
      );
}

class ExamExamType {
  final int id;
  final String name;
  final String? description;

  ExamExamType({
    required this.id,
    required this.name,
    this.description,
  });

  factory ExamExamType.fromJson(Map<String, dynamic> json) {
    return ExamExamType(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
    );
  }

  factory ExamExamType.empty() => ExamExamType(id: 0, name: '');
}

class ExamSubjectRef {
  final int id;
  final String name;
  final String shortName;

  ExamSubjectRef({
    required this.id,
    required this.name,
    required this.shortName,
  });

  factory ExamSubjectRef.fromJson(Map<String, dynamic> json) {
    return ExamSubjectRef(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      shortName: json['short_name']?.toString() ?? '',
    );
  }

  factory ExamSubjectRef.empty() => ExamSubjectRef(id: 0, name: '', shortName: '');
}

class ExamChildSubjectRef {
  final int id;
  final String name;
  final String? shortName;

  ExamChildSubjectRef({
    required this.id,
    required this.name,
    this.shortName,
  });

  factory ExamChildSubjectRef.fromJson(Map<String, dynamic> json) {
    return ExamChildSubjectRef(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      shortName: json['short_name']?.toString(),
    );
  }
}

class ExamChildSubjectResult {
  final int id;
  final ExamChildSubjectRef childSubject;
  final int maxMarks;
  final String? obtainedMarks;
  final String marksStatus;
  final double percentage;
  final bool isAbsent;
  final bool isNa;

  ExamChildSubjectResult({
    required this.id,
    required this.childSubject,
    required this.maxMarks,
    this.obtainedMarks,
    required this.marksStatus,
    required this.percentage,
    required this.isAbsent,
    required this.isNa,
  });

  factory ExamChildSubjectResult.fromJson(Map<String, dynamic> json) {
    final cs = json['child_subject'];
    return ExamChildSubjectResult(
      id: _asInt(json['id']),
      childSubject: cs is Map
          ? ExamChildSubjectRef.fromJson(Map<String, dynamic>.from(cs))
          : ExamChildSubjectRef(id: 0, name: ''),
      maxMarks: _asInt(json['max_marks']),
      obtainedMarks: json['obtained_marks']?.toString(),
      marksStatus: json['marks_status']?.toString() ?? '',
      percentage: _asDouble(json['percentage']),
      isAbsent: json['is_absent'] == true,
      isNa: json['is_na'] == true,
    );
  }
}

class ExamSubjectResult {
  final int id;
  final int examinationScheduleId;
  final ExamSubjectRef subject;
  final int maxMarks;
  final String? obtainedMarksRaw;
  final String marksStatus;
  final double percentage;
  final int? grade;
  final String? gradeName;
  final bool isGradeOnly;
  final List<ExamChildSubjectResult> childResults;
  final String formattedCreatedOn;
  final bool isAbsent;
  final bool isNa;

  ExamSubjectResult({
    required this.id,
    required this.examinationScheduleId,
    required this.subject,
    required this.maxMarks,
    this.obtainedMarksRaw,
    required this.marksStatus,
    required this.percentage,
    this.grade,
    this.gradeName,
    required this.isGradeOnly,
    required this.childResults,
    required this.formattedCreatedOn,
    required this.isAbsent,
    required this.isNa,
  });

  factory ExamSubjectResult.fromJson(Map<String, dynamic> json) {
    final subRaw = json['subject'];
    final rawChildren = json['exam_child_subject_results'];
    final children = <ExamChildSubjectResult>[];
    if (rawChildren is List) {
      for (final e in rawChildren) {
        if (e is Map<String, dynamic>) {
          children.add(ExamChildSubjectResult.fromJson(e));
        } else if (e is Map) {
          children.add(
            ExamChildSubjectResult.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    final om = json['obtained_marks'];
    return ExamSubjectResult(
      id: _asInt(json['id']),
      examinationScheduleId: _asInt(json['examination_schedule_id']),
      subject: subRaw is Map
          ? ExamSubjectRef.fromJson(Map<String, dynamic>.from(subRaw))
          : ExamSubjectRef.empty(),
      maxMarks: _asInt(json['max_marks']),
      obtainedMarksRaw: om?.toString(),
      marksStatus: json['marks_status']?.toString() ?? '',
      percentage: _asDouble(json['percentage']),
      grade: json['grade'] == null ? null : _asInt(json['grade']),
      gradeName: json['grade_name']?.toString(),
      isGradeOnly: json['is_grade_only'] == true,
      childResults: children,
      formattedCreatedOn: json['formatted_created_on']?.toString() ?? '',
      isAbsent: json['is_absent'] == true,
      isNa: json['is_na'] == true,
    );
  }

  String displayObtained() {
    if (isNa) return 'N/A';
    if (isAbsent) return 'AB';
    if (isGradeOnly && gradeName != null && gradeName!.trim().isNotEmpty) {
      return gradeName!.trim();
    }
    if (obtainedMarksRaw != null && obtainedMarksRaw!.trim().isNotEmpty) {
      return obtainedMarksRaw!.trim();
    }
    return '—';
  }
}

/// Per-exam aggregate (inside each exam card).
class ExamSessionSummary {
  final int totalSubjects;
  final int presentSubjects;
  final int absentSubjects;
  final int naSubjects;
  final num totalMarks;
  final num obtainedMarks;
  final double overallPercentage;

  ExamSessionSummary({
    required this.totalSubjects,
    required this.presentSubjects,
    required this.absentSubjects,
    required this.naSubjects,
    required this.totalMarks,
    required this.obtainedMarks,
    required this.overallPercentage,
  });

  factory ExamSessionSummary.fromJson(Map<String, dynamic> json) {
    return ExamSessionSummary(
      totalSubjects: _asInt(json['total_subjects']),
      presentSubjects: _asInt(json['present_subjects']),
      absentSubjects: _asInt(json['absent_subjects']),
      naSubjects: _asInt(json['na_subjects']),
      totalMarks: _asNum(json['total_marks']),
      obtainedMarks: _asNum(json['obtained_marks']),
      overallPercentage: _asDouble(json['overall_percentage']),
    );
  }

  factory ExamSessionSummary.empty() => ExamSessionSummary(
        totalSubjects: 0,
        presentSubjects: 0,
        absentSubjects: 0,
        naSubjects: 0,
        totalMarks: 0,
        obtainedMarks: 0,
        overallPercentage: 0,
      );
}

class ExamSession {
  final String examName;
  final ExamExamType examType;
  final String examStartDate;
  final String examEndDate;
  final String formattedStartDate;
  final String formattedEndDate;
  final String classSection;
  final String studentName;
  final List<ExamSubjectResult> subjects;
  final ExamSessionSummary summary;

  ExamSession({
    required this.examName,
    required this.examType,
    required this.examStartDate,
    required this.examEndDate,
    required this.formattedStartDate,
    required this.formattedEndDate,
    required this.classSection,
    required this.studentName,
    required this.subjects,
    required this.summary,
  });

  String get dedupeKey => '$examName|$examStartDate|$examEndDate';

  factory ExamSession.fromJson(Map<String, dynamic> json) {
    final typeRaw = json['exam_type'];
    final subjRaw = json['subjects'];
    final subjects = <ExamSubjectResult>[];
    if (subjRaw is List) {
      for (final e in subjRaw) {
        if (e is Map<String, dynamic>) {
          subjects.add(ExamSubjectResult.fromJson(e));
        } else if (e is Map) {
          subjects.add(ExamSubjectResult.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final sumRaw = json['summary'];
    return ExamSession(
      examName: json['exam_name']?.toString() ?? '',
      examType: typeRaw is Map
          ? ExamExamType.fromJson(Map<String, dynamic>.from(typeRaw))
          : ExamExamType.empty(),
      examStartDate: json['exam_start_date']?.toString() ?? '',
      examEndDate: json['exam_end_date']?.toString() ?? '',
      formattedStartDate: json['formatted_start_date']?.toString() ?? '',
      formattedEndDate: json['formatted_end_date']?.toString() ?? '',
      classSection: json['class_section']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      subjects: subjects,
      summary: sumRaw is Map
          ? ExamSessionSummary.fromJson(Map<String, dynamic>.from(sumRaw))
          : ExamSessionSummary.empty(),
    );
  }
}

class ExamResultsPeriodBlock {
  final List<ExamSession> exams;
  final ExamResultsListSummary summary;

  ExamResultsPeriodBlock({
    required this.exams,
    required this.summary,
  });

  factory ExamResultsPeriodBlock.fromJson(Map<String, dynamic> json) {
    final rawExams = json['exams'];
    final list = <ExamSession>[];
    if (rawExams is List) {
      for (final e in rawExams) {
        if (e is Map<String, dynamic>) {
          list.add(ExamSession.fromJson(e));
        } else if (e is Map) {
          list.add(ExamSession.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final sRaw = json['summary'];
    return ExamResultsPeriodBlock(
      exams: list,
      summary: sRaw is Map
          ? ExamResultsListSummary.fromJson(Map<String, dynamic>.from(sRaw))
          : ExamResultsListSummary.empty(),
    );
  }

  factory ExamResultsPeriodBlock.empty() => ExamResultsPeriodBlock(
        exams: [],
        summary: ExamResultsListSummary.empty(),
      );
}

class ExamResultsData {
  final ExamResultsStudent? student;
  final ExamResultsPeriodBlock today;
  final ExamResultsPeriodBlock previous;

  ExamResultsData({
    this.student,
    required this.today,
    required this.previous,
  });

  factory ExamResultsData.fromJson(Map<String, dynamic> json) {
    final tRaw = json['today'];
    final pRaw = json['previous'];
    final stRaw = json['student'];
    return ExamResultsData(
      student: stRaw is Map
          ? ExamResultsStudent.fromJson(Map<String, dynamic>.from(stRaw))
          : null,
      today: tRaw is Map
          ? ExamResultsPeriodBlock.fromJson(Map<String, dynamic>.from(tRaw))
          : ExamResultsPeriodBlock.empty(),
      previous: pRaw is Map
          ? ExamResultsPeriodBlock.fromJson(Map<String, dynamic>.from(pRaw))
          : ExamResultsPeriodBlock.empty(),
    );
  }
}
