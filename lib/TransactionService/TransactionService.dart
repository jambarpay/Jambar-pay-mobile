import '../ApiService/ApiService.dart';
import '../di.dart' as di;
import '../ApiService/BaseUrl.dart';
import '../Entity/TransactionEntity.dart';

class TransactionService {
  final ApiService apiService;

  TransactionService({ApiService? apiService})
    : apiService = apiService ?? di.apiService;

  Future<List<TransactionEntity>> getTransactions() async {
    final response = await apiService.get(BaseUrl.transactions());
    if (response is! List) {
      return [];
    }

    return response
        .map(
          (item) => TransactionEntity.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<TransactionEntity?> getTransactionById(String id) async {
    final response = await apiService.get(BaseUrl.transactions(id));
    if (response is! Map) {
      return null;
    }

    return TransactionEntity.fromJson(Map<String, dynamic>.from(response));
  }
}
