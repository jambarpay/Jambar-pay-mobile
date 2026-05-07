import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jambar_pay_mobile/main.dart';

void main() {
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

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Transaction Récentes'), findsOneWidget);
    expect(find.text('Abdoulaye Diallo'), findsOneWidget);
    expect(find.text('Le FOOD'), findsWidgets);

    await tester.tap(find.text('restaurants'));
    await tester.pumpAndSettle();

    expect(find.text('Restaurants'), findsOneWidget);
    expect(find.text('rechercher un restaurant'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    expect(find.text('Modifiez votre code secret'), findsOneWidget);
    expect(find.text('Contactez le support'), findsOneWidget);

    await tester.tap(find.text('Accueil'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scanner').first);
    await tester.pumpAndSettle();

    expect(find.text('Mon QR'), findsOneWidget);
    expect(find.text('Retour'), findsOneWidget);
  });
}
