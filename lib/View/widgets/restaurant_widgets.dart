import 'package:flutter/material.dart';
import '../models/mobile_employee_space.dart';
import 'app_palette.dart';
import 'home_widgets.dart';

class RestaurantsListView extends StatefulWidget {
  const RestaurantsListView({
    super.key,
    required this.isDarkMode,
    required this.restaurants,
    this.onSearchChanged,
  });

  final bool isDarkMode;
  final List<RestaurantPartnerModel> restaurants;
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
    final palette = AppPalette(widget.isDarkMode);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      children: [
        SearchBar(
          isDarkMode: widget.isDarkMode,
          controller: _searchController,
          onChanged: widget.onSearchChanged,
        ),
        const SizedBox(height: 18),
        Container(
          color: widget.isDarkMode ? palette.sectionContainer : Colors.transparent,
          padding: EdgeInsets.all(widget.isDarkMode ? 12 : 0),
          child: Column(
            children: [
              for (var index = 0; index < widget.restaurants.length; index++) ...[
                RestaurantCard(
                  restaurant: widget.restaurants[index],
                  isDarkMode: widget.isDarkMode,
                ),
                if (index != widget.restaurants.length - 1) const SizedBox(height: 14),
              ],
            ],
          ),
        ),
      ],
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
  final List<RestaurantPartnerModel> restaurants;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const FakeMap(),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Container(
            color: isDarkMode ? palette.sectionContainer : Colors.transparent,
            padding: EdgeInsets.all(isDarkMode ? 12 : 0),
            child: Column(
              children: [
                const SectionHeader(title: 'Restaurants a proximite'),
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
        color: widget.isDarkMode ? palette.tileBackground : const Color(0xFFEAE9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: TextStyle(
          color: widget.isDarkMode ? palette.primaryText : const Color(0xFF1C1A33),
          fontSize: 13.5,
        ),
        decoration: InputDecoration(
          hintText: 'rechercher un restaurant',
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

  final RestaurantPartnerModel restaurant;
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
                  restaurant.updatedAt,
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
                restaurant.distance,
                style: const TextStyle(
                  color: Color(0xFFF57C21),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                restaurant.isOpen ? 'Ouvert' : 'Ferme',
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

class FakeMap extends StatelessWidget {
  const FakeMap();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4E9D8), Color(0xFFE7DBC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: MapPainter())),
          const Positioned(
            top: 150,
            right: 90,
            child: Icon(Icons.location_on, color: Color(0xFF4CA5F5), size: 42),
          ),
        ],
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFD5BE92)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final smallRoadPaint = Paint()
      ..color = const Color(0xFFF7F0E0)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final mainRoads = [
      [Offset(0, 40), Offset(size.width, 20)],
      [Offset(0, 120), Offset(size.width, 170)],
      [Offset(0, 220), Offset(size.width, 250)],
      [Offset(40, 0), Offset(120, size.height)],
      [Offset(180, 0), Offset(250, size.height)],
      [Offset(300, 0), Offset(size.width - 20, size.height)],
    ];

    for (final road in mainRoads) {
      canvas.drawLine(road.first, road.last, roadPaint);
    }

    for (var i = 0; i < 8; i++) {
      canvas.drawLine(
        Offset(0, 24.0 + (i * 42)),
        Offset(size.width, 34.0 + (i * 42)),
        smallRoadPaint,
      );
    }

    for (var i = 0; i < 7; i++) {
      canvas.drawLine(
        Offset(20.0 + (i * 52), 0),
        Offset(24.0 + (i * 52), size.height),
        smallRoadPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
