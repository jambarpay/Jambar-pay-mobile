import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/value_objects/money.dart';
import '../datasources/remote/transaction_remote_datasource.dart';
import '../models/dto/transaction_dto.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _remoteDataSource.getTransactions();
      return response
          .map((json) => TransactionDto.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      // If the API is unavailable, return a small set of mock transactions
      print('TransactionRepositoryImpl ERROR: $e');
      final now = DateTime.now();
      return [
        Transaction(
          id: 'mock-1',
          type: TransactionType.debit,
          amount: Money.xof(1200),
          label: 'Keur Delice',
          date: now.subtract(const Duration(hours: 3)),
          status: TransactionStatus.validated,
        ),
        Transaction(
          id: 'mock-2',
          type: TransactionType.credit,
          amount: Money.xof(5000),
          label: 'Salaire',
          date: now.subtract(const Duration(days: 1)),
          status: TransactionStatus.validated,
        ),
        Transaction(
          id: 'mock-3',
          type: TransactionType.debit,
          amount: Money.xof(850),
          label: 'Achat',
          date: now.subtract(const Duration(days: 3)),
          status: TransactionStatus.pending,
        ),
        Transaction(
          id: 'mock-4',
          type: TransactionType.debit,
          amount: Money.xof(250),
          label: 'Taxi',
          date: now.subtract(const Duration(days: 7)),
          status: TransactionStatus.failed,
        ),
      ];
    }
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final json = await _remoteDataSource.getTransactionById(id);
      if (json == null) return null;
      return TransactionDto.fromJson(json).toDomain();
    } catch (e) {
      throw Exception('Impossible de trouver la transaction: ${e.toString()}');
    }
  }

  @override
  Future<List<Transaction>> getFilteredTransactions({
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
  }) async {
    try {
      final typeStr = type?.name.toUpperCase();
      final statusStr = status?.name.toLowerCase();
      
      final response = await _remoteDataSource.getFilteredTransactions(
        type: typeStr,
        startDate: startDate,
        endDate: endDate,
        status: statusStr,
      );
      return response
          .map((json) => TransactionDto.fromJson(json).toDomain())
          .toList();
    } catch (e) {
      throw Exception('Erreur de filtrage: ${e.toString()}');
    }
  }
}
