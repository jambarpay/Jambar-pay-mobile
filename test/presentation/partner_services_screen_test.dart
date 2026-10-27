import 'package:jambar_pay_mobile/domain/errors/app_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/domain/entities/partner_category.dart';
import 'package:jambar_pay_mobile/domain/entities/restaurant.dart';
import 'package:jambar_pay_mobile/domain/repositories/restaurant_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/restaurants/get_restaurants.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/restaurants/restaurant_event.dart';
import 'package:jambar_pay_mobile/presentation/screens/restaurants_screen.dart';
import 'package:jambar_pay_mobile/presentation/widgets/restaurant_widgets.dart'
    as partners;

void main() {
  testWidgets('employee chooses a service before browsing its real partners', (
    tester,
  ) async {
    final repository = _Repository();
    await _pumpScreen(tester, repository);
    expect(find.text('Choisissez un service'), findsOneWidget);
    for (final category in PartnerCategory.selectable) {
      expect(find.byKey(ValueKey('service-${category.name}')), findsOneWidget);
    }
    expect(
      tester
          .widget<FilledButton>(find.byKey(const ValueKey('service-continue')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const ValueKey('service-shop')));
    await tester.pump();
    expect(find.text('✓ Sélectionné'), findsOneWidget);
    await _tapVisible(tester, 'service-continue');
    expect(_listed(tester).map((p) => p.id), ['shop']);
    expect(find.text('1 partenaire'), findsOneWidget);
    expect(repository.calls, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'all partners and category chips combine with name/address search',
    (tester) async {
      final repository = _Repository();
      await _pumpScreen(tester, repository);
      await _tapVisible(tester, 'service-show-all');
      expect(_listed(tester).length, 4);
      await _tapVisible(tester, 'filter-shop');
      expect(_listed(tester).map((p) => p.id), ['shop']);
      await tester.enterText(find.byType(TextField), 'YOFF');
      await tester.pumpAndSettle();
      expect(_listed(tester).map((p) => p.id), ['shop']);
      await tester.enterText(find.byType(TextField), 'introuvable');
      await tester.pumpAndSettle();
      expect(_listed(tester), isEmpty);
      expect(
        find.text('Aucun partenaire ne correspond à votre recherche.'),
        findsOneWidget,
      );
      await _tapVisible(tester, 'filter-all');
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(_listed(tester).length, 4);
      expect(repository.calls, 1);
    },
  );

  testWidgets(
    'map and list use the same category and preserve the search text',
    (tester) async {
      await _pumpScreen(tester, _Repository());
      await tester.tap(find.byKey(const ValueKey('service-restaurant')));
      await _tapVisible(tester, 'service-continue');
      await tester.enterText(find.byType(TextField), 'Bistro');
      await tester.tap(find.text('Carte'));
      await tester.pumpAndSettle();
      final map = tester.widget<partners.RestaurantsMapView>(
        find.byType(partners.RestaurantsMapView),
      );
      expect(map.restaurants.map((p) => p.id), ['restaurant']);
      await tester.tap(find.text('Liste'));
      await tester.pumpAndSettle();
      expect(_listed(tester).map((p) => p.id), ['restaurant']);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Bistro',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty category offers all partners without inventing results', (
    tester,
  ) async {
    final repository = _Repository()
      ..data = [_partner('restaurant', PartnerCategory.restaurant)];
    await _pumpScreen(tester, repository);
    await tester.tap(find.byKey(const ValueKey('service-shop')));
    await _tapVisible(tester, 'service-continue');
    expect(_listed(tester), isEmpty);
    expect(
      find.text(
        'Aucun partenaire disponible dans cette catégorie pour le moment.',
      ),
      findsOneWidget,
    );
    await _tapVisible(tester, 'filter-all');
    expect(_listed(tester).single.id, 'restaurant');
  });

  testWidgets('back returns to service selection before returning home', (
    tester,
  ) async {
    var homeCalls = 0;
    await _pumpScreen(tester, _Repository(), onBack: () => homeCalls++);
    await tester.tap(find.byKey(const ValueKey('service-shop')));
    await _tapVisible(tester, 'service-continue');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Choisissez un service'), findsOneWidget);
    expect(find.text('✓ Sélectionné'), findsOneWidget);
    expect(homeCalls, 0);
    await tester.tap(find.byIcon(Icons.arrow_back));
    expect(homeCalls, 1);
  });

  for (final locale in ['fr', 'en']) {
    testWidgets(
      'service selection supports small screens, large text and dark mode ($locale)',
      (tester) async {
        await _pumpScreen(
          tester,
          _Repository(),
          width: 320,
          locale: locale,
          textScale: 2,
          dark: true,
        );
        await _tapVisible(tester, 'service-market');
        await _tapVisible(tester, 'service-continue');
        expect(_listed(tester).single.category, PartnerCategory.market);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('loading failure is shown and retry reloads the same service', (
    tester,
  ) async {
    final repository = _Repository()..fail = true;
    await _pumpScreen(tester, repository);
    await tester.tap(find.byKey(const ValueKey('service-shop')));
    await _tapVisible(tester, 'service-continue');
    expect(find.textContaining('Connexion indisponible'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();
    expect(_listed(tester).single.category, PartnerCategory.shop);
    expect(repository.calls, 2);
  });
}

List<Restaurant> _listed(WidgetTester tester) => tester
    .widget<partners.RestaurantsListView>(
      find.byType(partners.RestaurantsListView),
    )
    .restaurants;

Future<void> _tapVisible(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _Repository repository, {
  VoidCallback? onBack,
  double width = 390,
  String locale = 'fr',
  double textScale = 1,
  bool dark = false,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final bloc = RestaurantBloc(
    getRestaurants: GetRestaurants(repository),
    backgroundSync: false,
  );
  addTearDown(bloc.close);
  bloc.add(const RestaurantsLoadRequested());
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: dark ? ThemeData.dark() : ThemeData.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: BlocProvider.value(
        value: bloc,
        child: Scaffold(
          body: RestaurantsScreen(
            onBackHome: onBack ?? () {},
            isDarkMode: dark,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Restaurant _partner(String id, PartnerCategory category) => Restaurant(
  id: id,
  name: id == 'restaurant' ? 'Bistro' : 'Partenaire $id',
  address: id == 'shop' ? 'Grand Yoff' : 'Plateau',
  category: category,
  distanceKm: 0,
  updatedAt: DateTime(2026),
  isOpen: true,
  latitude: 0,
  longitude: 0,
);

class _Repository implements RestaurantRepository {
  var calls = 0;
  var fail = false;
  List<Restaurant> data = [
    _partner('restaurant', PartnerCategory.restaurant),
    _partner('shop', PartnerCategory.shop),
    _partner('supermarket', PartnerCategory.supermarket),
    _partner('market', PartnerCategory.market),
  ];

  @override
  Future<List<Restaurant>> getRestaurants() async {
    calls++;
    if (fail) throw const AppFailure('offline', kind: FailureKind.network);
    return data;
  }
}
