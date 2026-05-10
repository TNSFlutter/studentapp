import 'fee_structure_models.dart';

// GET fee/details/{feePeriodId}

class FeePeriodDetailApiResponse {
  final bool success;
  final String message;
  final FeePeriodDetailPayload? data;

  FeePeriodDetailApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory FeePeriodDetailApiResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return FeePeriodDetailApiResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: raw is Map<String, dynamic>
          ? FeePeriodDetailPayload.fromJson(raw)
          : null,
    );
  }
}

class FeePeriodDetailPayload {
  final FeePeriodDetailBlock feePeriod;
  final FeeStudentBrief student;
  final FeePaymentSummary paymentSummary;
  final List<FeeAccountHead> accountHeads;
  final List<Map<String, dynamic>> paymentsRaw;

  FeePeriodDetailPayload({
    required this.feePeriod,
    required this.student,
    required this.paymentSummary,
    required this.accountHeads,
    required this.paymentsRaw,
  });

  factory FeePeriodDetailPayload.fromJson(Map<String, dynamic> json) {
    final fp = json['fee_period'];
    final st = json['student'];
    final ps = json['payment_summary'];
    final heads = json['account_heads'];
    final pay = json['payments'];

    final accountHeads = <FeeAccountHead>[];
    if (heads is List) {
      for (final e in heads) {
        if (e is Map<String, dynamic>) {
          accountHeads.add(FeeAccountHead.fromJson(e));
        }
      }
    }

    final paymentsList = <Map<String, dynamic>>[];
    if (pay is List) {
      for (final e in pay) {
        if (e is Map<String, dynamic>) {
          paymentsList.add(Map<String, dynamic>.from(e));
        }
      }
    }

    return FeePeriodDetailPayload(
      feePeriod: fp is Map<String, dynamic>
          ? FeePeriodDetailBlock.fromJson(fp)
          : FeePeriodDetailBlock.empty(),
      student: st is Map<String, dynamic>
          ? FeeStudentBrief.fromJson(st)
          : FeeStudentBrief.empty(),
      paymentSummary: ps is Map<String, dynamic>
          ? FeePaymentSummary.fromJson(ps)
          : FeePaymentSummary.empty(),
      accountHeads: accountHeads,
      paymentsRaw: paymentsList,
    );
  }
}

class FeePeriodDetailBlock {
  final int id;
  final String name;
  final String startDate;
  final String endDate;
  final String description;

  FeePeriodDetailBlock({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
  });

  factory FeePeriodDetailBlock.empty() => FeePeriodDetailBlock(
        id: 0,
        name: '',
        startDate: '',
        endDate: '',
        description: '',
      );

  factory FeePeriodDetailBlock.fromJson(Map<String, dynamic> json) {
    return FeePeriodDetailBlock(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }
}

class FeeStudentBrief {
  final int studentId;
  final String name;

  FeeStudentBrief({required this.studentId, required this.name});

  factory FeeStudentBrief.empty() =>
      FeeStudentBrief(studentId: 0, name: '');

  factory FeeStudentBrief.fromJson(Map<String, dynamic> json) {
    return FeeStudentBrief(
      studentId: _asInt(json['student_id']),
      name: json['name']?.toString() ?? '',
    );
  }
}

class FeePaymentSummary {
  final num totalAmount;
  final num paidAmount;
  final num pendingAmount;
  final String paymentStatus;
  final double paymentPercentage;
  final bool isPaid;
  final String formattedTotal;
  final String formattedPaid;
  final String formattedPending;

  FeePaymentSummary({
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.paymentStatus,
    required this.paymentPercentage,
    required this.isPaid,
    required this.formattedTotal,
    required this.formattedPaid,
    required this.formattedPending,
  });

  factory FeePaymentSummary.empty() => FeePaymentSummary(
        totalAmount: 0,
        paidAmount: 0,
        pendingAmount: 0,
        paymentStatus: '',
        paymentPercentage: 0,
        isPaid: false,
        formattedTotal: '',
        formattedPaid: '',
        formattedPending: '',
      );

  factory FeePaymentSummary.fromJson(Map<String, dynamic> json) {
    return FeePaymentSummary(
      totalAmount: _asNum(json['total_amount']),
      paidAmount: _asNum(json['paid_amount']),
      pendingAmount: _asNum(json['pending_amount']),
      paymentStatus: json['payment_status']?.toString() ?? '',
      paymentPercentage: _asDouble(json['payment_percentage']),
      isPaid: json['is_paid'] == true,
      formattedTotal: json['formatted_total']?.toString() ?? '',
      formattedPaid: json['formatted_paid']?.toString() ?? '',
      formattedPending: json['formatted_pending']?.toString() ?? '',
    );
  }
}

// GET fee/payment-history

class FeePaymentHistoryApiResponse {
  final bool success;
  final String message;
  final List<FeePaymentHistoryItem> data;
  final FeePaymentHistoryPagination pagination;

  FeePaymentHistoryApiResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory FeePaymentHistoryApiResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final list = <FeePaymentHistoryItem>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(FeePaymentHistoryItem.fromJson(e));
        }
      }
    }
    final pRaw = json['pagination'];
    return FeePaymentHistoryApiResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: list,
      pagination: pRaw is Map<String, dynamic>
          ? FeePaymentHistoryPagination.fromJson(pRaw)
          : FeePaymentHistoryPagination.empty(),
    );
  }
}

class FeePaymentHistoryPagination {
  final int total;
  final int limit;
  final int offset;
  final int currentPage;
  final int lastPage;
  final int from;
  final int to;
  final bool hasNextPage;
  final bool hasPrevPage;

  FeePaymentHistoryPagination({
    required this.total,
    required this.limit,
    required this.offset,
    required this.currentPage,
    required this.lastPage,
    required this.from,
    required this.to,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory FeePaymentHistoryPagination.empty() =>
      FeePaymentHistoryPagination(
        total: 0,
        limit: 10,
        offset: 0,
        currentPage: 1,
        lastPage: 1,
        from: 0,
        to: 0,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory FeePaymentHistoryPagination.fromJson(Map<String, dynamic> json) {
    return FeePaymentHistoryPagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      offset: _asInt(json['offset']),
      currentPage: _asInt(json['current_page'], fallback: 1),
      lastPage: _asInt(json['last_page'], fallback: 1),
      from: _asInt(json['from']),
      to: _asInt(json['to']),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class FeePaymentHistoryItem {
  final int id;
  final int receiptNo;
  final String paymentAmount;
  final String paymentDate;
  final String paymentMode;
  final String discount;
  final String discountDescription;
  final String description;
  final String payableAmount;
  final String? totalPayableAmount;
  final Map<String, dynamic>? feePeriods;
  final String feePeriodIds;
  final String studentFeesAccountIds;
  final int bank;
  final String chequeNo;
  final String posReceiptNo;
  final String? transactionStatus;
  final String? referenceId;
  final String createdBy;
  final String createdOn;
  final String studentName;
  final String classSection;
  final String formattedPaymentDate;
  final String formattedAmount;
  final bool isOnlinePayment;
  final String paymentStatus;

  FeePaymentHistoryItem({
    required this.id,
    required this.receiptNo,
    required this.paymentAmount,
    required this.paymentDate,
    required this.paymentMode,
    required this.discount,
    required this.discountDescription,
    required this.description,
    required this.payableAmount,
    this.totalPayableAmount,
    this.feePeriods,
    required this.feePeriodIds,
    required this.studentFeesAccountIds,
    required this.bank,
    required this.chequeNo,
    required this.posReceiptNo,
    this.transactionStatus,
    this.referenceId,
    required this.createdBy,
    required this.createdOn,
    required this.studentName,
    required this.classSection,
    required this.formattedPaymentDate,
    required this.formattedAmount,
    required this.isOnlinePayment,
    required this.paymentStatus,
  });

  factory FeePaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? fp;
    final fpRaw = json['fee_periods'];
    if (fpRaw is Map<String, dynamic>) {
      fp = Map<String, dynamic>.from(fpRaw);
    }

    return FeePaymentHistoryItem(
      id: _asInt(json['id']),
      receiptNo: _asInt(json['receipt_no']),
      paymentAmount: json['payment_amount']?.toString() ?? '',
      paymentDate: json['payment_date']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      discount: json['discount']?.toString() ?? '',
      discountDescription: json['discount_description']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      payableAmount: json['payable_amount']?.toString() ?? '',
      totalPayableAmount: json['total_payable_amount']?.toString(),
      feePeriods: fp,
      feePeriodIds: json['fee_period_ids']?.toString() ?? '',
      studentFeesAccountIds:
          json['student_fees_account_ids']?.toString() ?? '',
      bank: _asInt(json['bank']),
      chequeNo: json['cheque_no']?.toString() ?? '',
      posReceiptNo: json['pos_receipt_no']?.toString() ?? '',
      transactionStatus: json['transaction_status']?.toString(),
      referenceId: json['reference_id']?.toString(),
      createdBy: json['created_by']?.toString() ?? '',
      createdOn: json['created_on']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      classSection: json['class_section']?.toString() ?? '',
      formattedPaymentDate: json['formatted_payment_date']?.toString() ?? '',
      formattedAmount: json['formatted_amount']?.toString() ?? '',
      isOnlinePayment: json['is_online_payment'] == true,
      paymentStatus: json['payment_status']?.toString() ?? '',
    );
  }

  String get feePeriodsLabel {
    if (feePeriods == null || feePeriods!.isEmpty) return '';
    return feePeriods!.values.join(', ');
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
