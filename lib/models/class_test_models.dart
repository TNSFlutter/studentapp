// Response for `GET results/class-test?limit=&cursor=`

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

class ClassTestResultsResponse {
  final bool success;
  final String message;
  final ClassTestResultsData? data;
  final ClassTestPagination pagination;

  ClassTestResultsResponse({
    required this.success,
    required this.message,
    this.data,
    required this.pagination,
  });

  factory ClassTestResultsResponse.fromJson(Map<String, dynamic> json) {
    final dRaw = json['data'];
    final pRaw = json['pagination'];
    return ClassTestResultsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dRaw is Map
          ? ClassTestResultsData.fromJson(
              Map<String, dynamic>.from(dRaw),
            )
          : null,
      pagination: pRaw is Map
          ? ClassTestPagination.fromJson(
              Map<String, dynamic>.from(pRaw),
            )
          : ClassTestPagination.empty(),
    );
  }
}

class ClassTestPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  ClassTestPagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory ClassTestPagination.empty() => ClassTestPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory ClassTestPagination.fromJson(Map<String, dynamic> json) {
    return ClassTestPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class ClassTestStudent {
  final int studentId;
  final String name;
  final String classSection;

  ClassTestStudent({
    required this.studentId,
    required this.name,
    required this.classSection,
  });

  factory ClassTestStudent.fromJson(Map<String, dynamic> json) {
    return ClassTestStudent(
      studentId: _asInt(json['student_id']),
      name: json['name']?.toString() ?? '',
      classSection: json['class_section']?.toString() ?? '',
    );
  }
}

class ClassTestSummary {
  final int totalTests;
  final int presentTests;
  final int absentTests;
  final int naTests;

  ClassTestSummary({
    required this.totalTests,
    required this.presentTests,
    required this.absentTests,
    required this.naTests,
  });

  factory ClassTestSummary.fromJson(Map<String, dynamic> json) {
    return ClassTestSummary(
      totalTests: _asInt(json['total_tests']),
      presentTests: _asInt(json['present_tests']),
      absentTests: _asInt(json['absent_tests']),
      naTests: _asInt(json['na_tests']),
    );
  }

  factory ClassTestSummary.empty() => ClassTestSummary(
        totalTests: 0,
        presentTests: 0,
        absentTests: 0,
        naTests: 0,
      );
}

class ClassTestSubject {
  final int id;
  final String name;
  final String shortName;

  ClassTestSubject({
    required this.id,
    required this.name,
    required this.shortName,
  });

  factory ClassTestSubject.fromJson(Map<String, dynamic> json) {
    return ClassTestSubject(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      shortName: json['short_name']?.toString() ?? '',
    );
  }

  factory ClassTestSubject.empty() =>
      ClassTestSubject(id: 0, name: '', shortName: '');
}

class ClassTestResult {
  final int id;
  final int classTestId;
  final String classTestName;
  final ClassTestSubject subject;
  final String testDate;
  final int maxMarks;
  final String obtainedMarks;
  final String marksStatus;
  final double percentage;
  final String? grade;
  final String? description;
  final String createdOn;
  final String formattedTestDate;
  final String formattedCreatedOn;
  final String classSection;
  final String studentName;
  final bool isAbsent;
  final bool isNa;

  ClassTestResult({
    required this.id,
    required this.classTestId,
    required this.classTestName,
    required this.subject,
    required this.testDate,
    required this.maxMarks,
    required this.obtainedMarks,
    required this.marksStatus,
    required this.percentage,
    this.grade,
    this.description,
    required this.createdOn,
    required this.formattedTestDate,
    required this.formattedCreatedOn,
    required this.classSection,
    required this.studentName,
    required this.isAbsent,
    required this.isNa,
  });

  factory ClassTestResult.fromJson(Map<String, dynamic> json) {
    final subRaw = json['subject'];
    return ClassTestResult(
      id: _asInt(json['id']),
      classTestId: _asInt(json['class_test_id']),
      classTestName: json['class_test_name']?.toString() ?? '',
      subject: subRaw is Map<String, dynamic>
          ? ClassTestSubject.fromJson(subRaw)
          : subRaw is Map
              ? ClassTestSubject.fromJson(
                  Map<String, dynamic>.from(subRaw),
                )
              : ClassTestSubject.empty(),
      testDate: json['test_date']?.toString() ?? '',
      maxMarks: _asInt(json['max_marks']),
      obtainedMarks: json['obtained_marks']?.toString() ?? '',
      marksStatus: json['marks_status']?.toString() ?? '',
      percentage: _asDouble(json['percentage']),
      grade: json['grade']?.toString(),
      description: json['description']?.toString(),
      createdOn: json['created_on']?.toString() ?? '',
      formattedTestDate: json['formatted_test_date']?.toString() ?? '',
      formattedCreatedOn: json['formatted_created_on']?.toString() ?? '',
      classSection: json['class_section']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      isAbsent: json['is_absent'] == true,
      isNa: json['is_na'] == true,
    );
  }
}

class ClassTestPeriodBlock {
  final List<ClassTestResult> results;
  final ClassTestSummary summary;

  ClassTestPeriodBlock({
    required this.results,
    required this.summary,
  });

  factory ClassTestPeriodBlock.fromJson(Map<String, dynamic> json) {
    final rawList = json['results'];
    final list = <ClassTestResult>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(ClassTestResult.fromJson(e));
        } else if (e is Map) {
          list.add(ClassTestResult.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final sRaw = json['summary'];
    return ClassTestPeriodBlock(
      results: list,
      summary: sRaw is Map
          ? ClassTestSummary.fromJson(Map<String, dynamic>.from(sRaw))
          : ClassTestSummary.empty(),
    );
  }

  factory ClassTestPeriodBlock.empty() => ClassTestPeriodBlock(
        results: [],
        summary: ClassTestSummary.empty(),
      );
}

class ClassTestResultsData {
  final ClassTestStudent? student;
  final ClassTestPeriodBlock today;
  final ClassTestPeriodBlock previous;

  ClassTestResultsData({
    this.student,
    required this.today,
    required this.previous,
  });

  factory ClassTestResultsData.fromJson(Map<String, dynamic> json) {
    final tRaw = json['today'];
    final pRaw = json['previous'];
    final stRaw = json['student'];
    return ClassTestResultsData(
      student: stRaw is Map
          ? ClassTestStudent.fromJson(Map<String, dynamic>.from(stRaw))
          : null,
      today: tRaw is Map
          ? ClassTestPeriodBlock.fromJson(
              Map<String, dynamic>.from(tRaw),
            )
          : ClassTestPeriodBlock.empty(),
      previous: pRaw is Map
          ? ClassTestPeriodBlock.fromJson(
              Map<String, dynamic>.from(pRaw),
            )
          : ClassTestPeriodBlock.empty(),
    );
  }
}
