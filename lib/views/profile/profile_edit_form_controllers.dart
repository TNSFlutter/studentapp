import 'package:flutter/material.dart';

import '../../models/student_profile_models.dart';
import '../../models/student_profile_update_models.dart';

/// Text controllers for [EditStudentInfoScreen] — disposed by owner.
class ProfileEditFormControllers {
  ProfileEditFormControllers._(this._profile);

  final StudentProfilePayload _profile;

  factory ProfileEditFormControllers.fromProfile(StudentProfilePayload p) {
    final c = ProfileEditFormControllers._(p);
    c._init(p);
    return c;
  }

  late final TextEditingController basicFirstName;
  late final TextEditingController basicLastName;
  late final TextEditingController basicDobIso;
  late final TextEditingController basicEmail;
  late final TextEditingController basicAadhaar;
  late final TextEditingController basicIdMark;
  late final TextEditingController basicAddr1;
  late final TextEditingController basicAddr2;
  late final TextEditingController basicPincode;

  late final TextEditingController acadCbse;
  late final TextEditingController acadExamRoll;
  late final TextEditingController acadSrn;

  late final TextEditingController fatherFirst;
  late final TextEditingController fatherLast;
  late final TextEditingController fatherProfession;
  late final TextEditingController fatherQualification;
  late final TextEditingController fatherIncome;
  late final TextEditingController fatherMobile;
  late final TextEditingController fatherAadhaar;
  late final TextEditingController fatherDob;
  late final TextEditingController fatherEmail;
  late final TextEditingController fatherPresent;
  late final TextEditingController fatherOffice;

  late final TextEditingController motherFirst;
  late final TextEditingController motherLast;
  late final TextEditingController motherProfession;
  late final TextEditingController motherQualification;
  late final TextEditingController motherIncome;
  late final TextEditingController motherMobile;
  late final TextEditingController motherAadhaar;
  late final TextEditingController motherDob;
  late final TextEditingController motherEmail;
  late final TextEditingController motherPresent;
  late final TextEditingController motherOffice;

  late final TextEditingController guardianFirst;
  late final TextEditingController guardianLast;
  late final TextEditingController guardianProfession;
  late final TextEditingController guardianQualification;
  late final TextEditingController guardianIncome;
  late final TextEditingController guardianMobile;
  late final TextEditingController guardianAadhaar;
  late final TextEditingController guardianDob;
  late final TextEditingController guardianEmail;
  late final TextEditingController guardianPresent;

  /// Editable FKs (from `GET student/profile/meta`); updated by dropdowns on the edit screen.
  late int genderId;
  late int bloodGroupId;
  late int nationalityId;
  int? religionId;
  late int casteId;
  int? countryId;
  int? stateId;
  int? cityId;

  late int transportSelf;
  int? houseId;
  int? streamId;
  int? feeSchemeId;

  void _init(StudentProfilePayload p) {
    final b = p.basic;
    basicFirstName = TextEditingController(text: b.firstName);
    basicLastName = TextEditingController(text: b.lastName);
    basicDobIso = TextEditingController(text: b.dateOfBirth);
    basicEmail = TextEditingController(text: b.email);
    basicAadhaar = TextEditingController(text: b.aadhaar);
    basicIdMark = TextEditingController(text: b.identificationMark ?? '');
    basicAddr1 = TextEditingController(text: b.addressLine1);
    basicAddr2 = TextEditingController(text: b.addressLine2);
    basicPincode = TextEditingController(
      text: b.pincode == 0 ? '' : '${b.pincode}',
    );

    genderId = b.genderId;
    bloodGroupId = b.bloodGroupId;
    nationalityId = b.nationalityId;
    religionId = b.religionId;
    casteId = b.casteId;
    countryId = b.countryId > 0 ? b.countryId : null;
    stateId = b.stateId > 0 ? b.stateId : null;
    cityId = b.cityId > 0 ? b.cityId : null;

    final ac = p.academicEditable;
    transportSelf = ac.transportSelf;
    houseId = ac.houseId;
    streamId = ac.streamId;
    feeSchemeId = ac.feeSchemeId > 0 ? ac.feeSchemeId : null;

    acadCbse = TextEditingController(text: ac.cbseRegistrationNo ?? '');
    acadExamRoll = TextEditingController(text: ac.examRollNo ?? '');
    acadSrn = TextEditingController(text: ac.srn ?? '');

    fatherFirst = TextEditingController(text: p.father.firstName ?? '');
    fatherLast = TextEditingController(text: p.father.lastName ?? '');
    fatherProfession = TextEditingController(text: p.father.profession ?? '');
    fatherQualification = TextEditingController(text: p.father.qualification ?? '');
    fatherIncome = TextEditingController(
      text: p.father.annualIncome == null ? '' : p.father.annualIncome.toString(),
    );
    fatherMobile = TextEditingController(text: p.father.mobile ?? '');
    fatherAadhaar = TextEditingController(text: p.father.aadhaar ?? '');
    fatherDob = TextEditingController(text: p.father.dateOfBirth ?? '');
    fatherEmail = TextEditingController(text: p.father.email ?? '');
    fatherPresent = TextEditingController(text: p.father.presentAddress ?? '');
    fatherOffice = TextEditingController(text: p.father.officeAddress ?? '');

    motherFirst = TextEditingController(text: p.mother.firstName ?? '');
    motherLast = TextEditingController(text: p.mother.lastName ?? '');
    motherProfession = TextEditingController(text: p.mother.profession ?? '');
    motherQualification = TextEditingController(text: p.mother.qualification ?? '');
    motherIncome = TextEditingController(
      text: p.mother.annualIncome == null ? '' : p.mother.annualIncome.toString(),
    );
    motherMobile = TextEditingController(text: p.mother.mobile ?? '');
    motherAadhaar = TextEditingController(text: p.mother.aadhaar ?? '');
    motherDob = TextEditingController(text: p.mother.dateOfBirth ?? '');
    motherEmail = TextEditingController(text: p.mother.email ?? '');
    motherPresent = TextEditingController(text: p.mother.presentAddress ?? '');
    motherOffice = TextEditingController(text: p.mother.officeAddress ?? '');

    final g = p.guardian;
    guardianFirst = TextEditingController(text: g.firstName ?? '');
    guardianLast = TextEditingController(text: g.lastName ?? '');
    guardianProfession = TextEditingController(text: g.profession ?? '');
    guardianQualification = TextEditingController(text: g.qualification ?? '');
    guardianIncome = TextEditingController(
      text: g.annualIncome == null ? '' : g.annualIncome.toString(),
    );
    guardianMobile = TextEditingController(text: g.mobile ?? '');
    guardianAadhaar = TextEditingController(text: g.aadhaar ?? '');
    guardianDob = TextEditingController(text: g.dateOfBirth ?? '');
    guardianEmail = TextEditingController(text: g.email ?? '');
    guardianPresent = TextEditingController(text: g.presentAddress ?? '');
  }

  void dispose() {
    basicFirstName.dispose();
    basicLastName.dispose();
    basicDobIso.dispose();
    basicEmail.dispose();
    basicAadhaar.dispose();
    basicIdMark.dispose();
    basicAddr1.dispose();
    basicAddr2.dispose();
    basicPincode.dispose();
    acadCbse.dispose();
    acadExamRoll.dispose();
    acadSrn.dispose();
    fatherFirst.dispose();
    fatherLast.dispose();
    fatherProfession.dispose();
    fatherQualification.dispose();
    fatherIncome.dispose();
    fatherMobile.dispose();
    fatherAadhaar.dispose();
    fatherDob.dispose();
    fatherEmail.dispose();
    fatherPresent.dispose();
    fatherOffice.dispose();
    motherFirst.dispose();
    motherLast.dispose();
    motherProfession.dispose();
    motherQualification.dispose();
    motherIncome.dispose();
    motherMobile.dispose();
    motherAadhaar.dispose();
    motherDob.dispose();
    motherEmail.dispose();
    motherPresent.dispose();
    motherOffice.dispose();
    guardianFirst.dispose();
    guardianLast.dispose();
    guardianProfession.dispose();
    guardianQualification.dispose();
    guardianIncome.dispose();
    guardianMobile.dispose();
    guardianAadhaar.dispose();
    guardianDob.dispose();
    guardianEmail.dispose();
    guardianPresent.dispose();
  }

  static num? _parseIncome(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return num.tryParse(t.replaceAll(',', ''));
  }

  static String? _emptyToNullIso(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return t;
  }

  ProfileBasicUpdate toBasicUpdate() {
    final b = _profile.basic;
    final pin = int.tryParse(basicPincode.text.trim()) ?? b.pincode;
    return ProfileBasicUpdate(
      firstName: basicFirstName.text.trim(),
      lastName: basicLastName.text.trim(),
      email: basicEmail.text.trim(),
      dateOfBirth: basicDobIso.text.trim(),
      genderId: genderId,
      bloodGroupId: bloodGroupId,
      nationalityId: nationalityId,
      religionId: religionId,
      casteId: casteId,
      aadhaar: basicAadhaar.text.trim(),
      identificationMark: basicIdMark.text.trim(),
      addressLine1: basicAddr1.text.trim(),
      addressLine2: basicAddr2.text.trim(),
      pincode: pin,
      cityId: cityId,
      stateId: stateId,
      countryId: countryId,
    );
  }

  ProfileAcademicUpdate toAcademicUpdate() {
    return ProfileAcademicUpdate(
      transportSelf: transportSelf,
      houseId: houseId,
      streamId: streamId,
      feeSchemeId: feeSchemeId,
      cbseRegistrationNo: acadCbse.text.trim(),
      examRollNo: acadExamRoll.text.trim(),
      srn: acadSrn.text.trim(),
    );
  }

  ProfileParentUpdate toFatherUpdate() {
    final f = _profile.father;
    return ProfileParentUpdate(
      hasParent: f.hasParent,
      firstName: fatherFirst.text.trim(),
      lastName: fatherLast.text.trim(),
      profession: fatherProfession.text.trim(),
      qualification: fatherQualification.text.trim(),
      annualIncome: _parseIncome(fatherIncome.text),
      mobile: fatherMobile.text.trim(),
      aadhaar: fatherAadhaar.text.trim(),
      dateOfBirth: _emptyToNullIso(fatherDob.text),
      email: fatherEmail.text.trim(),
      presentAddress: fatherPresent.text.trim(),
      officeAddress: fatherOffice.text.trim(),
    );
  }

  ProfileParentUpdate toMotherUpdate() {
    final m = _profile.mother;
    return ProfileParentUpdate(
      hasParent: m.hasParent,
      firstName: motherFirst.text.trim(),
      lastName: motherLast.text.trim(),
      profession: motherProfession.text.trim(),
      qualification: motherQualification.text.trim(),
      annualIncome: _parseIncome(motherIncome.text),
      mobile: motherMobile.text.trim(),
      aadhaar: motherAadhaar.text.trim(),
      dateOfBirth: _emptyToNullIso(motherDob.text),
      email: motherEmail.text.trim(),
      presentAddress: motherPresent.text.trim(),
      officeAddress: motherOffice.text.trim(),
    );
  }

  ProfileGuardianUpdate toGuardianUpdate() {
    return ProfileGuardianUpdate(
      firstName: guardianFirst.text.trim(),
      lastName: guardianLast.text.trim(),
      profession: guardianProfession.text.trim(),
      qualification: guardianQualification.text.trim(),
      annualIncome: _parseIncome(guardianIncome.text),
      mobile: guardianMobile.text.trim(),
      aadhaar: guardianAadhaar.text.trim(),
      dateOfBirth: _emptyToNullIso(guardianDob.text),
      email: guardianEmail.text.trim(),
      presentAddress: guardianPresent.text.trim(),
    );
  }
}
