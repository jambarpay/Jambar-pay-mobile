import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/domain/entities/restaurant.dart';
import 'package:jambar_pay_mobile/domain/entities/partner_category.dart';
import 'package:jambar_pay_mobile/domain/use_cases/restaurants/filter_partners.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_state.dart';
import '../widgets/app_palette.dart';
import '../widgets/home_widgets.dart';
import '../widgets/restaurant_widgets.dart' as partner_widgets;
import '../widgets/partner_service_widgets.dart';
import '../models/mobile_employee_space.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({
    super.key,
    required this.onBackHome,
    required this.isDarkMode,
    this.userProfile,
    this.wallet,
    this.onQrTap,
  });

  final VoidCallback onBackHome;
  final bool isDarkMode;
  final UserProfileModel? userProfile;
  final WalletSummaryModel? wallet;
  final VoidCallback? onQrTap;

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  bool _showMap = false;
  bool _browsing = false;
  PartnerCategory? _category;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _back() {
    if (!_browsing) {
      widget.onBackHome();
      return;
    }
    setState(() => _browsing = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantBloc, RestaurantState>(
      builder: (context, state) {
        final restaurants = state is RestaurantLoaded
            ? filterPartners(
                state.restaurants,
                category: _category,
                query: _searchController.text,
              )
            : const <Restaurant>[];
        final palette = AppPalette(widget.isDarkMode);
        final loc = AppLocalizations.of(context);
        final separateViewToggle =
            MediaQuery.sizeOf(context).width < 360 ||
            MediaQuery.textScalerOf(context).scale(16) > 21;
        final viewToggle = TogglePill(
          leftLabel: loc.map,
          rightLabel: loc.list,
          isLeftSelected: _showMap,
          onLeftTap: () => setState(() => _showMap = true),
          onRightTap: () => setState(() => _showMap = false),
          isDarkMode: widget.isDarkMode,
        );

        return Column(
          children: [
            if (widget.userProfile != null)
              EmployeeHeroHeader(
                userProfile: widget.userProfile!,
                wallet: widget.wallet,
                onQrTap: widget.onQrTap ?? () {},
                isDarkMode: widget.isDarkMode,
                showBalanceCard: false,
              ),
            SubPageHeader(
              title: loc.services,
              onBack: _back,
              trailing: !_browsing || separateViewToggle ? null : viewToggle,
              subtitle: _browsing ? loc.partnerCount(restaurants.length) : null,
              isDarkMode: widget.isDarkMode,
            ),
            if (_browsing) ...[
              if (separateViewToggle)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: viewToggle,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: partner_widgets.SearchBar(
                  controller: _searchController,
                  isDarkMode: widget.isDarkMode,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              PartnerCategoryFilters(
                selectedCategory: _category,
                isDarkMode: widget.isDarkMode,
                onSelected: (category) => setState(() => _category = category),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: ColoredBox(
                color: palette.pageBackground,
                child: !_browsing
                    ? PartnerServicePicker(
                        isDarkMode: widget.isDarkMode,
                        selectedCategory: _category,
                        onSelected: (category) =>
                            setState(() => _category = category),
                        onContinue: () => setState(() {
                          _searchController.clear();
                          _browsing = true;
                        }),
                        onShowAll: () => setState(() {
                          _category = null;
                          _searchController.clear();
                          _browsing = true;
                        }),
                      )
                    : switch (state) {
                        RestaurantInitial() || RestaurantLoading() =>
                          const Center(child: CircularProgressIndicator()),
                        RestaurantFailure(:final message) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(message, textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  onPressed: () => context
                                      .read<RestaurantBloc>()
                                      .add(const RestaurantsLoadRequested()),
                                  icon: const Icon(Icons.refresh),
                                  label: Text(loc.retry),
                                ),
                              ],
                            ),
                          ),
                        ),
                        RestaurantLoaded() =>
                          _showMap && restaurants.isNotEmpty
                              ? partner_widgets.RestaurantsMapView(
                                  key: ValueKey(
                                    restaurants
                                        .map((partner) => partner.id)
                                        .join(','),
                                  ),
                                  isDarkMode: widget.isDarkMode,
                                  restaurants: restaurants,
                                )
                              : partner_widgets.RestaurantsListView(
                                  isDarkMode: widget.isDarkMode,
                                  restaurants: restaurants,
                                  emptyMessage:
                                      _searchController.text.trim().isNotEmpty
                                      ? loc.noPartnersMatch
                                      : _category == null
                                      ? loc.noPartnersAvailable
                                      : loc.noPartnersInCategory,
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
