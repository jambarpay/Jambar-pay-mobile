import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jambar_pay_mobile/main.dart';
import 'package:jambar_pay_mobile/injection.dart' as di;
import 'package:jambar_pay_mobile/presentation/widgets/home_widgets.dart';
import 'package:jambar_pay_mobile/presentation/widgets/qr_widgets.dart';

void main() {
  setUpAll(() async {
    await di.init(useMockApi: true, useLocalAuth: true);
  });

  testWidgets('navigates from login to pin to home', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JambarPayApp());

    expect(find.text('Jambar Pay'), findsOneWidget);
    expect(find.text('Connexion'), findsOneWidget);

    for (final digit in ['7', '7', '1', '2', '3', '4', '5', '6', '7']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pump();
    }

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Code PIN'), findsOneWidget);

    await _tapDigits(tester, '1234', prefix: 'pin-keypad');
    await _pumpAsyncAuth(tester);

    expect(find.text('Transactions récentes'), findsOneWidget);
    expect(find.text('Abdoulaye Diallo'), findsOneWidget);
    expect(find.text('Le FOOD'), findsWidgets);

    await tester.tap(find.text('Voir tout'));
    await tester.pumpAndSettle();

    expect(find.text('6 transactions'), findsOneWidget);
    expect(find.text('Le FOOD'), findsWidgets);

    await tester.tap(find.text('Restaurants').last);
    await tester.pumpAndSettle();

    expect(find.text('Restaurants'), findsWidgets);
    expect(find.text('Rechercher un restaurant'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Modifier le code secret'), findsOneWidget);
    expect(find.text('Contacter le support'), findsOneWidget);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scanner').first);
    await tester.pumpAndSettle();

    expect(find.byType(ScannerPreview), findsOneWidget);
    expect(find.text('Retour'), findsOneWidget);
  });

  testWidgets('locks PIN entry after 5 failed attempts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JambarPayApp());

    for (final digit in ['7', '7', '1', '2', '3', '4', '5', '6', '7']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pump();
    }

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    for (var attempt = 0; attempt < 5; attempt++) {
      await _tapDigits(tester, '0000', prefix: 'pin-keypad');
      await _pumpAsyncAuth(tester);
    }

    expect(find.text('Code PIN'), findsOneWidget);
    expect(find.textContaining('2 minute'), findsWidgets);
    expect(find.textContaining('Nouvel essai dans'), findsWidgets);
  });

  testWidgets('uses a navigation rail on tablet layouts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1024, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const JambarPayApp());
    for (final digit in ['7', '7', '1', '2', '3', '4', '5', '6', '7']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pump();
    }
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await _tapDigits(tester, '1234', prefix: 'pin-keypad');
    await _pumpAsyncAuth(tester);

    expect(find.byType(HomeNavigationRail), findsOneWidget);
    expect(find.byType(HomeBottomNavigation), findsNothing);
  });
}

Future<void> _pumpAsyncAuth(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pumpAndSettle();
}

Future<void> _tapDigits(
  WidgetTester tester,
  String value, {
  String prefix = 'keypad',
}) async {
  for (final digit in value.split('')) {
    await tester.tap(find.byKey(ValueKey('$prefix-$digit')));
    await tester.pump();
  }
}
