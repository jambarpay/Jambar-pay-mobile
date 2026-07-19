import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/remote/restaurant_remote_datasource.dart';
import '../models/dto/restaurant_dto.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  const RestaurantRepositoryImpl(this._remoteDataSource);

  final RestaurantRemoteDataSource _remoteDataSource;

  @override
  Future<List<Restaurant>> getRestaurants() async {
    final response = await _remoteDataSource.getRestaurants();
    return response
        .whereType<Map>()
        .map((json) => RestaurantDto.fromJson(Map<String, dynamic>.from(json)))
        .map((dto) => dto.toDomain())
        .toList(growable: false);
  }
}
