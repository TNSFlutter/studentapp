bool validateMobile(String value) {
  const patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
  final regExp = RegExp(patttern);
  return regExp.hasMatch(value);
}

// Email validation
bool validateEmail(String email) {
  const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  final regExp = RegExp(pattern);
  return regExp.hasMatch(email);
}

// Password validation
bool validatePassword(String password) {
  // At least 8 characters, 1 uppercase, 1 lowercase, 1 number, 1 special character
  const pattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
  final regExp = RegExp(pattern);
  return regExp.hasMatch(password);
}

// Required field validation
bool validateRequired(String value) {
  return value.trim().isNotEmpty;
}

// Minimum length validation
bool validateMinLength(String value, int minLength) {
  return value.trim().length >= minLength;
}

// Maximum length validation
bool validateMaxLength(String value, int maxLength) {
  return value.trim().length <= maxLength;
}

// Get validation error message
String? getValidationError(
  String value,
  String fieldName, {
  bool isRequired = true,
  bool isEmail = false,
  bool isPassword = false,
  int? minLength,
  int? maxLength,
}) {
  if (isRequired && !validateRequired(value)) {
    return '$fieldName is required';
  }

  if (isEmail && !validateEmail(value)) {
    return 'Please enter a valid email address';
  }

  if (isPassword && !validatePassword(value)) {
    return 'Password must be at least 8 characters with uppercase, lowercase, number and special character';
  }

  if (minLength != null && !validateMinLength(value, minLength)) {
    return '$fieldName must be at least $minLength characters';
  }

  if (maxLength != null && !validateMaxLength(value, maxLength)) {
    return '$fieldName must not exceed $maxLength characters';
  }

  return null;
}
