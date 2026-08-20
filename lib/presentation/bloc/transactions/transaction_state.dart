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
  final int page;

  const TransactionLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.currentFilter,
    this.searchQuery,
    this.hasMore = true,
    this.visibleCount = 4,
    this.page = 0,
  });

  List<Transaction> get visibleTransactions =>
      filteredTransactions.take(visibleCount).toList(growable: false);

  TransactionLoaded copyWith({
    List<Transaction>? allTransactions,
    List<Transaction>? filteredTransactions,
    String? currentFilter,
    String? searchQuery,
    bool? hasMore,
    int? visibleCount,
    int? page,
  }) {
    return TransactionLoaded(
      allTransactions: allTransactions ?? this.allTransactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      currentFilter: currentFilter ?? this.currentFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      visibleCount: visibleCount ?? this.visibleCount,
      page: page ?? this.page,
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
    page,
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
