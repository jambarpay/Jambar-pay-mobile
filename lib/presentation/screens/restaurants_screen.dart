import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/domain/entities/restaurant.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_state.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_widgets.dart';
import '../widgets/restaurant_widgets.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({
    super.key,
    required this.onBackHome,
    required this.isDarkMode,
  });

  final VoidCallback onBackHome;
  final bool isDarkMode;

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  bool _showMap = false;
  String _searchQuery = '';

  List<Restaurant> _filteredRestaurants(List<Restaurant> restaurants) {
    if (_searchQuery.isEmpty) return restaurants;
    return restaurants
        .where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        final restaurants = state is RestaurantLoaded
            ? _filteredRestaurants(state.restaurants)
            : const <Restaurant>[];
        final palette = AppPalette(widget.isDarkMode);
        final loc = AppLocalizations.of(context);

        return Column(
          children: [
            SubPageHeader(
              title: loc.restaurants,
              onBack: widget.onBackHome,
              trailing: TogglePill(
                leftLabel: loc.map,
                rightLabel: loc.list,
                isLeftSelected: _showMap,
                onLeftTap: () => setState(() => _showMap = true),
                onRightTap: () => setState(() => _showMap = false),
                isDarkMode: widget.isDarkMode,
              ),
              subtitle: loc.restaurantsNearby(restaurants.length),
              isDarkMode: widget.isDarkMode,
            ),
            Expanded(
              child: ColoredBox(
                color: palette.pageBackground,
                child: switch (state) {
                  RestaurantInitial() || RestaurantLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  RestaurantFailure(:final message) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(message, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => context.read<RestaurantBloc>().add(
                              const RestaurantsLoadRequested(),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: Text(loc.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RestaurantLoaded() =>
                    _showMap
                        ? RestaurantsMapView(
                            isDarkMode: widget.isDarkMode,
                            restaurants: restaurants,
                          )
                        : RestaurantsListView(
                            isDarkMode: widget.isDarkMode,
                            restaurants: restaurants,
                            onSearchChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                          ),
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
