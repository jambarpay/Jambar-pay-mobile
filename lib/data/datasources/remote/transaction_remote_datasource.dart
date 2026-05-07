import '../../../ApiService/ApiService.dart';
import '../../../ApiService/BaseUrl.dart';

class TransactionRemoteDataSource {
  final ApiService apiService;

  TransactionRemoteDataSource(this.apiService);

  Future<List<dynamic>> getTransactions() async {
    final response = await apiService.get(BaseUrl.transactions());
    if (response is! List) return [];
    return response;
  }

  Future<Map<String, dynamic>?> getTransactionById(String id) async {
    final response = await apiService.get(BaseUrl.transactions(id));
    if (response is! Map<String, dynamic>) return null;
    return Map<String, dynamic>.from(response);
  }

  Future<List<dynamic>> getFilteredTransactions({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    if (status != null) queryParams['status'] = status;

    final response = await apiService.get(
      BaseUrl.transactions(),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (response is! List) return [];
    return response;
  }
}
