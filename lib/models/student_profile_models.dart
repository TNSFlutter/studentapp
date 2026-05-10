// `GET student/profile` and `GET student/profile/meta`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

String _str(dynamic v) => v?.toString().trim() ?? '';

/// Boolean flags from JSON (`true`, `1`, `"yes"`, etc.).
bool _truthyBool(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  return s == 'true' ||
      s == '1' ||
      s == 'yes' ||
      s == 'y' ||
      s == 'provided';
}

class ProfileSummary {
  final int studentId;
  final int classStudentId;
  final String fullName;
  final String classSection;
  final int rollNo;
  final String admissionNo;
  final String? photo;

  ProfileSummary({
    required this.studentId,
    required this.classStudentId,
    required this.fullName,
    required this.classSection,
    required this.rollNo,
    required this.admissionNo,
    this.photo,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      studentId: _asInt(json['student_id']),
      classStudentId: _asInt(json['class_student_id']),
      fullName: _str(json['full_name']),
      classSection: _str(json['class_section']),
      rollNo: _asInt(json['roll_no']),
      admissionNo: _str(json['admission_no']),
      photo: json['photo']?.toString(),
    );
  }
}

class ProfileBasic {
  final String firstName;
  final String lastName;
  final String aadhaar;
  final String? identificationMark;
  final String email;
  final String dateOfBirth;
  final int genderId;
  final int bloodGroupId;
  final String bloodGroupLabel;
  final int casteId;
  final String? casteLabel;
  final int studentSubCategoryId;
  final int nationalityId;
  final String? nationalityLabel;
  final int? religionId;
  final String? religionLabel;
  final String addressLine1;
  final String addressLine2;
  final int pincode;
  final int cityId;
  final String cityLabel;
  final int stateId;
  final String stateLabel;
  final int countryId;
  final String countryLabel;

  ProfileBasic({
    required this.firstName,
    required this.lastName,
    required this.aadhaar,
    this.identificationMark,
    required this.email,
    required this.dateOfBirth,
    required this.genderId,
    required this.bloodGroupId,
    required this.bloodGroupLabel,
    required this.casteId,
    this.casteLabel,
    required this.studentSubCategoryId,
    required this.nationalityId,
    this.nationalityLabel,
    this.religionId,
    this.religionLabel,
    required this.addressLine1,
    required this.addressLine2,
    required this.pincode,
    required this.cityId,
    required this.cityLabel,
    required this.stateId,
    required this.stateLabel,
    required this.countryId,
    required this.countryLabel,
  });

  factory ProfileBasic.fromJson(Map<String, dynamic> json) {
    return ProfileBasic(
      firstName: _str(json['first_name']),
      lastName: _str(json['last_name']),
      aadhaar: _str(json['aadhaar']),
      identificationMark: json['identification_mark']?.toString(),
      email: _str(json['email']),
      dateOfBirth: _str(json['date_of_birth']),
      genderId: _asInt(json['gender_id']),
      bloodGroupId: _asInt(json['blood_group_id']),
      bloodGroupLabel: _str(json['blood_group_label']),
      casteId: _asInt(json['caste_id']),
      casteLabel: json['caste_label']?.toString(),
      studentSubCategoryId: _asInt(json['student_sub_category_id']),
      nationalityId: _asInt(json['nationality_id']),
      nationalityLabel: json['nationality_label']?.toString(),
      religionId: json['religion_id'] == null ? null : _asInt(json['religion_id']),
      religionLabel: json['religion_label']?.toString(),
      addressLine1: _str(json['address_line1']),
      addressLine2: _str(json['address_line2']),
      pincode: _asInt(json['pincode']),
      cityId: _asInt(json['city_id']),
      cityLabel: _str(json['city_label']),
      stateId: _asInt(json['state_id']),
      stateLabel: _str(json['state_label']),
      countryId: _asInt(json['country_id']),
      countryLabel: _str(json['country_label']),
    );
  }
}

class ProfileAdminAcademicReadonly {
  final String message;
  final String classSection;
  final int rollNo;
  final String admissionNo;
  final String admissionDate;

  ProfileAdminAcademicReadonly({
    required this.message,
    required this.classSection,
    required this.rollNo,
    required this.admissionNo,
    required this.admissionDate,
  });

  factory ProfileAdminAcademicReadonly.fromJson(Map<String, dynamic> json) {
    return ProfileAdminAcademicReadonly(
      message: _str(json['message']),
      classSection: _str(json['class_section']),
      rollNo: _asInt(json['roll_no']),
      admissionNo: _str(json['admission_no']),
      admissionDate: _str(json['admission_date']),
    );
  }
}

class ProfileAcademicEditable {
  final int transportSelf;
  final int? houseId;
  final String? houseLabel;
  final int? streamId;
  final String? streamLabel;
  final int feeSchemeId;
  final String feeSchemeLabel;
  final String? cbseRegistrationNo;
  final String? examRollNo;
  final String? srn;

  ProfileAcademicEditable({
    required this.transportSelf,
    this.houseId,
    this.houseLabel,
    this.streamId,
    this.streamLabel,
    required this.feeSchemeId,
    required this.feeSchemeLabel,
    this.cbseRegistrationNo,
    this.examRollNo,
    this.srn,
  });

  factory ProfileAcademicEditable.fromJson(Map<String, dynamic> json) {
    return ProfileAcademicEditable(
      transportSelf: _asInt(json['transport_self']),
      houseId: json['house_id'] == null ? null : _asInt(json['house_id']),
      houseLabel: json['house_label']?.toString(),
      streamId: json['stream_id'] == null ? null : _asInt(json['stream_id']),
      streamLabel: json['stream_label']?.toString(),
      feeSchemeId: _asInt(json['fee_scheme_id']),
      feeSchemeLabel: _str(json['fee_scheme_label']),
      cbseRegistrationNo: json['cbse_registration_no']?.toString(),
      examRollNo: json['exam_roll_no']?.toString(),
      srn: json['srn']?.toString(),
    );
  }
}

class ProfileParentBlock {
  final bool hasParent;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? profession;
  final String? qualification;
  final num? annualIncome;
  final String? mobile;
  final String? aadhaar;
  final String? dateOfBirth;
  final String? email;
  final String? presentAddress;
  final String? officeAddress;

  ProfileParentBlock({
    required this.hasParent,
    this.firstName,
    this.middleName,
    this.lastName,
    this.profession,
    this.qualification,
    this.annualIncome,
    this.mobile,
    this.aadhaar,
    this.dateOfBirth,
    this.email,
    this.presentAddress,
    this.officeAddress,
  });

  factory ProfileParentBlock.fromJson(
    Map<String, dynamic> json, {
    required String hasKey,
  }) {
    final has = json[hasKey] == true;
    return ProfileParentBlock(
      hasParent: has,
      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),
      profession: json['profession']?.toString(),
      qualification: json['qualification']?.toString(),
      annualIncome: json['annual_income'] == null
          ? null
          : (json['annual_income'] is num
              ? json['annual_income'] as num
              : num.tryParse(json['annual_income'].toString())),
      mobile: json['mobile']?.toString(),
      aadhaar: json['aadhaar']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      email: json['email']?.toString(),
      presentAddress: json['present_address']?.toString(),
      officeAddress: json['office_address']?.toString(),
    );
  }

  String get displayName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].map((e) => e?.trim() ?? '').where((e) => e.isNotEmpty).toList();
    return parts.join(' ');
  }
}

bool _labelMeansBirthCertificate(String label) {
  final s = label.toLowerCase();
  return s.contains('birth') ||
      s.contains('birth_cert') ||
      s.contains('birth certificate');
}

bool _labelMeansTc(String label) {
  final s = label.toLowerCase();
  return s.contains('transfer') ||
      s.contains('transfer_cert') ||
      s.contains('transfer certificate') ||
      RegExp(r'\btc\b').hasMatch(s) ||
      s.contains('t.c.') ||
      s == 'tc';
}

bool _labelMeansStudentSubCategory(String label) {
  final s = label.toLowerCase();
  return (s.contains('sub') && s.contains('categor')) ||
      s.contains('sub_category') ||
      s.contains('subcategory') ||
      s.contains('student_sub_category');
}

int? _extractDocumentTypeId(Map<String, dynamic> d) {
  for (final k in [
    'doc_type_id',
    'document_type_id',
    'type_id',
    'document_type_master_id',
  ]) {
    final v = d[k];
    if (v == null) continue;
    if (v is int && v > 0) return v;
    final p = int.tryParse(v.toString());
    if (p != null && p > 0) return p;
  }
  final dt = d['document_type'];
  if (dt is int && dt > 0) return dt;
  if (dt is num && dt.toInt() > 0) return dt.toInt();
  final ps = dt?.toString().trim() ?? '';
  if (ps.isNotEmpty && RegExp(r'^\d+$').hasMatch(ps)) {
    return int.tryParse(ps);
  }
  return null;
}

/// Keys from nested profile blocks where checklist booleans sometimes appear.
Map<String, dynamic> _checklistRootFallback(Map<String, dynamic> root) {
  final merged = Map<String, dynamic>.from(root);
  for (final box in ['basic', 'academic_editable', 'summary']) {
    final sub = root[box];
    if (sub is Map<String, dynamic>) {
      merged.addAll(sub);
    } else if (sub is Map) {
      merged.addAll(Map<String, dynamic>.from(sub));
    }
  }
  return merged;
}

class ProfileDocumentsChecklist {
  final bool birthCertificateProvided;
  final bool tcProvided;
  final bool studentSubCategoryProvided;

  ProfileDocumentsChecklist({
    required this.birthCertificateProvided,
    required this.tcProvided,
    required this.studentSubCategoryProvided,
  });

  /// Parses checklist flags; checks [nested] first, then [rootFallback] for the same keys.
  factory ProfileDocumentsChecklist.fromJson(
    Map<String, dynamic> nested, [
    Map<String, dynamic>? rootFallback,
  ]) {
    final mergedRoot =
        rootFallback == null ? null : _checklistRootFallback(rootFallback);

    bool pick(Iterable<String> keys) {
      for (final k in keys) {
        if (nested.containsKey(k)) return _truthyBool(nested[k]);
      }
      final root = mergedRoot;
      if (root != null) {
        for (final k in keys) {
          if (root.containsKey(k)) return _truthyBool(root[k]);
        }
      }
      return false;
    }

    return ProfileDocumentsChecklist(
      birthCertificateProvided: pick(const [
        'birth_certificate_provided',
        'birthCertificateProvided',
        'BirthCertificateProvided',
        'is_birth_certificate_provided',
        'has_birth_certificate',
        'birth_certificate_uploaded',
      ]),
      tcProvided: pick(const [
        'tc_provided',
        'tcProvided',
        'transfer_certificate_provided',
        'transferCertificateProvided',
        'TCProvided',
        'has_tc',
        'tc_uploaded',
        'transfer_certificate_uploaded',
      ]),
      studentSubCategoryProvided: pick(const [
        'student_sub_category_provided',
        'studentSubCategoryProvided',
        'sub_category_provided',
        'has_student_sub_category',
        'sub_category_document_provided',
      ]),
    );
  }

  /// API returns `documents_checklist` as a list of rows (labels + status).
  factory ProfileDocumentsChecklist.fromJsonArray(
    List<dynamic> raw,
    Map<String, dynamic>? rootFallback,
  ) {
    bool birth = false;
    bool tc = false;
    bool sub = false;

    for (final e in raw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final label =
          '${m['label'] ?? m['name'] ?? m['title'] ?? m['document_type_name'] ?? m['document_type_label'] ?? m['document_type'] ?? m['type'] ?? ''}'
              .trim()
              .toLowerCase();

      bool rowOk = _truthyBool(m['provided']) ||
          _truthyBool(m['is_provided']) ||
          _truthyBool(m['uploaded']) ||
          _truthyBool(m['is_uploaded']) ||
          _truthyBool(m['complete']) ||
          _truthyBool(m['is_complete']);

      final st = m['status']?.toString().toLowerCase() ?? '';
      if (st == 'provided' ||
          st == 'complete' ||
          st == 'uploaded' ||
          st == 'yes' ||
          st == 'done') {
        rowOk = true;
      }

      if (!rowOk && m.containsKey('value')) {
        rowOk = _truthyBool(m['value']);
      }

      if (!rowOk) continue;

      if (_labelMeansBirthCertificate(label)) birth = true;
      if (_labelMeansTc(label)) tc = true;
      if (_labelMeansStudentSubCategory(label)) sub = true;
    }

    final fb = ProfileDocumentsChecklist.fromJson(
      {},
      rootFallback == null ? null : _checklistRootFallback(rootFallback),
    );
    return ProfileDocumentsChecklist(
      birthCertificateProvided: birth || fb.birthCertificateProvided,
      tcProvided: tc || fb.tcProvided,
      studentSubCategoryProvided: sub || fb.studentSubCategoryProvided,
    );
  }

  /// When API checklist flags are missing/wrong, infer "Provided" from uploaded docs metadata.
  ProfileDocumentsChecklist withInferenceFromDocuments(
    List<Map<String, dynamic>> documents,
  ) {
    if (documents.isEmpty) return this;

    bool inferBirth = false;
    bool inferTc = false;
    bool inferSub = false;

    for (final d in documents) {
      final blob = <String>[];
      for (final k in [
        'document_type',
        'type_name',
        'type',
        'category',
        'title',
        'name',
        'file_name',
        'label',
      ]) {
        final v = d[k]?.toString().toLowerCase() ?? '';
        if (v.isNotEmpty) blob.add(v);
      }
      final text = blob.join(' · ');
      if (_labelMeansBirthCertificate(text)) inferBirth = true;
      if (_labelMeansTc(text)) inferTc = true;
      if (_labelMeansStudentSubCategory(text)) inferSub = true;
    }

    return ProfileDocumentsChecklist(
      birthCertificateProvided: birthCertificateProvided || inferBirth,
      tcProvided: tcProvided || inferTc,
      studentSubCategoryProvided:
          studentSubCategoryProvided || inferSub,
    );
  }

  /// Student record already has a sub-category chosen (profile may omit checklist flags).
  ProfileDocumentsChecklist withBasicStudentSubCategory(ProfileBasic basic) {
    return ProfileDocumentsChecklist(
      birthCertificateProvided: birthCertificateProvided,
      tcProvided: tcProvided,
      studentSubCategoryProvided: studentSubCategoryProvided ||
          basic.studentSubCategoryId > 0,
    );
  }

  /// Match uploaded files to meta [documentTypes] by id (most reliable when labels are only on meta).
  ProfileDocumentsChecklist withDocumentTypeMeta(
    List<Map<String, dynamic>> documents,
    List<ProfileMetaOption>? documentTypes,
  ) {
    if (documentTypes == null || documentTypes.isEmpty) return this;

    final idToLabel = {for (final t in documentTypes) t.id: t.label.toLowerCase()};
    var b = birthCertificateProvided;
    var tc = tcProvided;
    var sub = studentSubCategoryProvided;

    for (final d in documents) {
      final tid = _extractDocumentTypeId(d);
      if (tid == null || tid <= 0) continue;
      final lab = idToLabel[tid] ?? '';
      if (lab.isEmpty) continue;
      if (_labelMeansBirthCertificate(lab)) b = true;
      if (_labelMeansTc(lab)) tc = true;
      if (_labelMeansStudentSubCategory(lab)) sub = true;
    }

    return ProfileDocumentsChecklist(
      birthCertificateProvided: b,
      tcProvided: tc,
      studentSubCategoryProvided: sub,
    );
  }

  /// Full merge for the Docs tab (uploaded files + academic basics + meta labels).
  ProfileDocumentsChecklist resolvedForDisplay({
    required List<Map<String, dynamic>> documents,
    required ProfileBasic basic,
    List<ProfileMetaOption>? documentTypes,
  }) {
    return withInferenceFromDocuments(documents)
        .withBasicStudentSubCategory(basic)
        .withDocumentTypeMeta(documents, documentTypes);
  }
}

class ProfilePhotos {
  final String? student;
  final String? father;
  final String? mother;
  final String? guardian;

  ProfilePhotos({
    this.student,
    this.father,
    this.mother,
    this.guardian,
  });

  factory ProfilePhotos.fromJson(Map<String, dynamic> json) {
    return ProfilePhotos(
      student: json['student']?.toString(),
      father: json['father']?.toString(),
      mother: json['mother']?.toString(),
      guardian: json['guardian']?.toString(),
    );
  }
}

ProfileDocumentsChecklist _resolveDocumentsChecklist(
  dynamic docChRaw,
  Map<String, dynamic> rootJson,
  List<Map<String, dynamic>> documents,
  ProfileBasic basic,
) {
  final fallback = _checklistRootFallback(rootJson);

  final ProfileDocumentsChecklist base;
  if (docChRaw is List) {
    base = ProfileDocumentsChecklist.fromJsonArray(docChRaw, fallback);
  } else {
    final Map<String, dynamic> nested;
    if (docChRaw is Map<String, dynamic>) {
      nested = docChRaw;
    } else if (docChRaw is Map) {
      nested = Map<String, dynamic>.from(docChRaw);
    } else {
      nested = <String, dynamic>{};
    }
    base = ProfileDocumentsChecklist.fromJson(nested, fallback);
  }

  return base
      .withInferenceFromDocuments(documents)
      .withBasicStudentSubCategory(basic);
}

class StudentProfilePayload {
  final ProfileSummary summary;
  final ProfileBasic basic;
  final ProfileAdminAcademicReadonly adminAcademicReadonly;
  final ProfileAcademicEditable academicEditable;
  final ProfileParentBlock father;
  final ProfileParentBlock mother;
  final ProfileParentBlock guardian;
  final ProfileDocumentsChecklist documentsChecklist;
  final List<Map<String, dynamic>> documents;
  final ProfilePhotos photos;

  /// When `false`, parents cannot change profile fields (school-controlled).
  /// Parsed from `is_editable` / `isEditable`; defaults to `true` if omitted.
  final bool isEditable;

  StudentProfilePayload({
    required this.summary,
    required this.basic,
    required this.adminAcademicReadonly,
    required this.academicEditable,
    required this.father,
    required this.mother,
    required this.guardian,
    required this.documentsChecklist,
    required this.documents,
    required this.photos,
    this.isEditable = true,
  });

  factory StudentProfilePayload.fromJson(Map<String, dynamic> json) {
    final sumRaw = json['summary'];
    final basicRaw = json['basic'];
    final admRaw = json['admin_academic_readonly'];
    final acadRaw = json['academic_editable'];
    final fRaw = json['father'];
    final mRaw = json['mother'];
    final gRaw = json['guardian'];
    final docChRaw = json['documents_checklist'] ??
        json['documentsChecklist'] ??
        json['document_checklist'];
    final docsRaw = json['documents'];
    final photosRaw = json['photos'];

    final docs = <Map<String, dynamic>>[];
    if (docsRaw is List) {
      for (final e in docsRaw) {
        if (e is Map<String, dynamic>) {
          docs.add(e);
        } else if (e is Map) {
          docs.add(Map<String, dynamic>.from(e));
        }
      }
    }

    final basic = basicRaw is Map<String, dynamic>
        ? ProfileBasic.fromJson(basicRaw)
        : ProfileBasic.fromJson({});

    final hasEditableFlag =
        json.containsKey('is_editable') || json.containsKey('isEditable');

    return StudentProfilePayload(
      summary: sumRaw is Map<String, dynamic>
          ? ProfileSummary.fromJson(sumRaw)
          : ProfileSummary.fromJson({}),
      basic: basic,
      adminAcademicReadonly: admRaw is Map<String, dynamic>
          ? ProfileAdminAcademicReadonly.fromJson(admRaw)
          : ProfileAdminAcademicReadonly.fromJson({}),
      academicEditable: acadRaw is Map<String, dynamic>
          ? ProfileAcademicEditable.fromJson(acadRaw)
          : ProfileAcademicEditable.fromJson({}),
      father: fRaw is Map<String, dynamic>
          ? ProfileParentBlock.fromJson(fRaw, hasKey: 'has_father')
          : ProfileParentBlock(hasParent: false),
      mother: mRaw is Map<String, dynamic>
          ? ProfileParentBlock.fromJson(mRaw, hasKey: 'has_mother')
          : ProfileParentBlock(hasParent: false),
      guardian: gRaw is Map<String, dynamic>
          ? ProfileParentBlock.fromJson(gRaw, hasKey: 'has_guardian')
          : ProfileParentBlock(hasParent: false),
      documentsChecklist: _resolveDocumentsChecklist(docChRaw, json, docs, basic),
      documents: docs,
      photos: photosRaw is Map<String, dynamic>
          ? ProfilePhotos.fromJson(photosRaw)
          : ProfilePhotos(),
      isEditable: hasEditableFlag
          ? _truthyBool(json['is_editable'] ?? json['isEditable'])
          : true,
    );
  }
}

class StudentProfileApiResponse {
  final bool success;
  final String message;
  final StudentProfilePayload? data;

  StudentProfileApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StudentProfileApiResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'];
    return StudentProfileApiResponse(
      success: json['success'] == true,
      message: _str(json['message']),
      data: d is Map<String, dynamic>
          ? StudentProfilePayload.fromJson(d)
          : null,
    );
  }
}

/// Meta option: gender uses `label`, most others use `name`.
class ProfileMetaOption {
  final int id;
  final String label;

  ProfileMetaOption({required this.id, required this.label});

  factory ProfileMetaOption.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString();
    final lbl = json['label']?.toString();
    return ProfileMetaOption(
      id: _asInt(json['id']),
      label: (lbl != null && lbl.isNotEmpty) ? lbl : (name ?? ''),
    );
  }
}

class StudentProfileMetaPayload {
  final List<ProfileMetaOption> genderOptions;
  final List<ProfileMetaOption> bloodGroups;
  final List<ProfileMetaOption> religions;
  final List<ProfileMetaOption> nationalities;
  final List<ProfileMetaOption> castes;
  final List<ProfileMetaOption> countries;
  /// Present when meta is loaded with `?country_id=`.
  final List<ProfileMetaOption> states;
  /// Present when meta is loaded with `?state_id=`.
  final List<ProfileMetaOption> cities;
  final List<ProfileMetaOption> houses;
  final List<ProfileMetaOption> feeSchemes;
  final List<ProfileMetaOption> streams;
  final List<ProfileMetaOption> documentTypes;

  StudentProfileMetaPayload({
    required this.genderOptions,
    required this.bloodGroups,
    required this.religions,
    required this.nationalities,
    required this.castes,
    required this.countries,
    this.states = const [],
    this.cities = const [],
    required this.houses,
    required this.feeSchemes,
    required this.streams,
    required this.documentTypes,
  });

  StudentProfileMetaPayload copyWith({
    List<ProfileMetaOption>? genderOptions,
    List<ProfileMetaOption>? bloodGroups,
    List<ProfileMetaOption>? religions,
    List<ProfileMetaOption>? nationalities,
    List<ProfileMetaOption>? castes,
    List<ProfileMetaOption>? countries,
    List<ProfileMetaOption>? states,
    List<ProfileMetaOption>? cities,
    List<ProfileMetaOption>? houses,
    List<ProfileMetaOption>? feeSchemes,
    List<ProfileMetaOption>? streams,
    List<ProfileMetaOption>? documentTypes,
  }) {
    return StudentProfileMetaPayload(
      genderOptions: genderOptions ?? this.genderOptions,
      bloodGroups: bloodGroups ?? this.bloodGroups,
      religions: religions ?? this.religions,
      nationalities: nationalities ?? this.nationalities,
      castes: castes ?? this.castes,
      countries: countries ?? this.countries,
      states: states ?? this.states,
      cities: cities ?? this.cities,
      houses: houses ?? this.houses,
      feeSchemes: feeSchemes ?? this.feeSchemes,
      streams: streams ?? this.streams,
      documentTypes: documentTypes ?? this.documentTypes,
    );
  }

  static List<ProfileMetaOption> _listOf(
    Map<String, dynamic> json,
    String key,
  ) {
    final raw = json[key];
    final out = <ProfileMetaOption>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          out.add(ProfileMetaOption.fromJson(e));
        } else if (e is Map) {
          out.add(ProfileMetaOption.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return out;
  }

  factory StudentProfileMetaPayload.fromJson(Map<String, dynamic> json) {
    return StudentProfileMetaPayload(
      genderOptions: _listOf(json, 'gender_options'),
      bloodGroups: _listOf(json, 'blood_groups'),
      religions: _listOf(json, 'religions'),
      nationalities: _listOf(json, 'nationalities'),
      castes: _listOf(json, 'castes'),
      countries: _listOf(json, 'countries'),
      states: _listOf(json, 'states'),
      cities: _listOf(json, 'cities'),
      houses: _listOf(json, 'houses'),
      feeSchemes: _listOf(json, 'fee_schemes'),
      streams: _listOf(json, 'streams'),
      documentTypes: _listOf(json, 'document_types'),
    );
  }
}

class StudentProfileMetaApiResponse {
  final bool success;
  final String message;
  final StudentProfileMetaPayload? data;

  StudentProfileMetaApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory StudentProfileMetaApiResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'];
    return StudentProfileMetaApiResponse(
      success: json['success'] == true,
      message: _str(json['message']),
      data: d is Map<String, dynamic>
          ? StudentProfileMetaPayload.fromJson(d)
          : null,
    );
  }
}
