import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../../../domain/use_cases/transactions/get_transactions.dart';
import '../../../domain/use_cases/transactions/filter_transactions.dart';
import '../../../domain/entities/transaction.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions _getTransactions;

  static const int _pageSize = 4;

  TransactionBloc({
    required GetTransactions getTransactions,
    required FilterTransactions filterTransactions,
  })  : _getTransactions = getTransactions,
        super(const TransactionInitial()) {
    on<TransactionsLoadRequested>(_onLoadRequested);
    on<TransactionsRefreshRequested>(_onRefreshRequested);
    on<TransactionsLoadMoreRequested>(_onLoadMoreRequested);
    on<TransactionsFilterChanged>(_onFilterChanged);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCleared>(_onSearchCleared);
  }

  Future<void> _onLoadRequested(
    TransactionsLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      final all = await _getTransactions();
      if (all.isEmpty) {
        emit(const TransactionEmpty());
      } else {
        final filtered = _applyFilter(all, 'Tous', null);
        emit(TransactionLoaded(
          allTransactions: all,
          filteredTransactions: filtered,
          currentFilter: 'Tous',
          searchQuery: null,
          hasMore: filtered.length > _pageSize,
          visibleCount: _pageSize,
        ));
      }
    } catch (e) {
      // Log error to help debugging network/backend issues
      print('TransactionBloc ERROR (load): $e');
      emit(TransactionFailure('Erreur: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshRequested(
    TransactionsRefreshRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;
    
    emit(const TransactionLoading());
    try {
      final all = await _getTransactions();
      final filtered = _applyFilter(all, current.currentFilter, current.searchQuery);
      emit(current.copyWith(
        allTransactions: all,
        filteredTransactions: filtered,
        hasMore: filtered.length > _pageSize,
        visibleCount: _pageSize,
      ));
    } catch (e) {
      print('TransactionBloc ERROR (refresh): $e');
      emit(TransactionFailure('Erreur: ${e.toString()}'));
    }
  }

  void _onLoadMoreRequested(
    TransactionsLoadMoreRequested event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;
    
    final newCount = current.visibleCount + _pageSize;
    emit(current.copyWith(
      visibleCount: newCount.clamp(0, current.filteredTransactions.length),
      hasMore: newCount < current.filteredTransactions.length,
    ));
  }

  void _onFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;
    
    final filtered = _applyFilter(current.allTransactions, event.filter, current.searchQuery);
    emit(TransactionLoaded(
      allTransactions: current.allTransactions,
      filteredTransactions: filtered,
      currentFilter: event.filter,
      searchQuery: current.searchQuery,
      hasMore: filtered.length > _pageSize,
      visibleCount: _pageSize,
    ));
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;
    
    final filtered = _applyFilter(current.allTransactions, current.currentFilter, event.query);
    emit(TransactionLoaded(
      allTransactions: current.allTransactions,
      filteredTransactions: filtered,
      currentFilter: current.currentFilter,
      searchQuery: event.query,
      hasMore: filtered.length > _pageSize,
      visibleCount: _pageSize,
    ));
  }

  void _onSearchCleared(
    SearchCleared event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;
    
    final filtered = _applyFilter(current.allTransactions, current.currentFilter, null);
    emit(TransactionLoaded(
      allTransactions: current.allTransactions,
      filteredTransactions: filtered,
      currentFilter: current.currentFilter,
      searchQuery: null,
      hasMore: filtered.length > _pageSize,
      visibleCount: _pageSize,
    ));
  }

  List<Transaction> _applyFilter(
    List<Transaction> transactions,
    String filter,
    String? query,
  ) {
    var result = transactions;

    final now = DateTime.now();
    switch (filter) {
      case "Aujourd'hui":
        result = result.where((t) {
          final d = t.date;
          return d.year == now.year && d.month == now.month && d.day == now.day;
        }).toList();
        break;
      case 'Cette semaine':
        final startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        result = result.where((t) => !t.date.isBefore(startOfWeek) && t.date.isBefore(endOfWeek)).toList();
        break;
      case 'Ce mois':
        result = result.where((t) => t.date.year == now.year && t.date.month == now.month).toList();
        break;
      default:
        break;
    }

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((t) {
        return t.label.toLowerCase().contains(q) ||
            t.status.toString().toLowerCase().contains(q) ||
            t.signedAmount.signedAmount.toLowerCase().contains(q) ||
            '${t.date.day}/${t.date.month}/${t.date.year}'.contains(q);
      }).toList();
    }

    return result;
  }
}
