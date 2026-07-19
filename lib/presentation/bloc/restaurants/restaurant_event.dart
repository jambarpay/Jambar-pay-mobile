import 'package:equatable/equatable.dart';

sealed class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object?> get props => const [];
}

final class RestaurantsLoadRequested extends RestaurantEvent {
  const RestaurantsLoadRequested();
}

final class RestaurantsRefreshRequested extends RestaurantEvent {
  const RestaurantsRefreshRequested();
}
