import '../entities/restaurant.dart';

abstract interface class RestaurantRepository {
  Future<List<Restaurant>> getRestaurants();
}
