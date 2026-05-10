class FeePaymentConfig {
  final bool enabled;
  final String gateway;
  final String keyId;
  final String mode;
  final bool isLive;
  final bool showPayButton;
  final String schoolName;
  final String currency;

  const FeePaymentConfig({
    required this.enabled,
    required this.gateway,
    required this.keyId,
    required this.mode,
    required this.isLive,
    required this.showPayButton,
    required this.schoolName,
    required this.currency,
  });

  factory FeePaymentConfig.fromJson(Map<String, dynamic> json) => FeePaymentConfig(
        enabled: json['enabled'] == true,
        gateway: json['gateway']?.toString() ?? '',
        keyId: json['key_id']?.toString() ?? '',
        mode: json['mode']?.toString() ?? '',
        isLive: json['is_live'] == true,
        showPayButton: json['show_pay_button'] == true,
        schoolName: json['school_name']?.toString() ?? '',
        currency: json['currency']?.toString() ?? 'INR',
      );
}

class FeePaymentConfigResponse {
  final bool success;
  final String message;
  final FeePaymentConfig? data;

  const FeePaymentConfigResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FeePaymentConfigResponse.fromJson(Map<String, dynamic> json) =>
      FeePaymentConfigResponse(
        success: json['success'] == true,
        message: json['message']?.toString() ?? '',
        data: json['data'] is Map<String, dynamic>
            ? FeePaymentConfig.fromJson(json['data'] as Map<String, dynamic>)
            : json['data'] is Map
                ? FeePaymentConfig.fromJson(
                    Map<String, dynamic>.from(json['data'] as Map),
                  )
                : null,
      );

  factory FeePaymentConfigResponse.failure(String message) =>
      FeePaymentConfigResponse(success: false, message: message, data: null);
}

class FeeInitiatePaymentData {
  final String initiatedId;
  final String orderId;
  final String amount;
  final Map<String, dynamic> raw;

  const FeeInitiatePaymentData({
    required this.initiatedId,
    required this.orderId,
    required this.amount,
    required this.raw,
  });

  factory FeeInitiatePaymentData.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
      return '';
    }

    return FeeInitiatePaymentData(
      initiatedId: pick(['InitiatedID', 'Initiated', 'initiated_id', 'id', 'result']),
      orderId: pick(['OrderID', 'order_id']),
      amount: pick(['Amount', 'amount', 'PGAmount']),
      raw: Map<String, dynamic>.from(json),
    );
  }
}

class FeeInitiatePaymentResponse {
  final bool success;
  final String message;
  final FeeInitiatePaymentData? data;

  const FeeInitiatePaymentResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FeeInitiatePaymentResponse.fromJson(Map<String, dynamic> json) =>
      FeeInitiatePaymentResponse(
        success: json['success'] == true,
        message: json['message']?.toString() ?? '',
        data: json['data'] is Map<String, dynamic>
            ? FeeInitiatePaymentData.fromJson(json['data'] as Map<String, dynamic>)
            : json['data'] is Map
                ? FeeInitiatePaymentData.fromJson(
                    Map<String, dynamic>.from(json['data'] as Map),
                  )
                : null,
      );

  factory FeeInitiatePaymentResponse.failure(String message) =>
      FeeInitiatePaymentResponse(success: false, message: message, data: null);
}

class FeeUpdatePaymentResponse {
  final bool success;
  final String message;
  /// Echo of `InitiatedID` from some API versions (e.g. `"602"`).
  final String? result;
  final Map<String, dynamic>? data;

  const FeeUpdatePaymentResponse({
    required this.success,
    required this.message,
    this.result,
    required this.data,
  });

  factory FeeUpdatePaymentResponse.fromJson(Map<String, dynamic> json) =>
      FeeUpdatePaymentResponse(
        success: json['success'] == true,
        message: json['message']?.toString() ?? '',
        result: json['result']?.toString(),
        data: json['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['data'] as Map<String, dynamic>)
            : json['data'] is Map
                ? Map<String, dynamic>.from(json['data'] as Map)
                : null,
      );

  factory FeeUpdatePaymentResponse.failure(String message) =>
      FeeUpdatePaymentResponse(
        success: false,
        message: message,
        result: null,
        data: null,
      );
}
