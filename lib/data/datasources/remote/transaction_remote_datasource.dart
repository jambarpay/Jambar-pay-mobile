import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';

class TransactionRemoteDataSource {
  final ApiService apiService;

  TransactionRemoteDataSource(this.apiService);

  Future<List<dynamic>> getTransactions() async {
    final response = await apiService.get(BaseUrl.transactions());
    return _items(response);
  }

  Future<Map<String, dynamic>> getTransactionsPage({
    required int page,
    required int size,
  }) async {
    final response = await apiService.get(
      BaseUrl.transactions(),
      queryParameters: {'page': '$page', 'size': '$size'},
    );
    if (response is Map && response['content'] is List) {
      return Map<String, dynamic>.from(response);
    }
    if (response is List) {
      return {
        'content': response,
        'page': page,
        'size': response.length,
        'totalElements': response.length,
        'totalPages': response.isEmpty ? 0 : 1,
      };
    }
    return {
      'content': const <dynamic>[],
      'page': page,
      'size': 0,
      'totalElements': 0,
      'totalPages': 0,
    };
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
    return _items(response);
  }

  List<dynamic> _items(dynamic response) {
    if (response is List) return response;
    if (response is Map && response['content'] is List) {
      return List<dynamic>.from(response['content'] as List);
    }
    return const [];
  }
}
