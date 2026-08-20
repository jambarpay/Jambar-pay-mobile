import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jambar_pay_mobile/app/router/app_router.dart';
import 'package:jambar_pay_mobile/domain/entities/restaurant.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_state.dart';
import '../models/mobile_employee_space.dart';
import '../widgets/app_palette.dart';
import '../widgets/balance_card.dart';
import '../widgets/home_widgets.dart';
import '../widgets/restaurant_widgets.dart';
import 'package:jambar_pay_mobile/design_system/tokens/app_colors.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.onTabSelected,
    required this.isDarkMode,
    required this.appState,
  });

  final ValueChanged<int> onTabSelected;
  final bool isDarkMode;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette(isDarkMode);
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 48, 22, 18),
          decoration: BoxDecoration(color: palette.headerBackground),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour',
                          style: TextStyle(
                            color: palette.onHeaderMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appState.userProfile.name,
                          style: TextStyle(
                            color: palette.onHeader,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.brand,
                    child: Text(
                      appState.userProfile.name.isEmpty
                          ? '?'
                          : appState.userProfile.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BalanceCard(
                isDarkMode: isDarkMode,
                wallet: appState.wallet,
                onQrTap: () async {
                  final selectedTab = await context.push<int>(
                    AppRoutes.qrScanner,
                  );
                  if (selectedTab != null && context.mounted) {
                    onTabSelected(selectedTab);
                  }
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Recharge employeur',
                  style: TextStyle(
                    color: palette.onHeaderMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: palette.pageBackground,
            child: Column(
              children: [
                QuickActionGrid(
                  scanLabel: loc.scan,
                  restaurantsLabel: loc.restaurants,
                  historyLabel: loc.history,
                  statementLabel: 'Relevé',
                  onScan: () async {
                    final selectedTab = await context.push<int>(
                      AppRoutes.qrScanner,
                    );
                    if (selectedTab != null && context.mounted) {
                      onTabSelected(selectedTab);
                    }
                  },
                  onRestaurants: () => onTabSelected(2),
                  onHistory: () => onTabSelected(1),
                  onStatement: () => onTabSelected(1),
                  isDarkMode: isDarkMode,
                ),
                SectionHeader(
                  title: loc.restaurantsNearby(
                    context.select<RestaurantBloc, int>((bloc) {
                      final state = bloc.state;
                      return state is RestaurantLoaded
                          ? state.restaurants.length
                          : 0;
                    }),
                  ),
                  actionLabel: loc.viewAll,
                  onActionTap: () => onTabSelected(2),
                  isDarkMode: isDarkMode,
                ),
                Expanded(
                  child: BlocBuilder<RestaurantBloc, RestaurantState>(
                    builder: (context, state) {
                      if (state is RestaurantInitial ||
                          state is RestaurantLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is RestaurantFailure) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                ),
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
                        );
                      }

                      final restaurants = state is RestaurantLoaded
                          ? [...state.restaurants]
                          : const <Restaurant>[];
                      restaurants.sort(
                        (left, right) =>
                            left.distanceKm.compareTo(right.distanceKm),
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: RestaurantMap(
                          restaurants: restaurants
                              .where((restaurant) => restaurant.hasCoordinates)
                              .toList(),
                          height: 270,
                          isDarkMode: isDarkMode,
                        ),
                      );
                    },
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
