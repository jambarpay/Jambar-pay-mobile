import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_radius.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import '../models/mobile_employee_space.dart';
import 'app_palette.dart';
import '../utils/localized_view_data.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({
    super.key,
    required this.transactions,
    this.topPadding = 0,
    this.showAmount = false,
    this.isDarkMode = false,
    this.controller,
    this.emptyState,
  });

  final List<TransactionItemModel> transactions;
  final double topPadding;
  final bool showAmount;
  final bool isDarkMode;
  final ScrollController? controller;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return emptyState ??
          Center(
            child: Text(AppLocalizations.of(context).noTransactionsAvailable),
          );
    }

    return ListView.separated(
      controller: controller,
      padding: EdgeInsets.fromLTRB(22, topPadding, 22, 22),
      itemBuilder: (context, index) {
        return TransactionTile(
          transaction: transactions[index],
          showAmount: showAmount,
          isDarkMode: isDarkMode,
        );
      },
      separatorBuilder: (context, index) {
        return const SizedBox(height: 14);
      },
      itemCount: transactions.length,
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    this.showAmount = true,
    this.compact = false,
    this.isDarkMode = false,
  });

  final TransactionItemModel transaction;
  final bool showAmount;
  final bool compact;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 16,
        vertical: compact ? 9 : 14,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? palette.tileBackground : Colors.white,
        border: Border.all(
          color: isDarkMode ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSubtle,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 38 : 46,
            height: compact ? 38 : 46,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppColors.darkWarmSurface
                  : AppColors.brandSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.restaurant_outlined,
              size: compact ? 18 : 21,
              color: AppColors.brand,
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizeTransactionLabel(context, transaction.label),
                  style: TextStyle(
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? palette.primaryText : null,
                  ),
                ),
                SizedBox(height: compact ? 1 : 3),
                Text(
                  localizeRelativeDate(context, transaction.date),
                  style: TextStyle(
                    fontSize: compact ? 11 : 12.5,
                    color: isDarkMode
                        ? AppColors.darkMutedText
                        : AppColors.lightMutedText,
                  ),
                ),
              ],
            ),
          ),
          if (showAmount)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.signedAmount,
                  style: TextStyle(
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.w700,
                    color: transaction.isCredit
                        ? AppColors.success
                        : (isDarkMode ? palette.primaryText : null),
                  ),
                ),
                SizedBox(height: compact ? 3 : 10),
                Text(
                  _statusText(transaction.status, context),
                  style: TextStyle(
                    fontSize: compact ? 10 : 11.5,
                    color: _statusColor(transaction.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _statusText(String status, BuildContext context) {
    final normalized = status.toLowerCase();
    final loc = AppLocalizations.of(context);
    if (normalized.contains('pending') || normalized.contains('attente')) {
      return loc.statusPending;
    }
    if (normalized.contains('failed') ||
        normalized.contains('échec') ||
        normalized.contains('échoué') ||
        normalized.contains('refus')) {
      return loc.statusFailed;
    }
    if (normalized.contains('validated') ||
        normalized.contains('valid') ||
        normalized.contains('valide') ||
        normalized.contains('validé')) {
      return loc.statusValidated;
    }
    return status;
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('attente') || normalized.contains('pending')) {
      return AppColors.warning;
    }
    if (normalized.contains('echec') ||
        normalized.contains('échoué') ||
        normalized.contains('failed') ||
        normalized.contains('refus')) {
      return Colors.red;
    }
    return AppColors.success;
  }
}
