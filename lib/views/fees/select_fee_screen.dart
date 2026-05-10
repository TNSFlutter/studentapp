import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'dart:math';

import '../../constants/app_colors.dart';
import '../../helpers/app_navigation.dart';
import '../../controllers/fee_controller.dart';
import '../../models/fee_payment_gateway_models.dart';
import '../../models/fee_structure_models.dart';
import '../../models/pending_fee_models.dart';
import '../../services/fee_payment_config_store.dart';
import '../../widgets/common_app_bar.dart';
import 'fee_payment_result_screen.dart';
import 'view_detail_screen.dart';

class SelectFeeScreen extends StatefulWidget {
  const SelectFeeScreen({super.key});

  @override
  State<SelectFeeScreen> createState() => _SelectFeeScreenState();
}

class _SelectFeeScreenState extends State<SelectFeeScreen> {
  static const int _pageSize = 6;

  /// `POST fee/update-payment` body field [Type] — matches backend contract sample.
  static const String _feeUpdatePaymentType = 'CashFreeResponse';

  final FeeController _feeController = FeeController();

  FeeStructureData? _data;
  bool _loading = true;
  String? _errorMessage;

  PendingFeeData? _pendingFee;
  bool _pendingLoading = false;
  String? _pendingError;
  final Razorpay _razorpay = Razorpay();
  final Map<int, FeeAccountHead> _unpaidHeadsByStudentAccountId = {};
  final Set<int> _selectedStudentAccountIds = <int>{};
  bool _paying = false;
  String _lastInitiatedId = '';
  String _lastOrderId = '';
  String _lastAmount = '0';
  Timer? _paymentWatchdog;
  final ScrollController _scrollController = ScrollController();
  bool _expandingPeriodPage = false;

  /// Client-side pagination over `fee_periods` (API returns full list).
  int _visiblePeriodCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    _loadFeeStructure();
    _loadPendingFee();
    _scrollController.addListener(_onScrollForPeriodPagination);
  }

  @override
  void dispose() {
    _paymentWatchdog?.cancel();
    _scrollController.removeListener(_onScrollForPeriodPagination);
    _scrollController.dispose();
    // Clear listeners first so no new native callbacks are delivered to this State.
    _razorpay.clear();
    // Do not call [_feeController.dispose] here: Razorpay may still invoke
    // success/error handlers asynchronously after checkout closes; disposing
    // the controller mid-flight caused crashes in production.
    super.dispose();
  }

  Future<void> _loadFeeStructure() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final parsed = await _feeController.fetchFeeStructure();

    if (!mounted) return;

    if (parsed.success && parsed.data != null) {
      final d = parsed.data!;
      final unpaid = <int, FeeAccountHead>{};
      final defaultSelected = <int>{};
      for (final p in d.feePeriods) {
        for (final h in p.accountHeads) {
          if (!h.isPaid) {
            unpaid[h.studentFeeAccountId] = h;
            if (p.feePeriodSelected) {
              defaultSelected.add(h.studentFeeAccountId);
            }
          }
        }
      }
      setState(() {
        _data = d;
        _unpaidHeadsByStudentAccountId
          ..clear()
          ..addAll(unpaid);
        _selectedStudentAccountIds
          ..clear()
          ..addAll(defaultSelected);
        _visiblePeriodCount =
            d.feePeriods.length < _pageSize ? d.feePeriods.length : _pageSize;
        _loading = false;
      });
      return;
    }

    setState(() {
      _errorMessage =
          parsed.message.isNotEmpty ? parsed.message : 'Unable to load fees.';
      _loading = false;
    });
  }

  Future<void> _loadPendingFee() async {
    if (!mounted) return;
    setState(() {
      _pendingLoading = true;
      _pendingError = null;
    });
    final parsed = await _feeController.fetchPendingFee(limit: 10);
    if (!mounted) return;
    if (parsed.success && parsed.data != null) {
      setState(() {
        _pendingFee = parsed.data;
        _pendingError = null;
        _pendingLoading = false;
      });
      return;
    }
    setState(() {
      _pendingFee = null;
      _pendingError = parsed.message.isNotEmpty
          ? parsed.message
          : 'Could not load pending fee.';
      _pendingLoading = false;
    });
  }

  void _loadMorePeriods() {
    final data = _data;
    if (data == null || _expandingPeriodPage) return;
    _expandingPeriodPage = true;
    setState(() {
      final next = _visiblePeriodCount + _pageSize;
      _visiblePeriodCount = next > data.feePeriods.length
          ? data.feePeriods.length
          : next;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expandingPeriodPage = false;
    });
  }

  void _onScrollForPeriodPagination() {
    if (!_scrollController.hasClients || !_hasMorePeriods) return;
    final pos = _scrollController.position;
    if (pos.pixels >= (pos.maxScrollExtent - 220)) {
      _loadMorePeriods();
    }
  }

  List<FeeStructurePeriod> get _visiblePeriods {
    final data = _data;
    if (data == null) return [];
    final end = _visiblePeriodCount.clamp(0, data.feePeriods.length);
    return data.feePeriods.sublist(0, end);
  }

  bool get _hasMorePeriods {
    final data = _data;
    if (data == null) return false;
    return _visiblePeriodCount < data.feePeriods.length;
  }

  static String _periodDateRange(FeeStructurePeriod p) {
    final s = DateTime.tryParse(p.startDate)?.toLocal();
    final e = DateTime.tryParse(p.endDate)?.toLocal();
    if (s == null) return '';
    final full = DateFormat('d MMM yyyy');
    if (e == null) return full.format(s);
    return '${DateFormat('d MMM').format(s)} – ${full.format(e)}';
  }

  static String _formatBalance(num n) {
    final fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return fmt.format(n);
  }

  num _pendingAmountFromHead(FeeAccountHead h) {
    final raw = h.pendingAmountRaw;
    if (raw is num) return raw;
    if (raw != null) {
      final parsed = num.tryParse(raw.toString());
      if (parsed != null) return parsed;
    }
    final formatted = h.formattedPendingAmount.replaceAll(RegExp(r'[^0-9.-]'), '');
    final fp = num.tryParse(formatted);
    if (fp != null) return fp;
    final np = num.tryParse(h.netPayableAmount);
    if (np != null) return np;
    return 0;
  }

  num get _selectedAmount => _selectedStudentAccountIds.fold<num>(
        0,
        (sum, id) => sum + _pendingAmountFromHead(_unpaidHeadsByStudentAccountId[id]!),
      );

  Future<FeePaymentConfig?> _ensurePaymentConfig() async {
    final cached = FeePaymentConfigStore.config;
    if (cached != null) return cached;
    final res = await _feeController.fetchPaymentConfig();
    return res.success ? res.data : null;
  }

  String _generateOrderId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random().nextInt(9000) + 1000;
    return '$now$rnd';
  }

  int _toPaise(String? amount, {required int fallback}) {
    if (amount == null || amount.trim().isEmpty) return fallback;
    final parsed = num.tryParse(amount.trim());
    if (parsed == null || parsed <= 0) return fallback;
    return (parsed * 100).round();
  }

  Future<bool> _isIosSimulator() async {
    if (!Platform.isIOS) return false;
    try {
      final info = await DeviceInfoPlugin().iosInfo;
      return !info.isPhysicalDevice;
    } catch (_) {
      return false;
    }
  }

  Future<void> _startPayment() async {
    if (_paying) return;
    if (_selectedStudentAccountIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_fee_select_month'.tr)),
      );
      return;
    }
    final amountNum = _selectedAmount;
    if (amountNum <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_fee_amount_gt_zero'.tr)),
      );
      return;
    }

    setState(() => _paying = true);
    final config = await _ensurePaymentConfig();
    if (!mounted) return;
    if (config == null || !config.enabled || !config.showPayButton) {
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_fee_online_disabled'.tr)),
      );
      return;
    }
    if (config.gateway.toLowerCase() != 'razorpay' || config.keyId.trim().isEmpty) {
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('select_fee_razorpay_missing'.tr)),
      );
      return;
    }

    final orderId = _generateOrderId();
    final amountRounded = amountNum.round().toString();
    final csv = _selectedStudentAccountIds.join(', ');

    final initiate = await _feeController.initiatePayment(
      studentAccountIdCsv: csv,
      orderId: orderId,
      amount: amountRounded,
    );

    if (!mounted) return;
    if (!initiate.success) {
      _paymentWatchdog?.cancel();
      setState(() => _paying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(initiate.message)),
      );
      return;
    }

    _lastInitiatedId = initiate.data?.initiatedId ?? '';
    _lastOrderId = (initiate.data?.orderId.isNotEmpty ?? false)
        ? initiate.data!.orderId
        : orderId;
    _lastAmount = (initiate.data?.amount.isNotEmpty ?? false)
        ? initiate.data!.amount
        : amountRounded;
    final checkoutAmountPaise = _toPaise(
      initiate.data?.amount,
      fallback: amountNum.round() * 100,
    );
    final iosSimulator = await _isIosSimulator();
    if (!mounted) return;

    final options = <String, dynamic>{
      'key': config.keyId,
      'amount': checkoutAmountPaise,
      'name': config.schoolName.isNotEmpty ? config.schoolName : 'fees_payment_label'.tr,
      'description': 'fees_payment_label'.tr,
      'currency': config.currency.isNotEmpty ? config.currency : 'INR',
      'timeout': 300,
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#FF7A21'},
    };
    // Pass order_id only when backend returns a valid Razorpay order id.
    // Internal IDs like "177712..." can block checkout opening.
    if (_lastOrderId.startsWith('order_')) {
      options['order_id'] = _lastOrderId;
    }

    try {
      _razorpay.open(options);
      _paymentWatchdog?.cancel();
      _paymentWatchdog = Timer(const Duration(seconds: 8), () {
        if (!mounted || !_paying) return;
        setState(() => _paying = false);
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text(
              iosSimulator
                  ? 'select_fee_checkout_not_open_ios'.tr
                  : 'select_fee_checkout_not_open'.tr,
            ),
          ),
        );
      });
    } catch (e) {
      _paymentWatchdog?.cancel();
      if (!mounted) return;
      setState(() => _paying = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('${'select_fee_unable_open_gateway'.tr}: $e')),
      );
    }
  }

  /// Maps Razorpay checkout metadata to [PaymentMode] for `POST fee/update-payment`.
  String _razorpayPaymentModeLabel(PaymentSuccessResponse response) {
    final raw = response.data;
    if (raw is! Map) return 'RAZORPAY';
    final m = Map<dynamic, dynamic>.from(raw);
    for (final key in ['method', 'Method', 'payment_method', 'wallet']) {
      final v = m[key];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim().toUpperCase();
      }
    }
    return 'RAZORPAY';
  }

  /// Backend expects string fields (see `POST parents/fee/update-payment`).
  Future<FeeUpdatePaymentResponse> _sendUpdatePayment({
    required String status,
    required String transactionId,
    required String code,
    required String paymentMode,
    required String referenceId,
    required String message,
    required String transactionTime,
    required String type,
  }) async {
    final payload = <String, dynamic>{
      'InitiatedID': _lastInitiatedId,
      'TransactionStatus': status,
      'PGAmount': _lastAmount,
      'TransactionID': transactionId,
      'OrderID': _lastOrderId,
      'Code': code,
      'PaymentMode': paymentMode,
      'ReferenceId': referenceId,
      'TransactionMessage': message,
      'TransactionTime': transactionTime,
      'Type': type,
    };
    final body = <String, dynamic>{};
    payload.forEach((k, v) => body[k] = v?.toString() ?? '');
    return _feeController.updatePayment(body);
  }

  void _navigatePaymentResult({
    required bool success,
    String? message,
    String? transactionId,
    String? orderId,
  }) {
    if (!mounted) return;
    final parsed = num.tryParse(_lastAmount.trim());
    final amountLabel = parsed != null
        ? _formatBalance(parsed)
        : (_lastAmount.isNotEmpty ? '₹ $_lastAmount' : null);
    final studentLine = _data != null
        ? '${_data!.studentName} · ${'common_session'.tr} ${_data!.session}'
        : null;
    AppNavigation.pushReplacement(
      context,
      FeePaymentResultScreen(
        isSuccess: success,
        amountLabel: amountLabel,
        studentLine: studentLine,
        transactionId: transactionId,
        orderId: orderId,
        message: message,
      ),
    );
  }

  /// Razorpay invokes handlers synchronously from a platform callback. Async
  /// handlers would return an unhandled [Future]; any error then crashes the
  /// app. We schedule real work on the next frame and use [unawaited] with a
  /// full try/catch inside.
  void _onPaymentSuccess(PaymentSuccessResponse response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_processPaymentSuccess(response));
    });
  }

  Future<void> _processPaymentSuccess(PaymentSuccessResponse response) async {
    _paymentWatchdog?.cancel();
    try {
      final paymentId = response.paymentId?.trim() ?? '';
      if (paymentId.isEmpty) {
        if (mounted) {
          setState(() => _paying = false);
          _navigatePaymentResult(
            success: false,
            message: 'select_fee_payment_failed'.tr,
          );
        }
        return;
      }

      if (_lastInitiatedId.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text('select_fee_missing_initiated_id'.tr)),
          );
        }
      }

      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final signature = response.signature?.trim() ?? '';
      final orderId = response.orderId?.trim() ?? '';
      final apiRes = await _sendUpdatePayment(
        status: 'SUCCESS',
        transactionId: paymentId,
        code: signature.isNotEmpty ? signature : paymentId,
        paymentMode: _razorpayPaymentModeLabel(response),
        referenceId: orderId.isNotEmpty ? orderId : paymentId,
        message: 'select_fee_payment_successful'.tr,
        transactionTime: now,
        type: _feeUpdatePaymentType,
      );

      if (!mounted) return;
      if (!apiRes.success) {
        setState(() => _paying = false);
        final msg = apiRes.message.trim().isNotEmpty
            ? apiRes.message
            : 'select_fee_update_payment_rejected'.tr;
        _navigatePaymentResult(
          success: false,
          message: msg,
          transactionId: paymentId,
          orderId: orderId.isNotEmpty ? orderId : null,
        );
        return;
      }

      setState(() {
        _paying = false;
        _selectedStudentAccountIds.clear();
      });
      _navigatePaymentResult(
        success: true,
        message: apiRes.message.trim().isNotEmpty ? apiRes.message : null,
        transactionId: paymentId,
        orderId: orderId.isNotEmpty ? orderId : null,
      );
    } catch (e, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stack,
          library: 'select_fee_screen',
          context: ErrorDescription('while handling Razorpay payment success'),
        ),
      );
      if (mounted) {
        setState(() => _paying = false);
        _navigatePaymentResult(
          success: false,
          message: 'select_fee_post_payment_sync_error'.tr,
        );
      }
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_processPaymentError(response));
    });
  }

  Future<void> _processPaymentError(PaymentFailureResponse response) async {
    _paymentWatchdog?.cancel();
    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      await _sendUpdatePayment(
        status: 'Fail',
        transactionId: response.code?.toString() ?? '',
        code: response.code?.toString() ?? '',
        paymentMode: 'RAZORPAY',
        referenceId: '',
        message: response.message ?? 'select_fee_payment_failed'.tr,
        transactionTime: now,
        type: _feeUpdatePaymentType,
      );
      if (!mounted) return;
      setState(() => _paying = false);
      _navigatePaymentResult(
        success: false,
        message: response.message ?? 'select_fee_payment_failed'.tr,
        transactionId: response.code?.toString(),
      );
    } catch (e, stack) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: e,
          stack: stack,
          library: 'select_fee_screen',
          context: ErrorDescription('while handling Razorpay payment error'),
        ),
      );
      if (mounted) {
        setState(() => _paying = false);
        _navigatePaymentResult(
          success: false,
          message: 'select_fee_payment_failed'.tr,
        );
      }
    }
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _paymentWatchdog?.cancel();
      setState(() => _paying = false);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(
            '${'select_fee_external_wallet'.tr}: ${response.walletName}',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _data?.overallSummary;

    return Scaffold(
      appBar: CommonAppBar(title: 'select_fee_title'.tr),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accentOrange,
                onRefresh: () async {
                  await _loadFeeStructure();
                  await _loadPendingFee();
                },
                child: _loading && _data == null
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accentOrange,
                            ),
                          ),
                        ],
                      )
                    : _errorMessage != null && _data == null
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              const SizedBox(height: 48),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: _loadFeeStructure,
                                  child: Text('common_retry'.tr),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_data != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        _data!.studentName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textDarkGrey
                                              .withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ),
                                  if (_data != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16),
                                      child: Text(
                                        '${'common_session'.tr} ${_data!.session}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textDarkGrey
                                              .withValues(alpha: 0.75),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardWhite,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                summary?.formattedTotalBalance
                                                        .isNotEmpty ==
                                                    true
                                                    ? summary!.formattedTotalBalance
                                                    : _formatBalance(
                                                        summary?.totalBalanceAmount ??
                                                            0,
                                                      ),
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textBlack,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'select_fee_balance_due'.tr,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textDarkGrey
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                              if (_pendingLoading) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  'select_fee_loading_pending'.tr,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ] else if (_pendingFee != null &&
                                                  !_pendingFee!.isPaid &&
                                                  _pendingFee!.pendingFee > 0) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  'select_fee_pending_dues'.tr,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textDarkGrey
                                                        .withValues(alpha: 0.7),
                                                  ),
                                                ),
                                                Text(
                                                  _formatBalance(
                                                    _pendingFee!.pendingFee,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        Colors.orange.shade800,
                                                  ),
                                                ),
                                              ] else if (_pendingError !=
                                                      null &&
                                                  _pendingFee == null) ...[
                                                const SizedBox(height: 6),
                                                Text(
                                                  _pendingError!,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.red.shade600,
                                                  ),
                                                ),
                                              ],
                                              if (summary != null) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  '${'select_fee_total_fee'.tr} ${summary.formattedTotalFee} · ${'common_paid'.tr} ${summary.formattedTotalPaid}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors
                                                        .textDarkGrey
                                                        .withValues(
                                                            alpha: 0.75),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: _paying ? null : _startPayment,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.accentOrange,
                                            foregroundColor: AppColors.cardWhite,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 12,
                                            ),
                                          ),
                                          child: Text(
                                            _paying
                                                ? 'select_fee_processing'.tr
                                                : '${'fees_pay_now'.tr} ${_formatBalance(_selectedAmount)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'select_fee_structure'.tr,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_visiblePeriods.isEmpty && !_loading)
                                    Text(
                                      'select_fee_no_periods'.tr,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _visiblePeriods.length,
                                      itemBuilder: (context, index) {
                                        return _buildFeeItem(
                                          _visiblePeriods[index],
                                        );
                                      },
                                    ),
                                  if (_hasMorePeriods) const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeItem(FeeStructurePeriod period) {
    final range = _periodDateRange(period);
    final amountLabel = period.isPaid
        ? (period.formattedTotalPaid.trim().isNotEmpty
            ? period.formattedTotalPaid.trim()
            : _formatBalance(period.totalPaid))
        : _formatBalance(period.balanceAmount);
    final unpaidHeads = period.accountHeads.where((h) => !h.isPaid).toList();
    final selectedCount = unpaidHeads
        .where((h) => _selectedStudentAccountIds.contains(h.studentFeeAccountId))
        .length;
    final periodSelected = selectedCount > 0 && selectedCount == unpaidHeads.length;
    final canSelectPeriod = unpaidHeads.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentOrange.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              color: AppColors.accentOrange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                period.monthCode,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cardWhite,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  period.feePeriodName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                if (range.isNotEmpty)
                  Text(
                    range,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          AppColors.textDarkGrey.withValues(alpha: 0.75),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  period.paymentStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: period.isPaid ? Colors.green.shade700 : Colors.orange.shade800,
                  ),
                ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
              Text(
                amountLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlack,
                ),
              ),
                  if (period.isPaid) ...[
                    const SizedBox(height: 4),
                    Text(
                      'select_fee_period_total_paid'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  GestureDetector(
                onTap: () {
                  AppNavigation.push(
                    context,
                    ViewDetailScreen(
                      feePeriodId: period.feePeriodId,
                    ),
                  );
                },
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
                  ),
                  if (canSelectPeriod)
                    Checkbox(
                      value: periodSelected,
                      activeColor: AppColors.accentOrange,
                      onChanged: (v) {
                        setState(() {
                          for (final h in unpaidHeads) {
                            if (v == true) {
                              _selectedStudentAccountIds.add(h.studentFeeAccountId);
                            } else {
                              _selectedStudentAccountIds.remove(h.studentFeeAccountId);
                            }
                          }
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
          if (unpaidHeads.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              periodSelected
                  ? 'Month selected for payment'
                  : selectedCount > 0
                      ? '$selectedCount/${unpaidHeads.length} heads selected'
                      : 'Select this month to pay all pending heads',
              style: TextStyle(
                fontSize: 12,
                color: periodSelected
                    ? Colors.green.shade700
                    : AppColors.textDarkGrey.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${unpaidHeads.length} pending account head(s)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textDarkGrey.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
