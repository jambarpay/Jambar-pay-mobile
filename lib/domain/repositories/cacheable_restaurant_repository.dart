import '../entities/restaurant.dart';

abstract interface class CacheableRestaurantRepository {
  Future<List<Restaurant>> getRestaurants({bool forceRefresh = false});
}
