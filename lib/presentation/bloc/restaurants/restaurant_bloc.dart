import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/restaurants/get_restaurants.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  RestaurantBloc({
    required GetRestaurants getRestaurants,
    bool backgroundSync = true,
  }) : _getRestaurants = getRestaurants,
       _backgroundSync = backgroundSync,
       super(const RestaurantInitial()) {
    on<RestaurantsLoadRequested>(_load);
    on<RestaurantsRefreshRequested>(_refresh);
  }

  final GetRestaurants _getRestaurants;
  final bool _backgroundSync;

  Future<void> _load(
    RestaurantsLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    try {
      emit(RestaurantLoaded(await _getRestaurants()));
      if (_backgroundSync) {
        try {
          emit(RestaurantLoaded(await _getRestaurants(forceRefresh: true)));
        } catch (_) {
          // The cached restaurants remain usable while the device is offline.
        }
      }
    } catch (error) {
      emit(RestaurantFailure(error.toString()));
    }
  }

  Future<void> _refresh(
    RestaurantsRefreshRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    try {
      emit(RestaurantLoaded(await _getRestaurants(forceRefresh: true)));
    } catch (error) {
      emit(RestaurantFailure(error.toString()));
    }
  }
}
