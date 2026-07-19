import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/domain/entities/restaurant.dart';
import 'package:jambar_pay_mobile/domain/repositories/restaurant_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/restaurants/get_restaurants.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_state.dart';

void main() {
  test('loads restaurants through the domain boundary', () async {
    final bloc = RestaurantBloc(
      getRestaurants: GetRestaurants(_FakeRestaurantRepository()),
    );
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RestaurantLoading>(),
        isA<RestaurantLoaded>().having(
          (state) => state.restaurants.single.name,
          'restaurant name',
          'Le FOOD',
        ),
      ]),
    );

    bloc.add(const RestaurantsLoadRequested());

    await expectation;
  });
}

class _FakeRestaurantRepository implements RestaurantRepository {
  @override
  Future<List<Restaurant>> getRestaurants() async => [
    Restaurant(
      id: 'rest-1',
      name: 'Le FOOD',
      distanceKm: 0.3,
      updatedAt: DateTime(2030),
      isOpen: true,
      latitude: 14.7165,
      longitude: -17.4672,
    ),
  ];
}
