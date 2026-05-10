int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}

String _toStr(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _toNullableStr(dynamic value) {
  final t = _toStr(value).trim();
  return t.isEmpty ? null : t;
}

class OutpassItem {
  final int id;
  final String status;
  final String? reason;
  final String? outDateTime;
  final String? formattedOut;
  final String? contactNo;
  final String? relation;
  final String? visitors;
  final String? description;
  final String? address;
  final String? documentUrl;
  final String? approvedBy;
  final String? approvedOn;
  final String? remarks;
  final bool hasQr;
  final String? createdOn;

  OutpassItem({
    required this.id,
    required this.status,
    this.reason,
    this.outDateTime,
    this.formattedOut,
    this.contactNo,
    this.relation,
    this.visitors,
    this.description,
    this.address,
    this.documentUrl,
    this.approvedBy,
    this.approvedOn,
    this.remarks,
    this.hasQr = false,
    this.createdOn,
  });

  factory OutpassItem.fromJson(Map<String, dynamic> json) {
    return OutpassItem(
      id: _toInt(json['id']),
      status: _toNullableStr(json['status']) ?? 'Pending',
      reason: _toNullableStr(json['reason']),
      outDateTime: _toNullableStr(json['out_date_time']),
      formattedOut: _toNullableStr(json['formatted_out']),
      contactNo: _toNullableStr(json['contact_no']),
      relation: _toNullableStr(json['relation']),
      visitors: _toNullableStr(json['visitors']),
      description: _toNullableStr(json['description']),
      address: _toNullableStr(json['address']),
      documentUrl: _toNullableStr(json['document_url']),
      approvedBy: _toNullableStr(json['approved_by']),
      approvedOn: _toNullableStr(json['approved_on']),
      remarks: _toNullableStr(json['remarks']),
      hasQr: json['has_qr'] == true,
      createdOn: _toNullableStr(json['created_on']),
    );
  }
}

class OutpassPagination {
  final int total;
  final int limit;
  final String? nextCursor;
  final bool hasNextPage;

  const OutpassPagination({
    required this.total,
    required this.limit,
    required this.nextCursor,
    required this.hasNextPage,
  });

  factory OutpassPagination.empty() => const OutpassPagination(
        total: 0,
        limit: 10,
        nextCursor: null,
        hasNextPage: false,
      );

  factory OutpassPagination.fromJson(Map<String, dynamic> json) => OutpassPagination(
        total: _toInt(json['total']),
        limit: _toInt(json['limit'], fallback: 10),
        nextCursor: _toNullableStr(json['next_cursor']),
        hasNextPage: json['has_next_page'] == true,
      );
}

class OutpassListResponse {
  final bool success;
  final String message;
  final List<OutpassItem> data;
  final OutpassPagination pagination;

  OutpassListResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory OutpassListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = <OutpassItem>[];
    if (rawData is List) {
      for (final e in rawData) {
        if (e is Map<String, dynamic>) {
          items.add(OutpassItem.fromJson(e));
        } else if (e is Map) {
          items.add(OutpassItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final rawPagination = json['pagination'];
    final pagination = rawPagination is Map<String, dynamic>
        ? OutpassPagination.fromJson(rawPagination)
        : rawPagination is Map
            ? OutpassPagination.fromJson(Map<String, dynamic>.from(rawPagination))
            : OutpassPagination.empty();
    return OutpassListResponse(
      success: json['success'] == true,
      message: _toStr(json['message']),
      data: items,
      pagination: pagination,
    );
  }

  factory OutpassListResponse.failure(String message) => OutpassListResponse(
        success: false,
        message: message,
        data: const [],
        pagination: OutpassPagination.empty(),
      );
}

class OutpassDetailResponse {
  final bool success;
  final String message;
  final OutpassItem? data;

  OutpassDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OutpassDetailResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return OutpassDetailResponse(
      success: json['success'] == true,
      message: _toStr(json['message']),
      data: raw is Map<String, dynamic>
          ? OutpassItem.fromJson(raw)
          : raw is Map
              ? OutpassItem.fromJson(Map<String, dynamic>.from(raw))
              : null,
    );
  }

  factory OutpassDetailResponse.failure(String message) => OutpassDetailResponse(
        success: false,
        message: message,
        data: null,
      );
}

class OutpassReason {
  final int id;
  final String name;

  const OutpassReason({required this.id, required this.name});

  factory OutpassReason.fromJson(Map<String, dynamic> json) => OutpassReason(
        id: _toInt(json['id']),
        name: _toStr(json['name']),
      );
}

class OutpassReasonsResponse {
  final bool success;
  final String message;
  final List<OutpassReason> data;

  OutpassReasonsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OutpassReasonsResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final reasons = <OutpassReason>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          reasons.add(OutpassReason.fromJson(e));
        } else if (e is Map) {
          reasons.add(OutpassReason.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return OutpassReasonsResponse(
      success: json['success'] == true,
      message: _toStr(json['message']),
      data: reasons,
    );
  }

  factory OutpassReasonsResponse.failure(String message) => OutpassReasonsResponse(
        success: false,
        message: message,
        data: const [],
      );
}

class OutpassActionResponse {
  final bool success;
  final String message;
  final OutpassItem? data;

  OutpassActionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory OutpassActionResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    return OutpassActionResponse(
      success: json['success'] == true,
      message: _toStr(json['message']),
      data: raw is Map<String, dynamic>
          ? OutpassItem.fromJson(raw)
          : raw is Map
              ? OutpassItem.fromJson(Map<String, dynamic>.from(raw))
              : null,
    );
  }

  factory OutpassActionResponse.failure(String message) => OutpassActionResponse(
        success: false,
        message: message,
      );
}
