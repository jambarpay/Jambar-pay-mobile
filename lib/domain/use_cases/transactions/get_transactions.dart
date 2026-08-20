import '../../repositories/transaction_repository.dart';
import '../../entities/transaction_page.dart';
import '../../repositories/paginated_transaction_repository.dart';

class GetTransactions {
  final TransactionRepository _transactionRepository;

  GetTransactions(this._transactionRepository);

  Future<TransactionPage> call({int page = 0, int size = 4}) async {
    if (_transactionRepository is PaginatedTransactionRepository) {
      return (_transactionRepository as PaginatedTransactionRepository)
          .getTransactionsPage(page: page, size: size);
    }

    // Compatibility fallback for local/test repositories that have not yet
    // implemented pagination. The production repository uses the branch
    // above and sends page/size to the payment service.
    final all = await _transactionRepository.getTransactions();
    final from = (page * size).clamp(0, all.length).toInt();
    final to = (from + size).clamp(from, all.length).toInt();
    final content = all.sublist(from, to);
    return TransactionPage(
      transactions: content,
      page: page,
      size: size,
      totalElements: all.length,
      totalPages: all.isEmpty ? 0 : (all.length / size).ceil(),
    );
  }
}
