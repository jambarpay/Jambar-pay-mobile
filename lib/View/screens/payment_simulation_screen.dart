import 'package:flutter/material.dart';

import '../models/mobile_employee_space.dart';
import '../widgets/app_palette.dart';
import '../widgets/keypad_widgets.dart';

class PaymentSimulationResult {
  final QRScanResultModel scanResult;
  final PaymentResultModel paymentResult;

  const PaymentSimulationResult({
    required this.scanResult,
    required this.paymentResult,
  });
}

class PaymentSimulationScreen extends StatefulWidget {
  const PaymentSimulationScreen({
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
  State<PaymentSimulationScreen> createState() =>
      _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState extends State<PaymentSimulationScreen> {
  String _amountDigits = '';
  String? _errorMessage;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);
    final contentColor = widget.isDarkMode
        ? palette.primaryText
        : const Color(0xFF1C1A33);
    final hintColor = widget.isDarkMode
        ? palette.secondaryText
        : const Color(0xFF8A8898);
    final actionColor = widget.isDarkMode
        ? palette.accent
        : const Color(0xFF0D124B);
    final amount = _amountDigits.isEmpty ? 0 : int.parse(_amountDigits);

    return Scaffold(
      backgroundColor: palette.pageBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final keypadHeight = (constraints.maxHeight * 0.34).clamp(
              200.0,
              280.0,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(Icons.arrow_back, color: contentColor),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Retour',
                            style: TextStyle(color: hintColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
                      child: Column(
                        children: [
                          Text(
                            widget.merchantName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: contentColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Veuillez entrer le montant a payer',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: contentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (widget.availableBalance != null)
                            Text(
                              'Solde disponible: ${widget.availableBalance!.formatted}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: hintColor,
                              ),
                            ),
                          const SizedBox(height: 26),
                          _AmountField(
                            amountLabel: _amountDigits.isEmpty
                                ? 'Montant'
                                : MoneyModel.xof(
                                    amount,
                                  ).formatted.replaceAll(' Fcfa', ''),
                            isDarkMode: widget.isDarkMode,
                          ),
                          const SizedBox(height: 16),
                          AnimatedOpacity(
                            opacity: _errorMessage == null ? 0 : 1,
                            duration: const Duration(milliseconds: 180),
                            child: SizedBox(
                              height: 18,
                              child: Text(
                                _errorMessage ?? '',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isSubmitting ? null : _submitPayment,
                              style: FilledButton.styleFrom(
                                backgroundColor: actionColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: actionColor.withValues(
                                  alpha: 0.45,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Payer',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          SizedBox(
                            height: keypadHeight.toDouble(),
                            child: NumericKeypad(
                              onDigitTap: _onDigitTap,
                              onBackspace: _onBackspace,
                              foregroundColor: contentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onDigitTap(String digit) {
    if (_amountDigits.length >= 6) {
      return;
    }

    setState(() {
      _errorMessage = null;
      if (_amountDigits == '0') {
        _amountDigits = digit;
      } else {
        _amountDigits = '$_amountDigits$digit';
      }
    });
  }

  void _onBackspace() {
    if (_amountDigits.isEmpty) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _amountDigits = _amountDigits.substring(0, _amountDigits.length - 1);
    });
  }

  Future<void> _submitPayment() async {
    final palette = AppPalette(widget.isDarkMode);
    final contentColor = widget.isDarkMode
        ? palette.primaryText
        : const Color(0xFF1C1A33);
    final hintColor = widget.isDarkMode
        ? palette.secondaryText
        : const Color(0xFF6E6B87);
    final actionColor = widget.isDarkMode
        ? palette.accent
        : const Color(0xFF0D124B);
    final surfaceColor = widget.isDarkMode
        ? palette.sectionContainer
        : Colors.white;
    final amount = int.tryParse(_amountDigits) ?? 0;
    final balance = widget.availableBalance?.amount ?? double.infinity;

    if (amount <= 0) {
      setState(() {
        _errorMessage = 'Veuillez saisir un montant valide.';
      });
      return;
    }

    if (amount > balance) {
      setState(() {
        _errorMessage = 'Solde insuffisant pour ce paiement.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 700));

    final money = MoneyModel.xof(amount);
    final now = DateTime.now();
    final formattedDate =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}, '
        '${now.hour.toString().padLeft(2, '0')}h'
        '${now.minute.toString().padLeft(2, '0')}';

    final result = PaymentSimulationResult(
      scanResult: QRScanResultModel(
        token: widget.qrToken,
        merchantName: widget.merchantName,
        amount: money,
        expiresAt: formattedDate,
      ),
      paymentResult: PaymentResultModel(
        paymentId: 'PAY-${now.millisecondsSinceEpoch}',
        status: PaymentStatus.success,
        amount: money,
        date: formattedDate,
      ),
    );

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isDarkMode
                      ? const Color(0xFF1E3A2F)
                      : const Color(0xFFE7FAF2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF11B777),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Paiement reussi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: contentColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${money.formatted} envoye a ${widget.merchantName}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Terminer'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(result);
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.amountLabel, required this.isDarkMode});

  final String amountLabel;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final borderColor = isDarkMode
        ? const Color(0xFF3B375A)
        : const Color(0xFFCBC9D3);
    final backgroundColor = isDarkMode
        ? palette.sectionContainer
        : Colors.white;
    final hintColor = isDarkMode
        ? palette.secondaryText
        : const Color(0xFF88879A);
    final contentColor = isDarkMode
        ? palette.primaryText
        : const Color(0xFF1C1A33);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        color: backgroundColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              amountLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: amountLabel == 'Montant'
                    ? FontWeight.w600
                    : FontWeight.w700,
                color: amountLabel == 'Montant' ? hintColor : contentColor,
              ),
            ),
          ),
          Text(
            'Fcfa',
            style: TextStyle(
              fontSize: 14,
              color: hintColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
