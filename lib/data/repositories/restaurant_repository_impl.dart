import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../../domain/repositories/cacheable_restaurant_repository.dart';
import '../datasources/remote/restaurant_remote_datasource.dart';
import '../models/dto/restaurant_dto.dart';

class RestaurantRepositoryImpl
    implements RestaurantRepository, CacheableRestaurantRepository {
  RestaurantRepositoryImpl(this._remoteDataSource);

  final RestaurantRemoteDataSource _remoteDataSource;
  static const _cacheTtl = Duration(minutes: 5);
  List<Restaurant>? _cachedRestaurants;
  DateTime? _cacheTimestamp;

  @override
  Future<List<Restaurant>> getRestaurants({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cachedRestaurants != null &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < _cacheTtl) {
      return _cachedRestaurants!;
    }

    final response = await _remoteDataSource.getRestaurants();
    final restaurants = response
        .whereType<Map>()
        .map((json) => RestaurantDto.fromJson(Map<String, dynamic>.from(json)))
        .map((dto) => dto.toDomain())
        .toList(growable: false);
    _cachedRestaurants = restaurants;
    _cacheTimestamp = now;
    return restaurants;
  }
}
