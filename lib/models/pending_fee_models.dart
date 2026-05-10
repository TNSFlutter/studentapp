// Response for `GET student/pending-fee?limit=&cursor=`

int _asInt(dynamic v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

num _asNum(dynamic v, {num fallback = 0}) {
  if (v == null) return fallback;
  if (v is num) return v;
  return num.tryParse(v.toString()) ?? fallback;
}

class PendingFeePagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;
  final bool hasPrevPage;

  PendingFeePagination({
    required this.total,
    required this.limit,
    this.nextCursor,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PendingFeePagination.empty() => PendingFeePagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
        hasPrevPage: false,
      );

  factory PendingFeePagination.fromJson(Map<String, dynamic> json) {
    return PendingFeePagination(
      total: _asInt(json['total']),
      limit: _asInt(json['limit'], fallback: 10),
      nextCursor: json['next_cursor']?.toString(),
      hasNextPage: json['has_next_page'] == true,
      hasPrevPage: json['has_prev_page'] == true,
    );
  }
}

class PendingFeeAccountHead {
  final int accountHeadId;
  final String accountHeadName;
  final String amount;
  final bool isPaid;
  final int feePeriodId;
  final String feePeriodName;

  PendingFeeAccountHead({
    required this.accountHeadId,
    required this.accountHeadName,
    required this.amount,
    required this.isPaid,
    required this.feePeriodId,
    required this.feePeriodName,
  });

  String get dedupeKey => '$accountHeadId|$feePeriodId';

  num get amountAsNum => num.tryParse(amount) ?? 0;

  factory PendingFeeAccountHead.fromJson(Map<String, dynamic> json) {
    return PendingFeeAccountHead(
      accountHeadId: _asInt(json['account_head_id']),
      accountHeadName: json['account_head_name']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0',
      isPaid: json['is_paid'] == true,
      feePeriodId: _asInt(json['fee_period_id']),
      feePeriodName: json['fee_period_name']?.toString() ?? '',
    );
  }
}

class PendingFeeData {
  final int studentId;
  final int feePeriodId;
  final String feePeriodName;
  final List<int> feePeriodIds;
  final num pendingFee;
  final bool isPaid;
  final String? paymentMode;
  final List<PendingFeeAccountHead> accountHeads;

  PendingFeeData({
    required this.studentId,
    required this.feePeriodId,
    required this.feePeriodName,
    required this.feePeriodIds,
    required this.pendingFee,
    required this.isPaid,
    this.paymentMode,
    required this.accountHeads,
  });

  factory PendingFeeData.fromJson(Map<String, dynamic> json) {
    final idsRaw = json['fee_period_ids'];
    final ids = <int>[];
    if (idsRaw is List) {
      for (final e in idsRaw) {
        ids.add(_asInt(e));
      }
    }
    final headsRaw = json['account_heads'];
    final heads = <PendingFeeAccountHead>[];
    if (headsRaw is List) {
      for (final e in headsRaw) {
        if (e is Map<String, dynamic>) {
          heads.add(PendingFeeAccountHead.fromJson(e));
        } else if (e is Map) {
          heads.add(
            PendingFeeAccountHead.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    return PendingFeeData(
      studentId: _asInt(json['student_id']),
      feePeriodId: _asInt(json['fee_period_id']),
      feePeriodName: json['fee_period_name']?.toString() ?? '',
      feePeriodIds: ids,
      pendingFee: _asNum(json['pending_fee']),
      isPaid: json['is_paid'] == true,
      paymentMode: json['payment_mode']?.toString(),
      accountHeads: heads,
    );
  }
}

class PendingFeeApiResponse {
  final bool success;
  final String message;
  final PendingFeeData? data;
  final PendingFeePagination pagination;

  PendingFeeApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.pagination,
  });

  factory PendingFeeApiResponse.fromJson(Map<String, dynamic> json) {
    final dRaw = json['data'];
    final pRaw = json['pagination'];
    return PendingFeeApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dRaw is Map
          ? PendingFeeData.fromJson(Map<String, dynamic>.from(dRaw))
          : null,
      pagination: pRaw is Map
          ? PendingFeePagination.fromJson(Map<String, dynamic>.from(pRaw))
          : PendingFeePagination.empty(),
    );
  }
}
