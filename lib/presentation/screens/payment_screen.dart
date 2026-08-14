import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/domain/value_objects/money.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_state.dart';

import '../models/mobile_employee_space.dart';
import '../widgets/app_palette.dart';
import '../widgets/payment_widgets.dart';

class PaymentFlowResult {
  const PaymentFlowResult({
    required this.transaction,
    required this.scanResult,
    required this.paymentResult,
  });

  final Transaction transaction;
  final QRScanResultModel scanResult;
  final PaymentResultModel paymentResult;
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.isDarkMode,
    required this.qrToken,
    required this.merchantName,
    this.availableBalance,
  });

  final bool isDarkMode;
  final String qrToken;
  final String merchantName;
  final MoneyModel? availableBalance;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _amountDigits = '';
  String _pinDigits = '';
  late final TextEditingController _pinController;
  late final FocusNode _pinFocusNode;
  String? _errorMessage;
  bool _isSubmitting = false;
  bool _isPinStep = false;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _pinFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);
    return BlocListener<PaymentBloc, PaymentState>(
      listener: _onPaymentStateChanged,
      child: Scaffold(
        backgroundColor: palette.pageBackground,
        body: PaymentForm(
          isDarkMode: widget.isDarkMode,
          merchantName: widget.merchantName,
          availableBalance: widget.availableBalance,
          amountDigits: _amountDigits,
          pinDigits: _pinDigits,
          pinController: _pinController,
          pinFocusNode: _pinFocusNode,
          errorMessage: _errorMessage,
          isSubmitting: _isSubmitting,
          isPinStep: _isPinStep,
          onClose: () => Navigator.of(context).pop(),
          onAmountDigitTap: _onAmountDigitTap,
          onAmountBackspace: _onAmountBackspace,
          onPinDigitTap: _onPinDigitTap,
          onPinBackspace: _onPinBackspace,
          onNativePinChanged: _onNativePinChanged,
          onSubmit: _isPinStep ? _confirmPayment : _startPayment,
        ),
      ),
    );
  }

  void _onAmountDigitTap(String digit) {
    if (_amountDigits.length >= 6) return;
    setState(() {
      _errorMessage = null;
      _amountDigits = _amountDigits == '0' ? digit : '$_amountDigits$digit';
    });
  }

  void _onAmountBackspace() {
    if (_amountDigits.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _amountDigits = _amountDigits.substring(0, _amountDigits.length - 1);
    });
  }

  void _onPinDigitTap(String digit) {
    if (_pinDigits.length >= 4) return;
    setState(() {
      _errorMessage = null;
      _pinDigits = '$_pinDigits$digit';
    });
  }

  void _onPinBackspace() {
    if (_pinDigits.isEmpty) return;
    setState(() {
      _errorMessage = null;
      _pinDigits = _pinDigits.substring(0, _pinDigits.length - 1);
    });
  }

  void _onNativePinChanged(String value) {
    setState(() {
      _errorMessage = null;
      _pinDigits = value;
    });
  }

  void _startPayment() {
    final loc = AppLocalizations.of(context);
    final amount = int.tryParse(_amountDigits) ?? 0;
    final balance = widget.availableBalance?.amount ?? double.infinity;
    if (amount <= 0) {
      setState(() => _errorMessage = loc.invalidAmount);
      return;
    }
    if (amount > balance) {
      setState(() => _errorMessage = loc.insufficientBalance);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    context.read<PaymentBloc>().add(
      QrScanned(
        qrToken: widget.qrToken,
        merchantName: widget.merchantName,
        amount: Money.xof(amount),
      ),
    );
  }

  void _confirmPayment() {
    if (_pinDigits.length != 4) {
      setState(
        () => _errorMessage = AppLocalizations.of(context).enterYourPinCode,
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    context.read<PaymentBloc>().add(PaymentConfirmed(_pinDigits));
  }

  void _onPaymentStateChanged(BuildContext context, PaymentState state) {
    switch (state) {
      case PaymentQrScanned():
        setState(() {
          _isSubmitting = false;
          _isPinStep = true;
          _pinDigits = '';
          _pinController.clear();
        });
      case PaymentFailure():
        setState(() {
          _isSubmitting = false;
          _pinDigits = '';
          _pinController.clear();
          _errorMessage = state.errorMessage;
        });
      case PaymentSuccess():
        setState(() => _isSubmitting = false);
        unawaited(_finishPayment(state.transaction));
      default:
        break;
    }
  }

  Future<void> _finishPayment(Transaction transaction) async {
    final money = MoneyModel(
      amount: transaction.amount.amount.toDouble(),
      currency: transaction.amount.currency,
      formatted: transaction.amount.formatted,
      symbol: 'F',
    );
    final date = _formatDate(transaction.date);
    final result = PaymentFlowResult(
      transaction: transaction,
      scanResult: QRScanResultModel(
        token: widget.qrToken,
        merchantName: transaction.label,
        amount: money,
        expiresAt: date,
      ),
      paymentResult: PaymentResultModel(
        paymentId: transaction.id,
        status: PaymentStatus.success,
        amount: money,
        date: date,
      ),
    );

    if (!mounted) return;
    await showPaymentSuccessDialog(
      context,
      isDarkMode: widget.isDarkMode,
      amount: money.formatted,
      merchantName: transaction.label,
    );
    if (mounted) Navigator.of(context).pop(result);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}h'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
