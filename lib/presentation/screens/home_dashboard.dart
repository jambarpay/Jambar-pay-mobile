import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jambar_pay_mobile/app/router/app_router.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_state.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import '../models/mobile_employee_space.dart';
import '../widgets/app_palette.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_widgets.dart';
import '../widgets/transaction_widgets.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';

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
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
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
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    final recent = state is TransactionLoaded
                        ? state.filteredTransactions.take(3).toList()
                        : const <Transaction>[];

                    return Column(
                      children: [
                        SectionHeader(
                          title: loc.recentTransactions,
                          actionLabel: loc.viewAll,
                          onActionTap: () => onTabSelected(1),
                          isDarkMode: isDarkMode,
                        ),
                        if (state is TransactionLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          )
                        else if (recent.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                loc.noTransactionsAvailable,
                                style: TextStyle(color: palette.mutedText),
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Column(
                              children: [
                                for (final transaction in recent) ...[
                                  TransactionTile(
                                    transaction: _toTransactionItemModel(
                                      transaction,
                                      context,
                                    ),
                                    compact: true,
                                    isDarkMode: isDarkMode,
                                  ),
                                  if (transaction != recent.last)
                                    const SizedBox(height: 10),
                                ],
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

TransactionItemModel _toTransactionItemModel(
  Transaction transaction,
  BuildContext context,
) {
  final loc = AppLocalizations.of(context);
  final date = transaction.date;
  final time = '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  final now = DateTime.now();
  final yesterday = now.subtract(const Duration(days: 1));
  final formattedDate =
      date.year == now.year && date.month == now.month && date.day == now.day
      ? loc.todayAt(time)
      : date.year == yesterday.year &&
            date.month == yesterday.month &&
            date.day == yesterday.day
      ? loc.yesterdayAt(time)
      : loc.dateTime('${date.day}/${date.month}/${date.year}', time);

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
    date: formattedDate,
    status: transaction.status == TransactionStatus.validated
        ? loc.statusValidated
        : transaction.status == TransactionStatus.failed
        ? loc.statusFailed
        : loc.statusPending,
  );
}
