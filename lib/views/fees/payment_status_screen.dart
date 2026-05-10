import 'package:flutter/material.dart';

import 'fee_payment_result_screen.dart';

/// Legacy route used by [PayFeeScreen]; shows the standard payment success layout.
class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeePaymentResultScreen(
      isSuccess: true,
    );
  }
}
