import '../../domain/repositories/transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../datasources/remote/transaction_remote_datasource.dart';
import '../models/dto/transaction_dto.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
    final response = await _remoteDataSource.getTransactions();
    return response
        .map((json) => TransactionDto.fromJson(json).toDomain())
        .toList();
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
