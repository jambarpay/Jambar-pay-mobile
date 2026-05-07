import '../../repositories/transaction_repository.dart';
import '../../entities/transaction.dart';

class GetTransactions {
  final TransactionRepository _transactionRepository;

  GetTransactions(this._transactionRepository);

  Future<List<Transaction>> call() {
    return _transactionRepository.getTransactions();
  }
}
