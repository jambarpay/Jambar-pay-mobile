import 'package:equatable/equatable.dart';

import '../../../domain/entities/restaurant.dart';

sealed class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => const [];
}

final class RestaurantInitial extends RestaurantState {
  const RestaurantInitial();
}

final class RestaurantLoading extends RestaurantState {
  const RestaurantLoading();
}

final class RestaurantLoaded extends RestaurantState {
  const RestaurantLoaded(this.restaurants);

  final List<Restaurant> restaurants;

  @override
  List<Object?> get props => [restaurants];
}

final class RestaurantFailure extends RestaurantState {
  const RestaurantFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
