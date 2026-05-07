import '../../repositories/transaction_repository.dart';
import '../../entities/transaction.dart';

class GetTransactionById {
  final TransactionRepository _transactionRepository;

  GetTransactionById(this._transactionRepository);

  Future<Transaction?> call(String id) {
    return _transactionRepository.getTransactionById(id);
  }
}
