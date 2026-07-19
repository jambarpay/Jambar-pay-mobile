import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/injection.dart' as di;
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/main.dart';
import 'package:jambar_pay_mobile/presentation/screens/pin_screen.dart';

void main() {
  setUpAll(() async {
    await di.init(useMockApi: true, useLocalAuth: true);
  });

  testWidgets('login keyboard exposes meaningful screen-reader semantics', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(const JambarPayApp());
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Effacer le dernier chiffre'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Numéro de téléphone',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('0 chiffre(s) saisi(s) sur 4'), findsNothing);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('PIN progress is announced without exposing the PIN value', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: PinScreen(
          pin: '1',
          phoneNumber: '771234567',
          onBack: () {},
          onBackspace: () {},
          onDigitTap: (_) {},
        ),
      ),
    );
    await tester.pump();

    expect(
      find.bySemanticsLabel('1 chiffre(s) saisi(s) sur 4'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('1234'), findsNothing);
    semantics.dispose();
  });
}
