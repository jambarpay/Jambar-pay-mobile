import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jambar_pay_mobile/main.dart';
import 'package:jambar_pay_mobile/injection.dart' as di;
import 'package:jambar_pay_mobile/presentation/widgets/home_widgets.dart';

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

    for (final digit in ['1', '2', '3', '4', '5', '6']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pumpAndSettle();
    }

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

    expect(find.text('Mon QR'), findsOneWidget);
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
      for (final digit in ['0', '0', '0', '0', '0', '0']) {
        await tester.tap(find.byKey(ValueKey('keypad-$digit')));
        await tester.pumpAndSettle();
      }
    }

    expect(find.text('Code PIN'), findsOneWidget);
    expect(find.textContaining('2 minute'), findsWidgets);
    expect(find.textContaining('Nouvel essai dans'), findsWidgets);
  });

  testWidgets('confirms a QR payment through the payment BLoC', (
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
    for (final digit in ['1', '2', '3', '4', '5', '6']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Scanner').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scanner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tester QR 1234'));
    await tester.pumpAndSettle();

    for (final digit in ['1', '0', '0', '0']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pump();
    }
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Entrez votre code PIN'), findsOneWidget);
    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pump();
    }
    await tester.tap(find.text('Payer'));
    await tester.pumpAndSettle();

    expect(find.text('Paiement réussi'), findsOneWidget);
    await tester.tap(find.text('Terminer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Paiement réussi chez'), findsOneWidget);
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
    for (final digit in ['1', '2', '3', '4', '5', '6']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pumpAndSettle();
    }

    expect(find.byType(HomeNavigationRail), findsOneWidget);
    expect(find.byType(HomeBottomNavigation), findsNothing);
  });
}
