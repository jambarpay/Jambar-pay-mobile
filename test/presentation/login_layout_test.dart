import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/screens/login_screen.dart';
import 'package:jambar_pay_mobile/presentation/widgets/auth_widgets.dart';

const _phone = '77 000 11 22';
const _limitMessage =
    'La limite de 2 envois OTP est atteinte pour cette activation.';

void main() {
  for (final (width, scale) in [
    (106.0, 1.0), // The reported Row had 84 px left after padding and borders.
    (160.0, 1.0),
    (276.0, 1.0),
    (346.0, 2.0),
  ]) {
    testWidgets(
      'phone remains readable at width $width and text scale $scale',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _app(
            scale: scale,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: const PhoneField(phoneNumber: _phone),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('+221'), findsOneWidget);
        expect(find.text(_phone), findsOneWidget);
        expect(find.bySemanticsLabel('Numéro de téléphone'), findsOneWidget);
        final field = tester.getRect(find.byType(PhoneField));
        expect(field.width, width);
        for (final text in ['+221', _phone]) {
          final bounds = tester.getRect(find.text(text));
          expect(bounds.left, greaterThanOrEqualTo(field.left));
          expect(bounds.right, lessThanOrEqualTo(field.right));
          expect(bounds.bottom, lessThanOrEqualTo(field.bottom));
        }
        semantics.dispose();
      },
    );
  }

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'login shows the server 429 on a narrow screen at scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 694);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          _app(
            scale: scale,
            child: LoginScreen(
              phoneNumber: _phone,
              errorText: _limitMessage,
              canContinue: false,
              onContinue: () {},
              onBackspace: () {},
              onDigitTap: (_) {},
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text(_limitMessage), findsOneWidget);
        expect(find.text(_phone), findsOneWidget);
        expect(find.byType(PhoneField), findsOneWidget);
      },
    );
  }
}

Widget _app({required Widget child, required double scale}) {
  return MaterialApp(
    locale: const Locale('fr'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: child,
  );
}
