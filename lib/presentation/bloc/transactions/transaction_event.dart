import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsLoadRequested extends TransactionEvent {
  const TransactionsLoadRequested();
}

class TransactionsRefreshRequested extends TransactionEvent {
  const TransactionsRefreshRequested();
}


class TransactionsLoadMoreRequested extends TransactionEvent {
  const TransactionsLoadMoreRequested();
}

class TransactionsFilterChanged extends TransactionEvent {
  final String filter; 
  final String? searchQuery;

  const TransactionsFilterChanged(this.filter, {this.searchQuery});

  @override
  List<Object?> get props => [filter, searchQuery];
}

class SearchQueryChanged extends TransactionEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchCleared extends TransactionEvent {
  const SearchCleared();
}
