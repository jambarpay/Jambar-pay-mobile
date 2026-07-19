import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/data/datasources/local/auth_local_datasource.dart';
import 'package:jambar_pay_mobile/domain/entities/user.dart';
import 'package:jambar_pay_mobile/domain/repositories/auth_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/change_pin.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/reset_pin.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';

void main() {
  group('PIN use cases', () {
    late _FakeAuthRepository repository;

    setUp(() => repository = _FakeAuthRepository());

    test('change PIN validates digits and delegates once', () async {
      final changePin = ChangePin(repository);

      await changePin(currentPin: '1234', newPin: '5678');

      expect(repository.changedPin, ('1234', '5678'));
      await expectLater(
        changePin(currentPin: 'abcd', newPin: '5678'),
        throwsException,
      );
    });

    test('reset PIN validates the phone and delegates once', () async {
      final resetPin = ResetPin(repository);
      const phone = PhoneNumber('771234567');

      await resetPin(phone: phone, newPin: '5678');

      expect(repository.reset, ('771234567', '5678'));
      await expectLater(
        resetPin(phone: const PhoneNumber('123'), newPin: '5678'),
        throwsException,
      );
    });
  });

  test('local authentication honors changed and reset PIN values', () async {
    final source = AuthLocalDataSource();

    await source.changePin(currentPin: '1234', newPin: '5678');
    await expectLater(
      source.verifyOtp(phone: '771234567', otp: '1234'),
      throwsException,
    );
    await expectLater(
      source.verifyOtp(phone: '771234567', otp: '5678'),
      completes,
    );

    await source.resetPin(phone: '771234567', newPin: '9012');
    await expectLater(
      source.verifyOtp(phone: '771234567', otp: '9012'),
      completes,
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  (String, String)? changedPin;
  (String, String)? reset;

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    changedPin = (currentPin, newPin);
  }

  @override
  Future<void> resetPin({
    required PhoneNumber phone,
    required String newPin,
  }) async {
    reset = (phone.digits, newPin);
  }

  @override
  Future<void> logout() async {}

  @override
  Future<String> refreshToken(String refreshToken) async => refreshToken;

  @override
  Future<void> sendOtp(PhoneNumber phone) async {}

  @override
  Future<User> verifyOtp({required PhoneNumber phone, required String otp}) {
    throw UnimplementedError();
  }
}
