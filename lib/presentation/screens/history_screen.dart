import 'package:flutter/material.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_state.dart';
import '../widgets/app_palette.dart';
import '../widgets/history_widgets.dart';
import '../widgets/transaction_widgets.dart';
import '../widgets/home_widgets.dart';
import '../models/mobile_employee_space.dart';

TransactionItemModel _toTransactionItemModel(
  Transaction t,
  BuildContext context,
) {
  final loc = AppLocalizations.of(context);
  return TransactionItemModel(
    id: t.id,
    type: t.type == TransactionType.credit ? 'CREDIT' : 'DEBIT',
    amount: MoneyModel(
      amount: t.amount.amount.toDouble(),
      currency: t.amount.currency,
      formatted: t.amount.formatted,
      symbol: 'F',
    ),
    label: t.label,
    date: _formatDate(t.date, context),
    status: t.status == TransactionStatus.validated
        ? loc.statusValidated
        : t.status == TransactionStatus.failed
        ? loc.statusFailed
        : loc.statusPending,
  );
}

String _formatDate(DateTime date, BuildContext context) {
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

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.isDarkMode,
    this.userProfile,
    this.wallet,
    this.onQrTap,
  });

  final bool isDarkMode;
  final UserProfileModel? userProfile;
  final WalletSummaryModel? wallet;
  final VoidCallback? onQrTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Column(
      children: [
        if (userProfile != null)
          EmployeeHeroHeader(
            userProfile: userProfile!,
            wallet: wallet,
            onQrTap: onQrTap ?? () {},
            isDarkMode: isDarkMode,
            showBalanceCard: false,
          ),
        SubPageHeader(
          title: AppLocalizations.of(context).history,
          onBackEnabled: false,
          subtitle: null,
        ),
        Expanded(
          child: ColoredBox(
            color: palette.pageBackground,
            child: Column(
              children: [
                // Search field
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    final query = state is TransactionLoaded
                        ? state.searchQuery ?? ''
                        : '';
                    return HistorySearchField(
                      query: query,
                      onChanged: (value) {
                        context.read<TransactionBloc>().add(
                          SearchQueryChanged(value),
                        );
                      },
                      isDarkMode: isDarkMode,
                    );
                  },
                ),
                // Filters
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    final currentFilter = state is TransactionLoaded
                        ? state.currentFilter
                        : 'all';
                    return HistoryFilters(
                      selectedFilter: currentFilter,
                      onFilterSelected: (value) {
                        context.read<TransactionBloc>().add(
                          TransactionsFilterChanged(value),
                        );
                      },
                      isDarkMode: isDarkMode,
                    );
                  },
                ),
                // Transaction count & loading indicator
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      final count = state is TransactionLoaded
                          ? state.filteredTransactions.length
                          : 0;
                      final hasMore =
                          state is TransactionLoaded && state.hasMore;

                      return Row(
                        children: [
                          Text(
                            AppLocalizations.of(
                              context,
                            ).transactionCount(count),
                            style: TextStyle(
                              color: isDarkMode
                                  ? palette.secondaryText
                                  : AppColors.lightSecondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (hasMore)
                            Flexible(
                              child: Text(
                                AppLocalizations.of(
                                  context,
                                ).progressiveLoadingActive,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                // Transaction list
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isDarkMode ? 16 : 0,
                      14,
                      isDarkMode ? 16 : 0,
                      0,
                    ),
                    child: Container(
                      color: isDarkMode
                          ? palette.sectionContainer
                          : Colors.transparent,
                      child: BlocBuilder<TransactionBloc, TransactionState>(
                        builder: (context, state) {
                          if (state is TransactionInitial ||
                              state is TransactionLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state is TransactionEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  state.searchQuery != null &&
                                          state.searchQuery!.isNotEmpty
                                      ? AppLocalizations.of(
                                          context,
                                        ).noTransactionsMatchSearch
                                      : AppLocalizations.of(
                                          context,
                                        ).noTransactionsAvailable,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? palette.secondaryText
                                        : AppColors.lightSecondaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }

                          if (state is TransactionFailure) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state.errorMessage,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        context.read<TransactionBloc>().add(
                                          const TransactionsLoadRequested(),
                                        );
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: Text(
                                        AppLocalizations.of(context).retry,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (state is TransactionLoaded) {
                            final visibleTransactions = state
                                .visibleTransactions
                                .map((t) => _toTransactionItemModel(t, context))
                                .toList();

                            return Column(
                              children: [
                                Expanded(
                                  child: TransactionsList(
                                    transactions: visibleTransactions,
                                    topPadding: isDarkMode ? 14 : 20,
                                    showAmount: true,
                                    isDarkMode: isDarkMode,
                                    emptyState: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                        ),
                                        child: Text(
                                          AppLocalizations.of(
                                            context,
                                          ).noTransactionsMatchSearch,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? palette.secondaryText
                                                : AppColors.lightSecondaryText,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (state.hasMore)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: FilledButton.tonalIcon(
                                      onPressed: () {
                                        context.read<TransactionBloc>().add(
                                          const TransactionsLoadMoreRequested(),
                                        );
                                      },
                                      icon: const Icon(Icons.expand_more),
                                      label: Text(
                                        AppLocalizations.of(context).loadMore,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                    ),
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
