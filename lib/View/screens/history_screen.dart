import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_state.dart';
import '../widgets/app_palette.dart';
import '../widgets/history_widgets.dart';
import '../widgets/transaction_widgets.dart';
import '../widgets/home_widgets.dart';
import '../models/mobile_employee_space.dart';

TransactionItemModel _toTransactionItemModel(Transaction t) {
  return TransactionItemModel(
    id: t.id,
    type: t.type == TransactionType.credit ? 'CREDIT' : 'DEBIT',
    amount: MoneyModel(
      amount: t.amount.amount,
      currency: t.amount.currency,
      formatted: t.amount.formatted,
      symbol: 'F',
    ),
    label: t.label,
    date: _formatDate(t.date),
    status: t.status == TransactionStatus.validated
        ? 'Valide'
        : t.status == TransactionStatus.failed
            ? 'Échoué'
            : 'En attente',
  );
}

String _formatDate(DateTime date) {
  final now = DateTime.now();
  if (date.year == now.year &&
      date.month == now.month &&
      date.day == now.day) {
    return "Aujourd'hui, ${date.hour}h${date.minute.toString().padLeft(2, '0')}";
  }
  final yesterday = now.subtract(const Duration(days: 1));
  if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    return 'Hier, ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  }
  return '${date.day}/${date.month}/${date.year}, ${date.hour}h${date.minute.toString().padLeft(2, '0')}';
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.isDarkMode,
  });

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Column(
      children: [
        const SubPageHeader(
          title: 'Historique',
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
                      controller: TextEditingController(text: query),
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
                        : 'Tous';
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
                      final hasMore = state is TransactionLoaded && state.hasMore;
                      
                      return Row(
                        children: [
                          Text(
                            '$count transaction(s)',
                            style: TextStyle(
                              color: isDarkMode
                                  ? palette.secondaryText
                                  : const Color(0xFF6B6884),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (hasMore)
                            Text(
                              'Chargement progressif actif',
                              style: TextStyle(
                                color: palette.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
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
                      color: isDarkMode ? palette.sectionContainer : Colors.transparent,
                      child: BlocBuilder<TransactionBloc, TransactionState>(
                        builder: (context, state) {
                          if (state is TransactionInitial || state is TransactionLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (state is TransactionEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  state.searchQuery != null && state.searchQuery!.isNotEmpty
                                      ? 'Aucune transaction ne correspond à votre recherche.'
                                      : 'Aucune transaction disponible.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? palette.secondaryText
                                        : const Color(0xFF6B6884),
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
                                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                        context
                                            .read<TransactionBloc>()
                                            .add(const TransactionsLoadRequested());
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Réessayer'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          if (state is TransactionLoaded) {
                            final visibleTransactions = state.filteredTransactions
                                .take(state.visibleCount)
                                .map(_toTransactionItemModel)
                                .toList();

                            return TransactionsList(
                              controller: ScrollController()
                                ..addListener(() {
                                  if (ScrollController().position.pixels >=
                                      ScrollController().position.maxScrollExtent - 80) {
                                    context.read<TransactionBloc>().add(
                                          const TransactionsLoadMoreRequested(),
                                        );
                                  }
                                }),
                              transactions: visibleTransactions,
                              topPadding: isDarkMode ? 14 : 20,
                              showAmount: true,
                              isDarkMode: isDarkMode,
                              emptyState: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    'Aucune transaction ne correspond à votre recherche.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? palette.secondaryText
                                          : const Color(0xFF6B6884),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
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
