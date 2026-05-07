import '../../repositories/transaction_repository.dart';
import '../../entities/transaction.dart';

class FilterTransactions {
  final TransactionRepository _transactionRepository;

  FilterTransactions(this._transactionRepository);

  Future<List<Transaction>> call({
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
  }) {
    return _transactionRepository.getFilteredTransactions(
      type: type,
      startDate: startDate,
      endDate: endDate,
      status: status,
    );
  }
}
