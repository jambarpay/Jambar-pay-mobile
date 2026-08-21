import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_durations.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';

import '../models/mobile_employee_space.dart';
import 'app_palette.dart';
import 'keypad_widgets.dart';

class PaymentForm extends StatelessWidget {
  const PaymentForm({
    super.key,
    required this.isDarkMode,
    required this.merchantName,
    required this.amountDigits,
    required this.isSubmitting,
    required this.onClose,
    required this.onAmountDigitTap,
    required this.onAmountBackspace,
    required this.onSubmit,
    this.availableBalance,
    this.errorMessage,
  });

  final bool isDarkMode;
  final String merchantName;
  final MoneyModel? availableBalance;
  final String amountDigits;
  final String? errorMessage;
  final bool isSubmitting;
  final VoidCallback onClose;
  final ValueChanged<String> onAmountDigitTap;
  final VoidCallback onAmountBackspace;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final loc = AppLocalizations.of(context);
    final contentColor = isDarkMode
        ? palette.primaryText
        : AppColors.lightPrimaryText;
    final hintColor = isDarkMode
        ? palette.secondaryText
        : AppColors.lightMutedText;
    final actionColor = isDarkMode ? palette.accent : AppColors.actionNavy;
    final amount = amountDigits.isEmpty ? 0 : int.parse(amountDigits);

    return SafeArea(
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
                  _PaymentBackButton(
                    label: loc.back,
                    contentColor: contentColor,
                    hintColor: hintColor,
                    onTap: onClose,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
                    child: Column(
                      children: [
                        Text(
                          merchantName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: contentColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loc.enterAmountToPay,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: contentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (availableBalance != null)
                          Text(
                            loc.availableBalance(availableBalance!.formatted),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hintColor,
                            ),
                          ),
                        const SizedBox(height: 26),
                        _AmountField(
                          amountLabel: amountDigits.isEmpty
                              ? loc.amount
                              : MoneyModel.xof(
                                  amount,
                                ).formatted.replaceAll(' Fcfa', ''),
                          isDarkMode: isDarkMode,
                        ),
                        const SizedBox(height: 16),
                        _PaymentError(message: errorMessage),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isSubmitting ? null : onSubmit,
                            style: FilledButton.styleFrom(
                              backgroundColor: actionColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: actionColor.withValues(
                                alpha: 0.45,
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(loc.pay),
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          height: keypadHeight.toDouble(),
                          child: NumericKeypad(
                            onDigitTap: onAmountDigitTap,
                            onBackspace: onAmountBackspace,
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
    );
  }
}

class _PaymentBackButton extends StatelessWidget {
  const _PaymentBackButton({
    required this.label,
    required this.contentColor,
    required this.hintColor,
    required this.onTap,
  });

  final String label;
  final Color contentColor;
  final Color hintColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onTap,
            icon: Icon(Icons.arrow_back, color: contentColor),
          ),
          Text(label, style: TextStyle(color: hintColor, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PaymentError extends StatelessWidget {
  const _PaymentError({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: message == null ? 0 : 1,
      duration: AppDurations.fast,
      child: SizedBox(
        height: 34,
        child: Text(
          message ?? '',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({required this.amountLabel, required this.isDarkMode});

  final String amountLabel;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final isPlaceholder = amountLabel == AppLocalizations.of(context).amount;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDarkMode ? AppColors.darkChip : AppColors.lightBorder,
        ),
        color: isDarkMode ? palette.sectionContainer : Colors.white,
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
                fontWeight: isPlaceholder ? FontWeight.w600 : FontWeight.w700,
                color: isPlaceholder
                    ? (isDarkMode ? palette.secondaryText : AppColors.lightHint)
                    : (isDarkMode
                          ? palette.primaryText
                          : AppColors.lightPrimaryText),
              ),
            ),
          ),
          Text(
            'Fcfa',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? palette.secondaryText : AppColors.lightHint,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showPaymentSuccessDialog(
  BuildContext context, {
  required bool isDarkMode,
  required String amount,
  required String merchantName,
}) {
  final palette = AppPalette(isDarkMode);
  final loc = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? AppColors.darkSuccessSurface
                  : AppColors.successSurface,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.paymentSuccess,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            loc.paymentSuccessBody(amount, merchantName),
            textAlign: TextAlign.center,
            style: TextStyle(color: palette.secondaryText),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(loc.finish),
        ),
      ],
    ),
  );
}
