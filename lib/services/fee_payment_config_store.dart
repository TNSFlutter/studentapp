import '../models/fee_payment_gateway_models.dart';

class FeePaymentConfigStore {
  FeePaymentConfigStore._();
  static FeePaymentConfig? _config;

  static FeePaymentConfig? get config => _config;
  static void setConfig(FeePaymentConfig? config) => _config = config;
}
