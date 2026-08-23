import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';
import '../../../core/storage/secure_session_storage.dart';

class TransactionRemoteDataSource {
  final ApiService apiService;
  final SecureSessionStorage? _sessionStorage;

  TransactionRemoteDataSource(this.apiService, [this._sessionStorage]);

  Future<List<dynamic>> getTransactions() async {
    try {
      final response = await apiService.get(BaseUrl.transactions());
      final items = _items(response);
      await _saveCache(items);
      return items;
    } catch (error) {
      final cached = await _readCache();
      if (cached != null) return cached;
      throw error;
    }
  }

  Future<Map<String, dynamic>> getTransactionsPage({
    required int page,
    required int size,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && page == 0) {
      final cached = await _readCache();
      if (cached != null) {
        return {
          'content': cached,
          'page': 0,
          'size': cached.length,
          'totalElements': cached.length,
          'totalPages': cached.isEmpty ? 0 : 1,
        };
      }
    }
    try {
      final response = await apiService.get(
        BaseUrl.transactions(),
        queryParameters: {'page': '$page', 'size': '$size'},
      );
      final normalized = _page(response, page);
      await _saveCache(normalized['content'] as List<dynamic>);
      return normalized;
    } catch (error) {
      if (page == 0) {
        final cached = await _readCache();
        if (cached != null) {
          return {
            'content': cached,
            'page': 0,
            'size': cached.length,
            'totalElements': cached.length,
            'totalPages': cached.isEmpty ? 0 : 1,
          };
        }
      }
      throw error;
    }
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

    try {
      final response = await apiService.get(
        BaseUrl.transactions(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final items = _items(response);
      await _saveCache(items);
      return items;
    } catch (error) {
      final cached = await _readCache();
      if (cached != null) return cached;
      throw error;
    }
  }

  Map<String, dynamic> _page(dynamic response, int page) {
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

  Future<void> _saveCache(List<dynamic> items) async {
    try {
      await _sessionStorage?.saveTransactionsCache(items);
    } catch (_) {
      // Cache failures must not affect a successful network response.
    }
  }

  Future<List<dynamic>?> _readCache() async {
    try {
      return await _sessionStorage?.readTransactionsCache();
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _items(dynamic response) {
    if (response is List) return response;
    if (response is Map && response['content'] is List) {
      return List<dynamic>.from(response['content'] as List);
    }
    return const [];
  }
}
