import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/domain/entities/user.dart';
import 'package:jambar_pay_mobile/domain/repositories/auth_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/logout.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/login_with_pin.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/reset_pin.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/send_otp.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/verify_otp.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/localized_auth_message_provider.dart';
import 'package:jambar_pay_mobile/presentation/screens/secret_code_screen.dart';

void main() {
  testWidgets('reset flow submits verification code before the new PIN', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = _RecordingAuthRepository();
    final authBloc = AuthBloc(
      sendOtp: SendOtp(repository),
      verifyOtp: VerifyOtp(repository),
      loginWithPin: LoginWithPin(repository),
      logout: Logout(repository),
      resetPin: ResetPin(repository),
      messages: LocalizedAuthMessageProvider(),
    );
    addTearDown(authBloc.close);

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
        home: BlocProvider.value(
          value: authBloc,
          child: const SecretCodeScreen(
            mode: SecretCodeFlowMode.reset,
            phoneNumber: '77 123 45 67',
          ),
        ),
      ),
    );

    expect(find.text('Code de vérification'), findsWidgets);
    for (final digit in '12345656785678'.split('')) {
      await tester.tap(find.byKey(ValueKey('keypad-$digit')));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(repository.resetCall, ('771234567', '123456', '5678'));
  });
}

class _RecordingAuthRepository implements AuthRepository {
  (String, String, String)? resetCall;

  @override
  Future<void> resetPin({
    required PhoneNumber phone,
    required String verificationCode,
    required String newPin,
  }) async {
    resetCall = (phone.digits, verificationCode, newPin);
  }

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<String> refreshToken(String refreshToken) async => refreshToken;

  @override
  Future<void> sendOtp(PhoneNumber phone) async {}

  @override
  Future<User> loginWithPin({
    required PhoneNumber phone,
    required String pin,
  }) async => User(id: 'user', name: 'Test', phone: phone);

  @override
  Future<User> verifyOtp({
    required PhoneNumber phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async => User(id: 'user', name: 'Test', phone: phone);
}
