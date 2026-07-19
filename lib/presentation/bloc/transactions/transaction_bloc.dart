import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import '../../../domain/use_cases/transactions/get_transactions.dart';
import '../../../domain/use_cases/transactions/filter_transactions.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions _getTransactions;
  final FilterTransactions _filterTransactions;

  static const int _pageSize = 4;

  TransactionBloc({
    required GetTransactions getTransactions,
    required FilterTransactions filterTransactions,
  }) : _getTransactions = getTransactions,
       _filterTransactions = filterTransactions,
       super(const TransactionInitial()) {
    on<TransactionsLoadRequested>(_onLoadRequested);
    on<TransactionsRefreshRequested>(_onRefreshRequested);
    on<TransactionsLoadMoreRequested>(_onLoadMoreRequested);
    on<TransactionsFilterChanged>(_onFilterChanged);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCleared>(_onSearchCleared);
    on<LocalTransactionRegistered>(_onLocalTransactionRegistered);
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
        final filtered = _filterTransactions(transactions: all, filter: 'all');
        emit(
          TransactionLoaded(
            allTransactions: all,
            filteredTransactions: filtered,
            currentFilter: 'all',
            searchQuery: null,
            hasMore: filtered.length > _pageSize,
            visibleCount: _pageSize,
          ),
        );
      }
    } catch (e) {
      emit(TransactionFailure(e.toString()));
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
      final filtered = _filterTransactions(
        transactions: all,
        filter: current.currentFilter,
        query: current.searchQuery,
      );
      emit(
        current.copyWith(
          allTransactions: all,
          filteredTransactions: filtered,
          hasMore: filtered.length > _pageSize,
          visibleCount: _pageSize,
        ),
      );
    } catch (e) {
      emit(TransactionFailure(e.toString()));
    }
  }

  void _onLoadMoreRequested(
    TransactionsLoadMoreRequested event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;

    final newCount = current.visibleCount + _pageSize;
    emit(
      current.copyWith(
        visibleCount: newCount.clamp(0, current.filteredTransactions.length),
        hasMore: newCount < current.filteredTransactions.length,
      ),
    );
  }

  void _onFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;

    final filtered = _filterTransactions(
      transactions: current.allTransactions,
      filter: event.filter,
      query: current.searchQuery,
    );
    emit(
      TransactionLoaded(
        allTransactions: current.allTransactions,
        filteredTransactions: filtered,
        currentFilter: event.filter,
        searchQuery: current.searchQuery,
        hasMore: filtered.length > _pageSize,
        visibleCount: _pageSize,
      ),
    );
  }

  void _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<TransactionState> emit,
  ) {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;

    final filtered = _filterTransactions(
      transactions: current.allTransactions,
      filter: current.currentFilter,
      query: event.query,
    );
    emit(
      TransactionLoaded(
        allTransactions: current.allTransactions,
        filteredTransactions: filtered,
        currentFilter: current.currentFilter,
        searchQuery: event.query,
        hasMore: filtered.length > _pageSize,
        visibleCount: _pageSize,
      ),
    );
  }

  void _onSearchCleared(SearchCleared event, Emitter<TransactionState> emit) {
    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;

    final filtered = _filterTransactions(
      transactions: current.allTransactions,
      filter: current.currentFilter,
    );
    emit(
      TransactionLoaded(
        allTransactions: current.allTransactions,
        filteredTransactions: filtered,
        currentFilter: current.currentFilter,
        searchQuery: null,
        hasMore: filtered.length > _pageSize,
        visibleCount: _pageSize,
      ),
    );
  }

  void _onLocalTransactionRegistered(
    LocalTransactionRegistered event,
    Emitter<TransactionState> emit,
  ) {
    if (state is TransactionInitial || state is TransactionEmpty) {
      emit(
        TransactionLoaded(
          allTransactions: [event.transaction],
          filteredTransactions: [event.transaction],
          currentFilter: 'all',
          searchQuery: null,
          hasMore: false,
          visibleCount: 1,
        ),
      );
      return;
    }

    if (state is! TransactionLoaded) return;
    final current = state as TransactionLoaded;

    final updatedAllTransactions = [
      event.transaction,
      ...current.allTransactions,
    ];
    final updatedFilteredTransactions = _filterTransactions(
      transactions: updatedAllTransactions,
      filter: current.currentFilter,
      query: current.searchQuery,
    );

    emit(
      current.copyWith(
        allTransactions: updatedAllTransactions,
        filteredTransactions: updatedFilteredTransactions,
        hasMore: updatedFilteredTransactions.length > _pageSize,
        visibleCount: _pageSize,
      ),
    );
  }
}
