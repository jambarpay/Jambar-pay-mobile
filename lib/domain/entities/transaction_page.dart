import 'transaction.dart';

/// A page returned by the payment API.
///
/// Keeping the pagination metadata in the domain prevents the UI from
/// guessing whether another network request is necessary.
class TransactionPage {
  const TransactionPage({
    required this.transactions,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<Transaction> transactions;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  bool get hasMore => page + 1 < totalPages;
}
