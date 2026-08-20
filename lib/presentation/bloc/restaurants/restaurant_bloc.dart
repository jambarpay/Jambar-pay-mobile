import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/restaurants/get_restaurants.dart';
import 'restaurant_event.dart';
import 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  RestaurantBloc({required GetRestaurants getRestaurants})
    : _getRestaurants = getRestaurants,
      super(const RestaurantInitial()) {
    on<RestaurantsLoadRequested>(_load);
    on<RestaurantsRefreshRequested>(_refresh);
  }

  final GetRestaurants _getRestaurants;

  Future<void> _load(
    RestaurantsLoadRequested event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(const RestaurantLoading());
    try {
      emit(RestaurantLoaded(await _getRestaurants()));
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
