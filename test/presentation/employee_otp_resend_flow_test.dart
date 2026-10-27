import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/core/network/base_url.dart';
import 'package:jambar_pay_mobile/core/storage/secure_session_storage.dart';
import 'package:jambar_pay_mobile/data/datasources/local/auth_local_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/repositories/auth_repository_impl.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/check_employee_otp.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/login_with_pin.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/logout.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/reset_pin.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/send_otp.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/start_employee_onboarding.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/verify_otp.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_state.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/localized_auth_message_provider.dart';
import 'package:jambar_pay_mobile/presentation/jambar_pay_app.dart';

void main() {
  testWidgets(
    'a tap after two minutes posts one resend and restarts the timer',
    (tester) async {
      final fixture = _ResendFixture();
      await fixture.open(tester);
      expect(find.text('Renvoyer le code dans 02:00'), findsOneWidget);
      expect(fixture.button(tester).onPressed, isNull);

      await fixture.advance(tester, const Duration(seconds: 119));
      expect(fixture.button(tester).onPressed, isNull);
      expect(fixture.requests, isEmpty);
      await fixture.advance(tester, const Duration(seconds: 1));
      expect(fixture.button(tester).onPressed, isNotNull);

      final resend = fixture.button(tester).onPressed!;
      resend();
      resend();
      await tester.pump();
      await tester.pump();
      expect(fixture.requests, hasLength(1));
      final request = fixture.requests.single;
      expect(request.method, 'POST');
      expect(request.url.path, BaseUrl.authRegisterResend());
      expect(jsonDecode(request.body), {'phoneNumber': '771234567'});
      expect(request.headers.containsKey('authorization'), isFalse);
      expect(fixture.button(tester).onPressed, isNull);

      fixture.response.complete(_jsonResponse({'success': true}));
      await tester.pumpAndSettle();
      expect(find.text('Renvoyer le code dans 02:00'), findsOneWidget);
      expect(fixture.button(tester).onPressed, isNull);
      expect((fixture.bloc.state as AuthOtpEntry).errorMessage, isNull);
      expect(fixture.requests, hasLength(1));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final response in [
    _jsonResponse({'success': false}),
    _jsonResponse({'message': 'missing acknowledgement'}),
    _jsonResponse({
      'success': false,
      'message':
          'La limite de 2 envois OTP est atteinte pour cette activation.',
    }, status: 429),
  ]) {
    testWidgets(
      'an unconfirmed resend (${response.statusCode}, ${response.body}) shows an error without restarting the timer',
      (tester) async {
        final fixture = _ResendFixture();
        await fixture.open(tester);
        await fixture.advance(tester, const Duration(minutes: 2));
        await tester.tap(find.text('Pas reçu ? Renvoyer le code'));
        await tester.pump();
        fixture.response.complete(response);
        await tester.pumpAndSettle();

        expect(fixture.requests, hasLength(1));
        expect((fixture.bloc.state as AuthOtpEntry).errorMessage, isNotEmpty);
        expect(
          fixture.bloc.remainingOtpResendDelay('771234567'),
          Duration.zero,
        );
        expect(fixture.button(tester).onPressed, isNotNull);
        expect(find.text('Renvoyer le code dans 02:00'), findsNothing);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}

http.Response _jsonResponse(Map<String, dynamic> body, {int status = 200}) =>
    http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

class _ResendFixture {
  DateTime now = DateTime.utc(2026, 10, 27);
  final requests = <http.Request>[];
  final response = Completer<http.Response>();
  late final AuthBloc bloc;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final api = ApiService(
      baseUrl: 'https://example.test',
      token: 'previous-session',
      client: MockClient((request) async {
        if (request.url.path == BaseUrl.authEmployeeOnboardingStart()) {
          return _jsonResponse({
            'success': true,
            'data': {'onboardingRequired': true},
          });
        }
        requests.add(request);
        return response.future;
      }),
    );
    addTearDown(api.dispose);
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSource(api, SecureSessionStorage()),
      AuthLocalDataSource(),
    );
    bloc = AuthBloc(
      sendOtp: SendOtp(repository),
      startEmployeeOnboarding: StartEmployeeOnboarding(repository),
      checkEmployeeOtp: CheckEmployeeOtp(repository),
      verifyOtp: VerifyOtp(repository),
      loginWithPin: LoginWithPin(repository),
      logout: Logout(repository),
      resetPin: ResetPin(repository),
      messages: LocalizedAuthMessageProvider(),
      initialPhone: '771234567',
      now: () => now,
    );
    addTearDown(bloc.close);
    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const JambarPayFlow(),
        ),
      ),
    );
    bloc.add(const PhoneNumberSubmitted());
    await tester.pumpAndSettle();
    expect(bloc.state, isA<AuthOtpEntry>());
  }

  Future<void> advance(WidgetTester tester, Duration duration) async {
    now = now.add(duration);
    await tester.pump(duration);
  }

  TextButton button(WidgetTester tester) => tester.widget<TextButton>(
    find.byWidgetPredicate((widget) => widget is TextButton),
  );
}
