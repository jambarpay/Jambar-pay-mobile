import '../../../core/errors/failure_handling.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';
import '../../../core/storage/secure_session_storage.dart';

class RestaurantRemoteDataSource {
  const RestaurantRemoteDataSource(this._apiService, [this._sessionStorage]);

  final ApiService _apiService;
  final SecureSessionStorage? _sessionStorage;

  Future<List<dynamic>> getRestaurants({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final cached = await _sessionStorage?.readRestaurantsCache();
        if (cached != null) return cached;
      } catch (error, stackTrace) {
        FailureDiagnostics.record(
          error,
          stackTrace,
          operation: 'restaurant_remote_datasource',
        );
        // Continue with the network request when the cache is unavailable.
      }
    }
    try {
      final response = await _apiService.get(BaseUrl.restaurants());
      if (response is! List) {
        throw const ApiException(
          'Format de restaurants invalide.',
          kind: FailureKind.invalidResponse,
        );
      }
      try {
        await _sessionStorage?.saveRestaurantsCache(response);
      } catch (error, stackTrace) {
        FailureDiagnostics.record(
          error,
          stackTrace,
          operation: 'restaurant_remote_datasource',
        );
        // Cache failures must not affect a successful network response.
      }
      return response;
    } catch (error) {
      if (!canUseCachedData(error)) rethrow;
      try {
        final cached = await _sessionStorage?.readRestaurantsCache();
        if (cached != null) return cached;
      } catch (error, stackTrace) {
        FailureDiagnostics.record(
          error,
          stackTrace,
          operation: 'restaurant_remote_datasource',
        );
        // Fall through to the original network error.
      }
      rethrow;
    }
  }
}
