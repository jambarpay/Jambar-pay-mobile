import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:jambar_pay_mobile/domain/entities/restaurant.dart';
import 'app_palette.dart';
import 'home_widgets.dart';

String _formatUpdatedAt(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final time = '${date.hour}h${date.minute.toString().padLeft(2, '0')}';
  final loc = AppLocalizations.of(context);
  if (DateUtils.isSameDay(date, now)) return loc.todayAt(time);
  if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return loc.yesterdayAt(time);
  }
  return loc.dateTime('${date.day}/${date.month}/${date.year}', time);
}

class RestaurantsListView extends StatefulWidget {
  const RestaurantsListView({
    super.key,
    required this.isDarkMode,
    required this.restaurants,
    this.onSearchChanged,
  });

  final bool isDarkMode;
  final List<Restaurant> restaurants;
  final ValueChanged<String>? onSearchChanged;

  @override
  State<RestaurantsListView> createState() => _RestaurantsListViewState();
}

class _RestaurantsListViewState extends State<RestaurantsListView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      itemCount: widget.restaurants.isEmpty ? 2 : widget.restaurants.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == 0) {
          return SearchBar(
            isDarkMode: widget.isDarkMode,
            controller: _searchController,
            onChanged: widget.onSearchChanged,
          );
        }
        if (widget.restaurants.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(AppLocalizations.of(context).noRestaurantsAvailable),
            ),
          );
        }
        return RestaurantCard(
          restaurant: widget.restaurants[index - 1],
          isDarkMode: widget.isDarkMode,
        );
      },
    );
  }
}

class RestaurantsMapView extends StatelessWidget {
  const RestaurantsMapView({
    super.key,
    required this.isDarkMode,
    required this.restaurants,
  });

  final bool isDarkMode;
  final List<Restaurant> restaurants;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        RestaurantMap(restaurants: restaurants, isDarkMode: isDarkMode),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Container(
            color: isDarkMode ? palette.sectionContainer : Colors.transparent,
            padding: EdgeInsets.all(isDarkMode ? 12 : 0),
            child: Column(
              children: [
                SectionHeader(
                  title: AppLocalizations.of(
                    context,
                  ).restaurantsNearby(restaurants.length.toString()),
                ),
                for (
                  var index = 0;
                  index < restaurants.take(2).length;
                  index++
                ) ...[
                  RestaurantCard(
                    restaurant: restaurants[index],
                    isDarkMode: isDarkMode,
                  ),
                  if (index == 0) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RestaurantMap extends StatelessWidget {
  const RestaurantMap({
    super.key,
    required this.restaurants,
    required this.isDarkMode,
  });

  final List<Restaurant> restaurants;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    if (restaurants.isEmpty) {
      return Container(
        height: 360,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        decoration: BoxDecoration(
          color: isDarkMode
              ? palette.sectionContainer
              : const Color(0xFFF3F2FB),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          AppLocalizations.of(context).noTransactionsAvailable,
          style: TextStyle(
            color: palette.secondaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final center = _averagePosition(restaurants);

    return Container(
      height: 360,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF343254) : const Color(0xFFE1DFF3),
        ),
      ),
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.2,
              minZoom: 12,
              maxZoom: 18.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.jambarpay.jambar_pay_mobile',
              ),
              MarkerLayer(
                markers: [
                  for (final restaurant in restaurants)
                    Marker(
                      point: LatLng(restaurant.latitude, restaurant.longitude),
                      width: 124,
                      height: 72,
                      child: _RestaurantMapMarker(
                        restaurant: restaurant,
                        isDarkMode: isDarkMode,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: _MapOverlayHeader(
              restaurants: restaurants,
              isDarkMode: isDarkMode,
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  '© OpenStreetMap',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A3952),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LatLng _averagePosition(List<Restaurant> restaurants) {
    final totalLat = restaurants.fold<double>(
      0,
      (sum, restaurant) => sum + restaurant.latitude,
    );
    final totalLng = restaurants.fold<double>(
      0,
      (sum, restaurant) => sum + restaurant.longitude,
    );

    return LatLng(totalLat / restaurants.length, totalLng / restaurants.length);
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({
    super.key,
    this.isDarkMode = false,
    this.controller,
    this.onChanged,
  });

  final bool isDarkMode;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? palette.tileBackground
            : const Color(0xFFEAE9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: widget.isDarkMode
              ? palette.primaryText
              : const Color(0xFF1C1A33),
          fontSize: 13.5,
        ),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).searchRestaurant,
          hintStyle: TextStyle(
            color: widget.isDarkMode
                ? const Color(0xFF8B86B8)
                : const Color(0xFF88879A),
            fontSize: 13.5,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: widget.isDarkMode
                ? const Color(0xFF6A64D8)
                : const Color(0xFF88879A),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.isDarkMode = false,
  });

  final Restaurant restaurant;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? palette.tileBackground : const Color(0xFFEFEFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF251F32)
                  : const Color(0xFFFFEFE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant_outlined,
              size: 16,
              color: Color(0xFFF57C21),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurant.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? palette.primaryText : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatUpdatedAt(context, restaurant.updatedAt),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDarkMode
                        ? const Color(0xFF787392)
                        : const Color(0xFF8A8898),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${restaurant.distanceKm.toStringAsFixed(1)} km',
                style: const TextStyle(
                  color: Color(0xFFF57C21),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                restaurant.isOpen
                    ? AppLocalizations.of(context).open
                    : AppLocalizations.of(context).closed,
                style: TextStyle(
                  color: restaurant.isOpen
                      ? const Color(0xFF11B777)
                      : Colors.red,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RestaurantMapMarker extends StatelessWidget {
  const _RestaurantMapMarker({
    required this.restaurant,
    required this.isDarkMode,
  });

  final Restaurant restaurant;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1A35) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            restaurant.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : const Color(0xFF1C1A33),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -2),
          child: Icon(
            Icons.location_on,
            size: 34,
            color: restaurant.isOpen
                ? const Color(0xFFF57C21)
                : const Color(0xFFB84A62),
          ),
        ),
      ],
    );
  }
}

class _MapOverlayHeader extends StatelessWidget {
  const _MapOverlayHeader({
    required this.restaurants,
    required this.isDarkMode,
  });

  final List<Restaurant> restaurants;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final openCount = restaurants
        .where((restaurant) => restaurant.isOpen)
        .length;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xD91E1A35)
                  : const Color(0xEFFFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.storefront, size: 18, color: palette.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${restaurants.length} • $openCount ${AppLocalizations.of(context).open.toLowerCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF1C1A33),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
