import '../../entities/restaurant.dart';
import '../../repositories/restaurant_repository.dart';

class GetRestaurants {
  const GetRestaurants(this._repository);

  final RestaurantRepository _repository;

  Future<List<Restaurant>> call() => _repository.getRestaurants();
}
