String _stripBearerPrefix(String value) {
  final v = value.trim();
  if (v.length > 7 && v.toLowerCase().startsWith('bearer ')) {
    return v.substring(7).trim();
  }
  return v;
}

/// Reads access token from common API field names.
String _readAccessToken(Map<String, dynamic> json) {
  const keys = ['token', 'access_token', 'accessToken'];
  for (final k in keys) {
    final v = json[k];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty) return _stripBearerPrefix(s);
  }
  return '';
}

/// Reads refresh token from common API field names.
String _readRefreshToken(Map<String, dynamic> json) {
  const keys = ['refresh_token', 'refreshToken'];
  for (final k in keys) {
    final v = json[k];
    if (v == null) continue;
    final s = v.toString().trim();
    if (s.isNotEmpty) return s;
  }
  return '';
}

Map<String, dynamic> _sessionKeysFromLoginPayload(Map<String, dynamic> json) {
  final m = <String, dynamic>{};
  const keys = [
    'token',
    'access_token',
    'accessToken',
    'refresh_token',
    'refreshToken',
    'expires_at',
    'expiresAt',
    'devices',
  ];
  for (final k in keys) {
    if (json.containsKey(k)) m[k] = json[k];
  }
  return m;
}

class LoginRequest {
  final String phone; // Changed from username to phone for clarity
  final String password;
  final DeviceInfo device;

  LoginRequest({
    required this.phone,
    required this.password,
    required this.device,
  });

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'password': password, 'device': device.toJson()};
  }
}

class DeviceInfo {
  final String deviceId;
  final String deviceType;
  final String deviceName;
  final String deviceModel;
  final String deviceToken;

  DeviceInfo({
    required this.deviceId,
    required this.deviceType,
    required this.deviceName,
    required this.deviceModel,
    required this.deviceToken,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['device_id'] ?? '',
      deviceType: json['device_type'] ?? '',
      deviceName: json['device_name'] ?? '',
      deviceModel: json['device_model'] ?? '',
      deviceToken: json['device_token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_type': deviceType,
      'device_name': deviceName,
      'device_model': deviceModel,
      'device_token': deviceToken,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({required this.success, required this.message, this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final User user;
  final Session session;

  LoginData({required this.user, required this.session});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'];
    if (userRaw is! Map<String, dynamic>) {
      throw FormatException('LoginData: user must be an object');
    }
    final sessionRaw = json['session'];
    final mergedSession = <String, dynamic>{
      ..._sessionKeysFromLoginPayload(json),
      if (sessionRaw is Map<String, dynamic>) ...sessionRaw,
    };
    return LoginData(
      user: User.fromJson(userRaw),
      session: Session.fromJson(mergedSession),
    );
  }
}

class User {
  final int recordId;
  final String name;
  final String photo;
  final String userName;
  final String password;
  final String description;
  final String createdOn;
  final String createdBy;
  final String updatedOn;
  final String updatedBy;
  final int roleId;
  final String phoneNumber;
  final String email;
  final bool inactive;
  final String? notificationToken;
  final int? institutionId;
  final String? firstLogin;
  final String? lastLogin;
  final String? passwordHash;
  final String? institution;

  User({
    required this.recordId,
    required this.name,
    required this.photo,
    required this.userName,
    required this.password,
    required this.description,
    required this.createdOn,
    required this.createdBy,
    required this.updatedOn,
    required this.updatedBy,
    required this.roleId,
    required this.phoneNumber,
    required this.email,
    required this.inactive,
    this.notificationToken,
    this.institutionId,
    this.firstLogin,
    this.lastLogin,
    this.passwordHash,
    this.institution,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      recordId: json['RecordID'] ?? 0,
      name: json['Name'] ?? '',
      photo: json['Photo'] ?? '',
      userName: json['UserName'] ?? '',
      password: json['Password'] ?? '',
      description: json['Description'] ?? '',
      createdOn: json['CreatedOn'] ?? '',
      createdBy: json['CreatedBy'] ?? '',
      updatedOn: json['UpdatedOn'] ?? '',
      updatedBy: json['UpdatedBy'] ?? '',
      roleId: json['RoleID'] ?? 0,
      phoneNumber: json['PhoneNumber']?.toString() ?? '',
      email: json['email'] ?? '',
      inactive: json['Inactive'] ?? false,
      notificationToken: json['NotificationToken'],
      institutionId: json['InstitutionID'],
      firstLogin: json['FirstLogin'],
      lastLogin: json['LastLogin'],
      passwordHash: json['PasswordHash'],
      institution: json['Institution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RecordID': recordId,
      'Name': name,
      'Photo': photo,
      'UserName': userName,
      'Password': password,
      'Description': description,
      'CreatedOn': createdOn,
      'CreatedBy': createdBy,
      'UpdatedOn': updatedOn,
      'UpdatedBy': updatedBy,
      'RoleID': roleId,
      'PhoneNumber': phoneNumber,
      'email': email,
      'Inactive': inactive,
      'NotificationToken': notificationToken,
      'InstitutionID': institutionId,
      'FirstLogin': firstLogin,
      'LastLogin': lastLogin,
      'PasswordHash': passwordHash,
      'Institution': institution,
    };
  }
}

class Session {
  final String token;
  final String refreshToken;
  final String expiresAt;
  final List<SessionDevice> devices;

  Session({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    required this.devices,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final expires =
        json['expires_at']?.toString() ??
        json['expiresAt']?.toString() ??
        json['access_token_expires_at']?.toString() ??
        '';
    return Session(
      token: _readAccessToken(json),
      refreshToken: _readRefreshToken(json),
      expiresAt: expires,
      devices:
          (json['devices'] as List<dynamic>?)
              ?.map((device) => SessionDevice.fromJson(device))
              .toList() ??
          [],
    );
  }
}

class SessionDevice {
  final String deviceId;
  final String deviceToken;
  final String deviceType;
  final String deviceName;
  final int? studentId;
  final int? classStudentId;

  SessionDevice({
    required this.deviceId,
    required this.deviceToken,
    required this.deviceType,
    required this.deviceName,
    this.studentId,
    this.classStudentId,
  });

  factory SessionDevice.fromJson(Map<String, dynamic> json) {
    return SessionDevice(
      deviceId: json['device_id'] ?? '',
      deviceToken: json['device_token'] ?? '',
      deviceType: json['device_type'] ?? '',
      deviceName: json['device_name'] ?? '',
      studentId: json['student_id'],
      classStudentId: json['class_student_id'],
    );
  }
}

class RefreshTokenResponse {
  final bool success;
  final String message;
  final RefreshTokenData? data;

  RefreshTokenResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? RefreshTokenData.fromJson(json['data'])
          : null,
    );
  }
}

class RefreshTokenData {
  final String token;
  final String refreshToken;
  final String expiresAt;

  RefreshTokenData({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory RefreshTokenData.fromJson(Map<String, dynamic> json) {
    final expires =
        json['expires_at']?.toString() ?? json['expiresAt']?.toString() ?? '';
    return RefreshTokenData(
      token: _readAccessToken(json),
      refreshToken: _readRefreshToken(json),
      expiresAt: expires,
    );
  }
}

class LogoutResponse {
  final bool success;
  final String message;
  final dynamic data;

  LogoutResponse({required this.success, required this.message, this.data});

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

// Forgot Password Models
class ForgotPasswordRequest {
  final String phone;

  ForgotPasswordRequest({required this.phone});

  Map<String, dynamic> toJson() {
    return {'phone': phone};
  }
}

class ForgotPasswordResponse {
  final bool success;
  final String message;
  final dynamic data;

  ForgotPasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class ResetPasswordRequest {
  final String phone;
  final int otp;
  final String password;

  ResetPasswordRequest({
    required this.phone,
    required this.otp,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'otp': otp, 'password': password};
  }
}

class ResetPasswordResponse {
  final bool success;
  final String message;
  final dynamic data;

  ResetPasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}
