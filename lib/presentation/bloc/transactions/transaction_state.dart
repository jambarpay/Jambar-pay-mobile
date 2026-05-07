import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> allTransactions;
  final List<Transaction> filteredTransactions;
  final String currentFilter;
  final String? searchQuery;
  final bool hasMore;
  final int visibleCount;

  const TransactionLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.currentFilter,
    this.searchQuery,
    this.hasMore = true,
    this.visibleCount = 4,
  });

  TransactionLoaded copyWith({
    List<Transaction>? allTransactions,
    List<Transaction>? filteredTransactions,
    String? currentFilter,
    String? searchQuery,
    bool? hasMore,
    int? visibleCount,
  }) {
    return TransactionLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      visibleCount: visibleCount ?? this.visibleCount,
    );
  }

  @override
  List<Object?> get props => [
        allTransactions,
        filteredTransactions,
        currentFilter,
        searchQuery,
        hasMore,
        visibleCount,
      ];
}

class TransactionEmpty extends TransactionState {
  final String? searchQuery;

  const TransactionEmpty({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class TransactionFailure extends TransactionState {
  final String errorMessage;

  const TransactionFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
