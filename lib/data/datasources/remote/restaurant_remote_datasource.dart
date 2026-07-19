import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';

class RestaurantRemoteDataSource {
  const RestaurantRemoteDataSource(this._apiService);

  final ApiService _apiService;

  Future<List<dynamic>> getRestaurants() async {
    final response = await _apiService.get(BaseUrl.restaurants());
    if (response is! List) {
      throw const ApiException('Format de restaurants invalide.');
    }
    return response;
  }
}
