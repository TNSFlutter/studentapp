// Request bodies for `PUT student/profile/*` (field names match API).

Object? _jsonNullableInt(int? v) {
  if (v == null || v <= 0) return null;
  return v;
}

/// MySQL `integer` columns reject `""`; omit empty input as JSON `null`.
String? _jsonNullableTrimmedString(String s) {
  final t = s.trim();
  return t.isEmpty ? null : t;
}

/// Parse only when non-empty; `null` if blank or not a valid int (avoids `''` for int columns).
int? _jsonIntOrNullFromText(String s) {
  final t = s.trim();
  if (t.isEmpty) return null;
  return int.tryParse(t);
}

/// `PUT student/profile/basic`
class ProfileBasicUpdate {
  final String firstName;
  final String lastName;
  final String email;
  final String dateOfBirth;
  final int genderId;
  final int bloodGroupId;
  final int nationalityId;
  final int? religionId;
  final int casteId;
  final String aadhaar;
  final String identificationMark;
  final String addressLine1;
  final String addressLine2;
  final int pincode;
  final int? cityId;
  final int? stateId;
  final int? countryId;

  ProfileBasicUpdate({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.genderId,
    required this.bloodGroupId,
    required this.nationalityId,
    this.religionId,
    required this.casteId,
    required this.aadhaar,
    required this.identificationMark,
    required this.addressLine1,
    required this.addressLine2,
    required this.pincode,
    this.cityId,
    this.stateId,
    this.countryId,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'date_of_birth': dateOfBirth,
        'gender_id': genderId,
        'blood_group_id': bloodGroupId,
        'nationality_id': nationalityId,
        'religion_id': religionId,
        'caste_id': casteId,
        'aadhaar': aadhaar,
        'identification_mark': identificationMark,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'pincode': pincode,
        'city_id': _jsonNullableInt(cityId),
        'state_id': _jsonNullableInt(stateId),
        'country_id': _jsonNullableInt(countryId),
      };
}

/// `PUT student/profile/academic`
class ProfileAcademicUpdate {
  final int transportSelf;
  final int? houseId;
  final int? streamId;
  final int? feeSchemeId;
  final String cbseRegistrationNo;
  final String examRollNo;
  final String srn;

  ProfileAcademicUpdate({
    required this.transportSelf,
    this.houseId,
    this.streamId,
    this.feeSchemeId,
    required this.cbseRegistrationNo,
    required this.examRollNo,
    required this.srn,
  });

  Map<String, dynamic> toJson() => {
        'transport_self': transportSelf,
        'house_id': _jsonNullableInt(houseId),
        'stream_id': _jsonNullableInt(streamId),
        'fee_scheme_id': _jsonNullableInt(feeSchemeId),
        'cbse_registration_no': _jsonNullableTrimmedString(cbseRegistrationNo),
        'exam_roll_no': _jsonIntOrNullFromText(examRollNo),
        'srn': _jsonIntOrNullFromText(srn),
      };
}

/// `PUT student/profile/father` / `PUT student/profile/mother`
class ProfileParentUpdate {
  final bool hasParent;
  final String firstName;
  final String lastName;
  final String profession;
  final String qualification;
  final num? annualIncome;
  final String mobile;
  final String aadhaar;
  final String? dateOfBirth;
  final String email;
  final String presentAddress;
  final String officeAddress;

  ProfileParentUpdate({
    required this.hasParent,
    required this.firstName,
    required this.lastName,
    required this.profession,
    required this.qualification,
    this.annualIncome,
    required this.mobile,
    required this.aadhaar,
    this.dateOfBirth,
    required this.email,
    required this.presentAddress,
    required this.officeAddress,
  });

  Map<String, dynamic> toJsonFather() => {
        'has_father': hasParent,
        'first_name': firstName,
        'last_name': lastName,
        'profession': profession,
        'qualification': qualification,
        'annual_income': annualIncome,
        'mobile': mobile,
        'aadhaar': aadhaar,
        'date_of_birth': dateOfBirth,
        'email': email,
        'present_address': presentAddress,
        'office_address': officeAddress,
      };

  Map<String, dynamic> toJsonMother() => {
        'has_mother': hasParent,
        'first_name': firstName,
        'last_name': lastName,
        'profession': profession,
        'qualification': qualification,
        'annual_income': annualIncome,
        'mobile': mobile,
        'aadhaar': aadhaar,
        'date_of_birth': dateOfBirth,
        'email': email,
        'present_address': presentAddress,
        'office_address': officeAddress,
      };
}

/// `PUT student/profile/guardian`
class ProfileGuardianUpdate {
  final String firstName;
  final String lastName;
  final String profession;
  final String qualification;
  final num? annualIncome;
  final String mobile;
  final String aadhaar;
  final String? dateOfBirth;
  final String email;
  final String presentAddress;

  ProfileGuardianUpdate({
    required this.firstName,
    required this.lastName,
    required this.profession,
    required this.qualification,
    this.annualIncome,
    required this.mobile,
    required this.aadhaar,
    this.dateOfBirth,
    required this.email,
    required this.presentAddress,
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'profession': profession,
        'qualification': qualification,
        'annual_income': annualIncome,
        'mobile': mobile,
        'aadhaar': aadhaar,
        'date_of_birth': dateOfBirth,
        'email': email,
        'present_address': presentAddress,
      };
}
