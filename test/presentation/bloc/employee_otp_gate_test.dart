import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/domain/entities/user.dart';
import 'package:jambar_pay_mobile/domain/repositories/auth_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/check_employee_otp.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/login_with_pin.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/logout.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/reset_pin.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/send_otp.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/start_employee_onboarding.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/verify_otp.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/auth_state.dart';
import 'package:jambar_pay_mobile/presentation/bloc/auth/localized_auth_message_provider.dart';

void main() {
  late _GateRepository repository;
  late AuthBloc bloc;
  late List<AuthState> states;
  late StreamSubscription<AuthState> subscription;

  setUp(() async {
    repository = _GateRepository();
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
    );
    states = [];
    subscription = bloc.stream.listen(states.add);
    final entry = bloc.stream.firstWhere((state) => state is AuthOtpEntry);
    bloc.add(const PhoneNumberSubmitted());
    await entry;
  });

  tearDown(() async {
    await subscription.cancel();
    await bloc.close();
  });

  Future<void> enterCode(String code) async {
    final entered = bloc.stream.firstWhere(
      (state) => state is AuthOtpEntry && state.otp == code,
    );
    for (final digit in code.split('')) {
      bloc.add(OtpChanged(digit));
    }
    await entered;
  }

  test('six digits alone never authorize PIN setup', () async {
    await enterCode('333333');
    expect(bloc.state, isA<AuthOtpEntry>());
    expect(repository.checkCalls, 0);
    expect(states.whereType<AuthPinSetupEntry>(), isEmpty);
  });

  for (final status in [401, 410, 429, 503]) {
    test(
      'server rejection $status keeps the employee on the OTP screen',
      () async {
        repository.checkError = ApiException('Rejected', statusCode: status);
        await enterCode('333333');
        final rejected = bloc.stream.firstWhere(
          (state) => state is AuthOtpEntry && state.errorMessage != null,
        );
        bloc.add(const OtpSubmitted());
        final state = await rejected as AuthOtpEntry;

        expect(state.isSubmitting, isFalse);
        expect(state.errorMessage, isNotEmpty);
        expect(repository.checked, ('771234567', '333333'));
        expect(states.whereType<AuthPinSetupEntry>(), isEmpty);
        expect(states.whereType<AuthPinSetupConfirmation>(), isEmpty);
        expect(states.whereType<AuthAuthenticated>(), isEmpty);
        expect(repository.finalCalls, 0);
      },
    );
  }

  test('network errors do not open PIN setup', () async {
    repository.checkError = TimeoutException('offline');
    await enterCode('333333');
    final rejected = bloc.stream.firstWhere(
      (state) => state is AuthOtpEntry && state.errorMessage != null,
    );
    bloc.add(const OtpSubmitted());
    await rejected;
    expect(states.whereType<AuthPinSetupEntry>(), isEmpty);
    expect(repository.finalCalls, 0);
  });

  test(
    'waits for server success and blocks double taps or premature PIN events',
    () async {
      repository.pendingCheck = Completer<void>();
      await enterCode('333333');
      final checking = bloc.stream.firstWhere(
        (state) => state is AuthOtpEntry && state.isSubmitting,
      );
      bloc.add(const OtpSubmitted());
      await checking;
      bloc.add(const OtpSubmitted());
      bloc.add(const OtpChanged('9'));
      bloc.add(const PinChanged('2468'));
      bloc.add(const PinSubmitted());
      await Future<void>.delayed(Duration.zero);
      expect(repository.checkCalls, 1);
      expect(repository.loginCalls, 0);
      expect(bloc.state, isA<AuthOtpEntry>());
      expect(states.whereType<AuthPinSetupEntry>(), isEmpty);

      final allowed = bloc.stream.firstWhere(
        (state) => state is AuthPinSetupEntry,
      );
      repository.pendingCheck!.complete();
      await allowed;
      expect(repository.finalCalls, 0);
      expect(states.whereType<AuthAuthenticated>(), isEmpty);
    },
  );

  test(
    'late successful responses cannot reopen PIN setup after going back',
    () async {
      repository.pendingCheck = Completer<void>();
      await enterCode('333333');
      final checking = bloc.stream.firstWhere(
        (state) => state is AuthOtpEntry && state.isSubmitting,
      );
      bloc.add(const OtpSubmitted());
      await checking;
      final back = bloc.stream.firstWhere((state) => state is AuthPhoneInitial);
      bloc.add(const BackToPhoneRequested());
      await back;
      repository.pendingCheck!.complete();
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state, isA<AuthPhoneInitial>());
      expect(states.whereType<AuthPinSetupEntry>(), isEmpty);
    },
  );

  test(
    'expiration during PIN entry returns to OTP instead of activating',
    () async {
      repository.finalError = const ApiException(
        'OTP has expired',
        statusCode: 410,
      );
      await enterCode('333333');
      final allowed = bloc.stream.firstWhere(
        (state) => state is AuthPinSetupEntry,
      );
      bloc.add(const OtpSubmitted());
      await allowed;
      final confirming = bloc.stream.firstWhere(
        (state) => state is AuthPinSetupConfirmation,
      );
      bloc.add(const PinChanged('2468'));
      await confirming;
      final rejected = bloc.stream.firstWhere(
        (state) => state is AuthOtpEntry && state.errorMessage != null,
      );
      bloc.add(const PinChanged('2468'));
      await rejected;
      expect(repository.finalCalls, 1);
      expect(bloc.state, isA<AuthOtpEntry>());
      expect(states.whereType<AuthAuthenticated>(), isEmpty);
    },
  );

  test(
    'valid OTP and confirmed PIN complete the normal activation flow',
    () async {
      await enterCode('333333');
      final allowed = bloc.stream.firstWhere(
        (state) => state is AuthPinSetupEntry,
      );
      bloc.add(const OtpSubmitted());
      await allowed;
      final confirming = bloc.stream.firstWhere(
        (state) => state is AuthPinSetupConfirmation,
      );
      bloc.add(const PinChanged('2468'));
      await confirming;
      final activated = bloc.stream.firstWhere(
        (state) => state is AuthAuthenticated,
      );
      bloc.add(const PinChanged('2468'));
      await activated;
      expect(repository.finalCall, ('771234567', '333333', '2468', '2468'));
      expect(repository.checkCalls, 1);
      expect(repository.finalCalls, 1);
    },
  );
}

class _GateRepository implements AuthRepository {
  Object? checkError;
  Object? finalError;
  Completer<void>? pendingCheck;
  int checkCalls = 0;
  int finalCalls = 0;
  int loginCalls = 0;
  (String, String)? checked;
  (String, String, String?, String?)? finalCall;

  @override
  Future<bool> startEmployeeOnboarding(PhoneNumber phone) async => true;

  @override
  Future<void> checkEmployeeOtp({
    required PhoneNumber phone,
    required String otp,
  }) async {
    checkCalls++;
    checked = (phone.digits, otp);
    if (checkError case final error?) throw error;
    await pendingCheck?.future;
  }

  @override
  Future<User> verifyOtp({
    required PhoneNumber phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async {
    finalCalls++;
    finalCall = (phone.digits, otp, pin, pinConfirmation);
    if (finalError case final error?) throw error;
    return User(id: 'employee', name: 'Test', phone: phone);
  }

  @override
  Future<User> loginWithPin({
    required PhoneNumber phone,
    required String pin,
  }) async {
    loginCalls++;
    return User(id: 'employee', name: 'Test', phone: phone);
  }

  @override
  Future<void> sendOtp(PhoneNumber phone) async {}
  @override
  Future<void> logout() async {}
  @override
  Future<void> deleteAccount() async {}
  @override
  Future<String> refreshToken(String token) async => token;
  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {}
  @override
  Future<void> resetPin({
    required PhoneNumber phone,
    required String verificationCode,
    required String newPin,
  }) async {}
}
