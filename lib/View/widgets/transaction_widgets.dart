import 'package:flutter/material.dart';
import '../models/mobile_employee_space.dart';
import 'app_palette.dart';

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
          const Center(child: Text('Aucune transaction disponible.'));
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
    this.isDarkMode = false,
  });

  final TransactionItemModel transaction;
  final bool showAmount;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? palette.tileBackground : const Color(0xFFF0EEFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF251F32)
                  : const Color(0xFFFFE0CC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              size: 16,
              color: Color(0xFFF57C21),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? palette.primaryText : null,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.date,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDarkMode
                        ? const Color(0xFF787392)
                        : const Color(0xFF8A8898),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: transaction.isCredit
                        ? const Color(0xFF11B777)
                        : (isDarkMode ? palette.primaryText : null),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  transaction.status,
                  style: TextStyle(
                    fontSize: 11.5,
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

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('attente')) {
      return const Color(0xFFF5A623);
    }
    if (normalized.contains('echec') || normalized.contains('refus')) {
      return Colors.red;
    }
    return const Color(0xFF11B777);
  }
}
