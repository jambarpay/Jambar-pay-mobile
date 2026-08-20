import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';
import '../../repositories/cacheable_restaurant_repository.dart';

class GetRestaurants {
  const GetRestaurants(this._repository);

  final RestaurantRepository _repository;

  Future<List<Restaurant>> call({bool forceRefresh = false}) async {
    if (_repository is CacheableRestaurantRepository) {
      return (_repository as CacheableRestaurantRepository).getRestaurants(
        forceRefresh: forceRefresh,
      );
    }
    return _repository.getRestaurants();
  }
}
