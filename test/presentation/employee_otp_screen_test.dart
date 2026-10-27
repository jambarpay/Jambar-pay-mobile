import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/screens/employee_otp_screen.dart';

void main() {
  testWidgets(
    'employee resend counts down, survives rebuilds and restarts after sending',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var now = DateTime.utc(2026, 10, 27);
      var deadline = now.add(const Duration(minutes: 2));
      var sends = 0;
      Widget screen({String otp = ''}) => MaterialApp(
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
          otp: otp,
          onSubmit: () {},
          onDigitTap: (_) {},
          onBackspace: () {},
          remainingResendDelay: () => deadline.difference(now),
          onResend: () async {
            sends++;
            deadline = now.add(const Duration(minutes: 2));
          },
        ),
      );
      await tester.pumpWidget(screen());
      expect(find.text('Renvoyer le code dans 02:00'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(
              find.byWidgetPredicate((widget) => widget is TextButton),
            )
            .onPressed,
        isNull,
      );

      now = now.add(const Duration(seconds: 60));
      await tester.pump(const Duration(seconds: 60));
      await tester.pumpWidget(screen(otp: '123'));
      expect(find.text('Renvoyer le code dans 01:00'), findsOneWidget);
      now = now.add(const Duration(seconds: 59, milliseconds: 999));
      await tester.pumpWidget(screen(otp: '1234'));
      expect(find.text('Renvoyer le code dans 00:01'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(
              find.byWidgetPredicate((widget) => widget is TextButton),
            )
            .onPressed,
        isNull,
      );
      now = now.add(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        tester
            .widget<TextButton>(
              find.byWidgetPredicate((widget) => widget is TextButton),
            )
            .onPressed,
        isNotNull,
      );
      expect(sends, 0);

      final resend = tester
          .widget<TextButton>(
            find.byWidgetPredicate((widget) => widget is TextButton),
          )
          .onPressed!;
      resend();
      resend();
      await tester.pump();
      expect(sends, 1);
      expect(find.text('Renvoyer le code dans 02:00'), findsOneWidget);
      expect(
        tester
            .widget<TextButton>(
              find.byWidgetPredicate((widget) => widget is TextButton),
            )
            .onPressed,
        isNull,
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      now = now.add(const Duration(minutes: 3));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(
        tester
            .widget<TextButton>(
              find.byWidgetPredicate((widget) => widget is TextButton),
            )
            .onPressed,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(minutes: 3));
      expect(tester.takeException(), isNull);
    },
  );

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
            onResend: () async {},
            remainingResendDelay: () => Duration.zero,
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
      expect(
        tester
            .widget<TextButton>(
              find.byWidgetPredicate((widget) => widget is TextButton),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.byIcon(Icons.arrow_back));
      expect(backs, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
