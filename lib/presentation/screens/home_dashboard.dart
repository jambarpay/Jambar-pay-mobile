import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jambar_pay_mobile/app/router/app_router.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_state.dart';
import '../models/mobile_employee_space.dart';
import '../widgets/app_palette.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_widgets.dart';
import '../widgets/transaction_widgets.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';

TransactionItemModel _toTransactionItemModel(
  Transaction transaction,
  BuildContext context,
) {
  final loc = AppLocalizations.of(context);

  return TransactionItemModel(
    id: transaction.id,
    type: transaction.type == TransactionType.credit ? 'CREDIT' : 'DEBIT',
    amount: MoneyModel(
      amount: transaction.amount.amount.toDouble(),
      currency: transaction.amount.currency,
      formatted: transaction.amount.formatted,
      symbol: 'F',
    ),
    label: transaction.label,
    date: _formatTransactionDate(transaction.date, context),
    status: transaction.status == TransactionStatus.validated
        ? loc.statusValidated
        : transaction.status == TransactionStatus.failed
        ? loc.statusFailed
        : loc.statusPending,
  );
}

String _formatTransactionDate(DateTime date, BuildContext context) {
  final loc = AppLocalizations.of(context);
  final now = DateTime.now();
  final time = '${date.hour}h${date.minute.toString().padLeft(2, '0')}';

  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    return loc.todayAt(time);
  }

  final yesterday = now.subtract(const Duration(days: 1));
  if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return loc.yesterdayAt(time);
  }

  return loc.dateTime('${date.day}/${date.month}/${date.year}', time);
}

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.onTabSelected,
    required this.isDarkMode,
    required this.appState,
  });

  final ValueChanged<int> onTabSelected;
  final bool isDarkMode;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 48, 22, 18),
          decoration: BoxDecoration(color: palette.headerBackground),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour',
                          style: TextStyle(
                            color: palette.onHeaderMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appState.userProfile.name,
                          style: TextStyle(
                            color: palette.onHeader,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.brand,
                    child: Text(
                      appState.userProfile.name.isEmpty
                          ? '?'
                          : appState.userProfile.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BalanceCard(
                isDarkMode: isDarkMode,
                wallet: appState.wallet,
                onQrTap: () async {
                  final selectedTab = await context.push<int>(
                    AppRoutes.qrScanner,
                  );
                  if (selectedTab != null && context.mounted) {
                    onTabSelected(selectedTab);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: palette.pageBackground,
            child: Column(
              children: [
                QuickActionGrid(
                  scanLabel: loc.scan,
                  restaurantsLabel: loc.restaurants,
                  historyLabel: loc.history,
                  statementLabel: 'Relevé',
                  onScan: () async {
                    final selectedTab = await context.push<int>(
                      AppRoutes.qrScanner,
                    );
                    if (selectedTab != null && context.mounted) {
                      onTabSelected(selectedTab);
                    }
                  },
                  onRestaurants: () => onTabSelected(2),
                  onHistory: () => onTabSelected(1),
                  onStatement: () => onTabSelected(1),
                  isDarkMode: isDarkMode,
                ),
                SectionHeader(
                  title: loc.recentTransactions,
                  actionLabel: loc.viewAll,
                  onActionTap: () {
                    final transactionBloc = context.read<TransactionBloc>();
                    final transactionState = transactionBloc.state;

                    if (transactionState is TransactionLoaded) {
                      transactionBloc.add(const SearchCleared());
                      transactionBloc.add(
                        const TransactionsFilterChanged('all'),
                      );
                    } else {
                      transactionBloc.add(const TransactionsLoadRequested());
                    }

                    onTabSelected(1);
                  },
                  isDarkMode: isDarkMode,
                ),
                Expanded(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      final recentTransactions = state is TransactionLoaded
                          ? state.allTransactions
                                .take(6)
                                .map(
                                  (transaction) => _toTransactionItemModel(
                                    transaction,
                                    context,
                                  ),
                                )
                                .toList()
                          : const <TransactionItemModel>[];

                      return TransactionsList(
                        transactions: recentTransactions,
                        showAmount: true,
                        isDarkMode: isDarkMode,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
