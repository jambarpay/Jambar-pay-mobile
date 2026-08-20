import '../entities/transaction_page.dart';

abstract interface class PaginatedTransactionRepository {
  Future<TransactionPage> getTransactionsPage({
    required int page,
    required int size,
  });
}
