import '../../helpers/validators.dart';
import 'profile_edit_form_controllers.dart';
import '../../models/student_profile_models.dart';

void addBasicTabErrors(
  ProfileEditFormControllers e,
  void Function(String key, String message) out,
) {
  if (e.basicFirstName.text.trim().isEmpty) {
    out('firstName', 'This field is required');
  }
  if (e.basicLastName.text.trim().isEmpty) {
    out('lastName', 'This field is required');
  }
  final email = e.basicEmail.text.trim();
  if (email.isEmpty) {
    out('email', 'This field is required');
  } else if (!validateEmail(email)) {
    out('email', 'Enter a valid email address');
  }
  final dob = e.basicDobIso.text.trim();
  if (dob.isEmpty) {
    out('dob', 'This field is required');
  } else if (DateTime.tryParse(dob) == null) {
    out('dob', 'Use date format yyyy-MM-dd');
  }
  if (e.genderId <= 0) out('gender', 'This field is required');
  if (e.bloodGroupId <= 0) out('blood', 'This field is required');
  if (e.casteId <= 0) out('caste', 'This field is required');
  if (e.nationalityId <= 0) out('nationality', 'This field is required');
  if (e.basicAddr1.text.trim().isEmpty) {
    out('addr1', 'This field is required');
  }
  final pin = e.basicPincode.text.trim();
  if (pin.isEmpty) {
    out('pincode', 'This field is required');
  } else {
    final p = int.tryParse(pin);
    if (p == null || p <= 0) {
      out('pincode', 'Enter a valid PIN code');
    }
  }
}

void addAcademicTabErrors(
  ProfileEditFormControllers e,
  void Function(String key, String message) out,
) {
  final exam = e.acadExamRoll.text.trim();
  if (exam.isNotEmpty && int.tryParse(exam) == null) {
    out('examRoll', 'Must be a whole number (or leave empty)');
  }
  final srn = e.acadSrn.text.trim();
  if (srn.isNotEmpty && int.tryParse(srn) == null) {
    out('srn', 'Must be a whole number (or leave empty)');
  }
}

void addParentTabErrors(
  ProfileEditFormControllers e,
  ProfileParentBlock block,
  bool isFather,
  void Function(String key, String message) out,
) {
  if (!block.hasParent) return;
  if (isFather) {
    if (e.fatherFirst.text.trim().isEmpty) out('firstName', 'This field is required');
    if (e.fatherLast.text.trim().isEmpty) out('lastName', 'This field is required');
    final m = e.fatherMobile.text.trim();
    if (m.isEmpty) {
      out('mobile', 'This field is required');
    } else if (!validateMobile(m)) {
      out('mobile', 'Enter a valid mobile number');
    }
    final em = e.fatherEmail.text.trim();
    if (em.isNotEmpty && !validateEmail(em)) {
      out('email', 'Enter a valid email address');
    }
  } else {
    if (e.motherFirst.text.trim().isEmpty) out('firstName', 'This field is required');
    if (e.motherLast.text.trim().isEmpty) out('lastName', 'This field is required');
    final m = e.motherMobile.text.trim();
    if (m.isEmpty) {
      out('mobile', 'This field is required');
    } else if (!validateMobile(m)) {
      out('mobile', 'Enter a valid mobile number');
    }
    final em = e.motherEmail.text.trim();
    if (em.isNotEmpty && !validateEmail(em)) {
      out('email', 'Enter a valid email address');
    }
  }
}

void addGuardianTabErrors(
  ProfileEditFormControllers e,
  void Function(String key, String message) out,
) {
  if (e.guardianFirst.text.trim().isEmpty) {
    out('firstName', 'This field is required');
  }
  if (e.guardianLast.text.trim().isEmpty) {
    out('lastName', 'This field is required');
  }
  final m = e.guardianMobile.text.trim();
  if (m.isEmpty) {
    out('mobile', 'This field is required');
  } else if (!validateMobile(m)) {
    out('mobile', 'Enter a valid mobile number');
  }
  final em = e.guardianEmail.text.trim();
  if (em.isNotEmpty && !validateEmail(em)) {
    out('email', 'Enter a valid email address');
  }
}
