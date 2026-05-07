import 'package:flutter/material.dart';
import '../models/mobile_employee_space.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_widgets.dart';
import '../widgets/restaurant_widgets.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({
    super.key,
    required this.onBackHome,
    required this.isDarkMode,
    required this.restaurants,
  });

  final VoidCallback onBackHome;
  final bool isDarkMode;
  final List<RestaurantPartnerModel> restaurants;

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(widget.isDarkMode);

    return Column(
      children: [
        SubPageHeader(
          title: 'Restaurants',
          onBack: widget.onBackHome,
          trailing: TogglePill(
            leftLabel: 'Carte',
            rightLabel: 'Liste',
            isLeftSelected: _showMap,
            onLeftTap: () => setState(() => _showMap = true),
            onRightTap: () => setState(() => _showMap = false),
            isDarkMode: widget.isDarkMode,
          ),
          subtitle: '${widget.restaurants.length} restaurants pres de vous',
          isDarkMode: widget.isDarkMode,
        ),
        Expanded(
          child: ColoredBox(
            color: palette.pageBackground,
            child: _showMap
                ? RestaurantsMapView(
                    isDarkMode: widget.isDarkMode,
                    restaurants: widget.restaurants,
                  )
                : RestaurantsListView(
                    isDarkMode: widget.isDarkMode,
                    restaurants: widget.restaurants,
                  ),
          ),
        ),
      ],
    );
  }
}
