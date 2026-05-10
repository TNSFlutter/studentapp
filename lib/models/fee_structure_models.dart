// Models for GET `fee/fee-structure`.

class FeeStructureApiResponse {
  final bool success;
  final String message;
  final FeeStructureData? data;

  FeeStructureApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory FeeStructureApiResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return FeeStructureApiResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: raw is Map<String, dynamic>
          ? FeeStructureData.fromJson(raw)
          : null,
    );
  }
}

class FeeStructureData {
  final int studentId;
  final String studentName;
  final String session;
  final List<FeeStructurePeriod> feePeriods;
  final FeeOverallSummary overallSummary;

  FeeStructureData({
    required this.studentId,
    required this.studentName,
    required this.session,
    required this.feePeriods,
    required this.overallSummary,
  });

  factory FeeStructureData.fromJson(Map<String, dynamic> json) {
    final rawPeriods = json['fee_periods'];
    final periods = <FeeStructurePeriod>[];
    if (rawPeriods is List) {
      for (final e in rawPeriods) {
        if (e is Map<String, dynamic>) {
          periods.add(FeeStructurePeriod.fromJson(e));
        }
      }
    }
    final summaryRaw = json['overall_summary'];
    return FeeStructureData(
      studentId: _asInt(json['student_id']),
      studentName: json['student_name']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      feePeriods: periods,
      overallSummary: summaryRaw is Map<String, dynamic>
          ? FeeOverallSummary.fromJson(summaryRaw)
          : FeeOverallSummary.empty(),
    );
  }
}

class FeeOverallSummary {
  final num totalFeeAmount;
  final num totalPaidAmount;
  final num totalBalanceAmount;
  final String formattedTotalFee;
  final String formattedTotalPaid;
  final String formattedTotalBalance;
  final double overallPaymentPercentage;

  FeeOverallSummary({
    required this.totalFeeAmount,
    required this.totalPaidAmount,
    required this.totalBalanceAmount,
    required this.formattedTotalFee,
    required this.formattedTotalPaid,
    required this.formattedTotalBalance,
    required this.overallPaymentPercentage,
  });

  factory FeeOverallSummary.empty() => FeeOverallSummary(
        totalFeeAmount: 0,
        totalPaidAmount: 0,
        totalBalanceAmount: 0,
        formattedTotalFee: '₹0',
        formattedTotalPaid: '₹0',
        formattedTotalBalance: '₹0',
        overallPaymentPercentage: 0,
      );

  factory FeeOverallSummary.fromJson(Map<String, dynamic> json) {
    return FeeOverallSummary(
      totalFeeAmount: _asNum(json['total_fee_amount']),
      totalPaidAmount: _asNum(json['total_paid_amount']),
      totalBalanceAmount: _asNum(json['total_balance_amount']),
      formattedTotalFee: json['formatted_total_fee']?.toString() ?? '',
      formattedTotalPaid: json['formatted_total_paid']?.toString() ?? '',
      formattedTotalBalance: json['formatted_total_balance']?.toString() ?? '',
      overallPaymentPercentage:
          _asDouble(json['overall_payment_percentage']),
    );
  }
}

class FeeStructurePeriod {
  final int feePeriodId;
  final String feePeriodName;
  final String startDate;
  final String endDate;
  final bool feePeriodSelected;
  final num totalAmount;
  final num totalPaid;
  /// Server-formatted total paid for this period (optional; when empty, UI formats [totalPaid]).
  final String formattedTotalPaid;
  final num balanceAmount;
  final bool isPaid;
  final String paymentStatus;
  final List<FeeAccountHead> accountHeads;

  FeeStructurePeriod({
    required this.feePeriodId,
    required this.feePeriodName,
    required this.startDate,
    required this.endDate,
    required this.feePeriodSelected,
    required this.totalAmount,
    required this.totalPaid,
    this.formattedTotalPaid = '',
    required this.balanceAmount,
    required this.isPaid,
    required this.paymentStatus,
    required this.accountHeads,
  });

  factory FeeStructurePeriod.fromJson(Map<String, dynamic> json) {
    final rawHeads = json['account_heads'];
    final heads = <FeeAccountHead>[];
    if (rawHeads is List) {
      for (final e in rawHeads) {
        if (e is Map<String, dynamic>) {
          heads.add(FeeAccountHead.fromJson(e));
        }
      }
    }
    return FeeStructurePeriod(
      feePeriodId: _asInt(json['fee_period_id']),
      feePeriodName: json['fee_period_name']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      feePeriodSelected: json['fee_period_selected'] == true,
      totalAmount: _asNum(json['total_amount']),
      totalPaid: _asNum(json['total_paid']),
      formattedTotalPaid: json['formatted_total_paid']?.toString() ?? '',
      balanceAmount: _asNum(json['balance_amount']),
      isPaid: json['is_paid'] == true,
      paymentStatus: json['payment_status']?.toString() ?? '',
      accountHeads: heads,
    );
  }

  /// Badge text e.g. APR, MAY (first 3 letters of period name).
  String get monthCode {
    final n = feePeriodName.trim();
    if (n.isEmpty) return '--';
    return n.length >= 3
        ? n.substring(0, 3).toUpperCase()
        : n.toUpperCase();
  }
}

class FeeAccountHead {
  final int studentFeeAccountId;
  final int accountHeadId;
  final String accountHeadName;
  final String amount;
  final String netPayableAmount;
  final String concession;
  final String fine;
  final String? description;
  final String? paymentDate;
  final bool isPaid;
  final String debitAmount;
  final dynamic pendingAmountRaw;
  final String formattedAmount;
  final String formattedNetPayable;
  final String formattedConcession;
  final String formattedFine;
  final String formattedDebitAmount;
  final String formattedPendingAmount;

  FeeAccountHead({
    required this.studentFeeAccountId,
    required this.accountHeadId,
    required this.accountHeadName,
    required this.amount,
    required this.netPayableAmount,
    required this.concession,
    required this.fine,
    this.description,
    this.paymentDate,
    required this.isPaid,
    required this.debitAmount,
    required this.pendingAmountRaw,
    required this.formattedAmount,
    required this.formattedNetPayable,
    required this.formattedConcession,
    required this.formattedFine,
    required this.formattedDebitAmount,
    required this.formattedPendingAmount,
  });

  factory FeeAccountHead.fromJson(Map<String, dynamic> json) {
    return FeeAccountHead(
      studentFeeAccountId: _asInt(json['student_fee_account_id']),
      accountHeadId: _asInt(json['account_head_id']),
      accountHeadName: json['account_head_name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      netPayableAmount: json['net_payable_amount']?.toString() ?? '0',
      concession: json['concession']?.toString() ?? '0',
      fine: json['fine']?.toString() ?? '0',
      description: json['description']?.toString(),
      paymentDate: json['payment_date']?.toString(),
      isPaid: json['is_paid'] == true,
      debitAmount: json['debit_amount']?.toString() ?? '0',
      pendingAmountRaw: json['pending_amount'],
      formattedAmount: json['formatted_amount']?.toString() ?? '',
      formattedNetPayable: json['formatted_net_payable']?.toString() ?? '',
      formattedConcession: json['formatted_concession']?.toString() ?? '',
      formattedFine: json['formatted_fine']?.toString() ?? '',
      formattedDebitAmount: json['formatted_debit_amount']?.toString() ?? '',
      formattedPendingAmount:
          json['formatted_pending_amount']?.toString() ?? '',
    );
  }

  /// Best label to show when [isPaid] is true (amount actually received / credited).
  String get displayAmountWhenPaid {
    final debit = formattedDebitAmount.trim();
    if (debit.isNotEmpty) return debit;
    final net = formattedNetPayable.trim();
    if (net.isNotEmpty) return net;
    final amt = formattedAmount.trim();
    if (amt.isNotEmpty) return amt;
    return amount;
  }
}

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? fallback;
}

double _asDouble(dynamic v, {double fallback = 0}) {
  if (v == null) return fallback;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? fallback;
}

num _asNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? 0;
}
