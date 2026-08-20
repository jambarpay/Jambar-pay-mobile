import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/paginated_transaction_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_page.dart';
import '../datasources/remote/transaction_remote_datasource.dart';
import '../models/dto/transaction_dto.dart';

class TransactionRepositoryImpl
    implements TransactionRepository, PaginatedTransactionRepository {
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
  Future<TransactionPage> getTransactionsPage({
    required int page,
    required int size,
  }) async {
    final response = await _remoteDataSource.getTransactionsPage(
      page: page,
      size: size,
    );
    final content = (response['content'] as List<dynamic>? ?? const [])
        .map((json) => TransactionDto.fromJson(json).toDomain())
        .toList(growable: false);
    return TransactionPage(
      transactions: content,
      page: (response['page'] as num?)?.toInt() ?? page,
      size: (response['size'] as num?)?.toInt() ?? size,
      totalElements: (response['totalElements'] as num?)?.toInt() ?? content.length,
      totalPages: (response['totalPages'] as num?)?.toInt() ?? (content.isEmpty ? 0 : 1),
    );
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
