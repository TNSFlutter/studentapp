import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studentapp/widgets/common_app_bar.dart';

import '../../constants/app_colors.dart';
import '../../helpers/app_navigation.dart';
import '../../controllers/fee_controller.dart';
import '../../models/pending_fee_models.dart';
import 'payment_status_screen.dart';

class PayFeeScreen extends StatefulWidget {
  const PayFeeScreen({super.key});

  @override
  State<PayFeeScreen> createState() => _PayFeeScreenState();
}

class _PayFeeScreenState extends State<PayFeeScreen> {
  final FeeController _feeController = FeeController();
  final TextEditingController _customAmountController = TextEditingController();

  PendingFeeData? _pending;
  bool _loading = true;
  String? _error;

  bool _isTotalAmountSelected = true;
  bool _isCustomAmountSelected = false;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  @override
  void dispose() {
    _feeController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadPending() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final parsed = await _feeController.fetchPendingFee(limit: 10);
    if (!mounted) return;
    if (parsed.success && parsed.data != null) {
      setState(() {
        _pending = parsed.data;
        _loading = false;
      });
      return;
    }
    setState(() {
      _error = parsed.message.isNotEmpty
          ? parsed.message
          : 'Could not load pending amount.';
      _loading = false;
    });
  }

  String _formatMoney(num n) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(n);
  }

  String _componentsLine(List<PendingFeeAccountHead> heads) {
    final unique = heads.map((h) => h.accountHeadName).toSet().toList();
    if (unique.isEmpty) return 'Fee components';
    if (unique.length <= 2) return unique.join(' + ');
    return '${unique[0]} + ${unique[1]} + ${unique.length - 2} more';
  }

  String _periodsLine(PendingFeeData d, List<PendingFeeAccountHead> heads) {
    final names = heads.map((h) => h.feePeriodName).toSet().toList()..sort();
    if (names.isNotEmpty) return names.join(', ');
    return d.feePeriodName;
  }

  num get _payableTotal => _pending?.pendingFee ?? 0;

  String get _payButtonLabel =>
      'Pay ${_formatMoney(_isTotalAmountSelected ? _payableTotal : _customParsed)}';

  num get _customParsed =>
      num.tryParse(_customAmountController.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(title: 'Pay Fee'),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFFF7ED)),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentOrange,
                        ),
                      )
                    : _error != null
                        ? ListView(
                            children: [
                              const SizedBox(height: 48),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                              TextButton(
                                onPressed: _loadPending,
                                child: const Text('Retry'),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      GestureDetector(
                                        onTap: _selectTotalAmount,
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppColors.accentOrange
                                                  .withValues(alpha: 0.3),
                                              width: _isTotalAmountSelected
                                                  ? 2
                                                  : 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text(
                                                      'Total Amount',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _isTotalAmountSelected
                                                              ? AppColors
                                                                  .accentOrange
                                                              : Colors
                                                                  .transparent,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: _isTotalAmountSelected
                                                            ? AppColors
                                                                .accentOrange
                                                            : Colors.grey,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: _isTotalAmountSelected
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 16,
                                                          )
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _formatMoney(_payableTotal),
                                                style: const TextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              if (_pending != null) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  _componentsLine(
                                                    _pending!.accountHeads,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Periods: ${_periodsLine(_pending!, _pending!.accountHeads)}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      GestureDetector(
                                        onTap: _selectCustomAmount,
                                        child: Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: _isCustomAmountSelected
                                                  ? AppColors.accentOrange
                                                  : Colors.transparent,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Expanded(
                                                    child: Text(
                                                      'Custom Amount',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          _isCustomAmountSelected
                                                              ? AppColors
                                                                  .accentOrange
                                                              : Colors
                                                                  .transparent,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.grey,
                                                        width: 2,
                                                      ),
                                                    ),
                                                    child: _isCustomAmountSelected
                                                        ? const Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 16,
                                                          )
                                                        : null,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              TextField(
                                                controller:
                                                    _customAmountController,
                                                onChanged: (_) {
                                                  if (_isCustomAmountSelected) {
                                                    setState(() {});
                                                  }
                                                },
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Enter your Amount',
                                                  hintStyle: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 14,
                                                  ),
                                                  border:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: Colors.grey,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: AppColors
                                                          .accentOrange,
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () {
                                    AppNavigation.push(
                                      context,
                                      const PaymentStatusScreen(),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentOrange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _payButtonLabel,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTotalAmount() {
    setState(() {
      _isTotalAmountSelected = true;
      _isCustomAmountSelected = false;
    });
  }

  void _selectCustomAmount() {
    setState(() {
      _isTotalAmountSelected = false;
      _isCustomAmountSelected = true;
    });
  }
}
