import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/screens/employee_otp_screen.dart';

void main() {
  testWidgets(
    'checking OTP disables submission and editing but keeps the back action',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var submissions = 0;
      var edits = 0;
      var backs = 0;
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
          home: EmployeeOtpScreen(
            phoneNumber: '77 123 45 67',
            otp: '333333',
            isSubmitting: true,
            onSubmit: () => submissions++,
            onDigitTap: (_) => edits++,
            onBackspace: () => edits++,
            onBack: () => backs++,
          ),
        ),
      );
      expect(find.text('Code de vérification reçu'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.tap(find.byKey(const ValueKey('keypad-1')));
      expect(edits, 0);
      expect(submissions, 0);
      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backs, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
