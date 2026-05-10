// `GET auth/sessions` — linked login sessions for the parent account.

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

class AuthSessionItem {
  final int sessionId;
  final String deviceId;
  final String deviceType;
  final String? deviceName;
  final DateTime? lastActive;
  final DateTime? expiresAt;

  AuthSessionItem({
    required this.sessionId,
    required this.deviceId,
    required this.deviceType,
    this.deviceName,
    this.lastActive,
    this.expiresAt,
  });

  factory AuthSessionItem.fromJson(Map<String, dynamic> json) {
    final nameRaw = json['device_name']?.toString().trim();
    return AuthSessionItem(
      sessionId: _asInt(json['session_id']),
      deviceId: json['device_id']?.toString().trim() ?? '',
      deviceType: (json['device_type'] ?? '').toString().toLowerCase().trim(),
      deviceName: (nameRaw == null || nameRaw.isEmpty) ? null : nameRaw,
      lastActive: DateTime.tryParse(json['last_active']?.toString() ?? ''),
      expiresAt: DateTime.tryParse(json['expires_at']?.toString() ?? ''),
    );
  }
}

class AuthSessionsApiResult {
  final bool success;
  final String message;
  final List<AuthSessionItem> sessions;

  AuthSessionsApiResult({
    required this.success,
    required this.message,
    required this.sessions,
  });

  factory AuthSessionsApiResult.fromJson(Map<String, dynamic> json) {
    final list = <AuthSessionItem>[];
    final raw = json['data'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(AuthSessionItem.fromJson(e));
        } else if (e is Map) {
          list.add(AuthSessionItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return AuthSessionsApiResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      sessions: list,
    );
  }
}
