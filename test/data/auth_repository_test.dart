import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/core/storage/secure_session_storage.dart';
import 'package:jambar_pay_mobile/data/datasources/local/auth_local_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/repositories/auth_repository_impl.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';

void main() {
  const phone = PhoneNumber('771234567');

  test(
    'preserves the backend OTP send-limit error for start and resend',
    () async {
      const error = ApiException(
        'La limite de 2 envois OTP est atteinte pour cette activation.',
        statusCode: 429,
      );
      final remote = _RemoteAuthStub()..error = error;
      final repository = AuthRepositoryImpl(remote, _LocalAuthStub());

      await expectLater(
        repository.startEmployeeOnboarding(phone),
        throwsA(same(error)),
      );
      await expectLater(repository.sendOtp(phone), throwsA(same(error)));
    },
  );

  test('AuthRepositoryImpl delegates the complete local contract', () async {
    final local = _LocalAuthStub();
    final storage = _RecordingSessionStorage();
    final repository = AuthRepositoryImpl(
      _RemoteAuthStub(),
      local,
      useLocalAuth: true,
      sessionStorage: storage,
    );

    await repository.sendOtp(phone);
    await repository.checkEmployeeOtp(phone: phone, otp: '123456');
    final user = await repository.verifyOtp(phone: phone, otp: '1234');
    expect(user.id, 'local-user');
    expect(
      (await repository.loginWithPin(phone: phone, pin: '1234')).id,
      'local-user',
    );
    expect(await repository.refreshToken('refresh'), 'local-refresh');
    await repository.changePin(currentPin: '1234', newPin: '5678');
    await repository.resetPin(
      phone: phone,
      verificationCode: '9876',
      newPin: '5678',
    );
    await repository.logout();

    expect(local.sentPhone, phone.digits);
    expect(local.checkedOtp, (phone.digits, '123456'));
    expect(local.changedPin, ('1234', '5678'));
    expect(local.resetCall, ('771234567', '9876', '5678'));
    expect(local.didLogout, isTrue);
    expect(storage.didClearRememberedPhone, isTrue);
  });

  test('AuthRepositoryImpl delegates the complete remote contract', () async {
    final remote = _RemoteAuthStub();
    final repository = AuthRepositoryImpl(
      remote,
      _LocalAuthStub(),
      useLocalAuth: false,
    );

    await repository.sendOtp(phone);
    await repository.checkEmployeeOtp(phone: phone, otp: '123456');
    final user = await repository.verifyOtp(phone: phone, otp: '1234');
    expect(user.id, 'remote-user');
    expect(
      (await repository.loginWithPin(phone: phone, pin: '1234')).id,
      'remote-user',
    );
    expect(await repository.refreshToken('refresh'), 'remote-refresh');
    await repository.changePin(currentPin: '1234', newPin: '5678');
    await repository.resetPin(
      phone: phone,
      verificationCode: '9876',
      newPin: '5678',
    );
    await repository.logout();

    expect(remote.sentPhone, phone.digits);
    expect(remote.checkedOtp, (phone.digits, '123456'));
    expect(remote.changedPin, ('1234', '5678'));
    expect(remote.resetCall, ('771234567', '9876', '5678'));
    expect(remote.didLogout, isTrue);
  });

  test(
    'a remote OTP rejection never falls back to local authentication',
    () async {
      final remote = _RemoteAuthStub()
        ..error = const ApiException('Invalid OTP', statusCode: 401);
      final local = _LocalAuthStub();
      final repository = AuthRepositoryImpl(remote, local, useLocalAuth: false);

      await expectLater(
        repository.checkEmployeeOtp(phone: phone, otp: '123456'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'status',
            401,
          ),
        ),
      );
      expect(local.checkedOtp, isNull);
    },
  );

  test(
    'AuthRepositoryImpl preserves original errors and keeps logout safe',
    () async {
      final remote = _RemoteAuthStub()..error = StateError('offline');
      final repository = AuthRepositoryImpl(
        remote,
        _LocalAuthStub(),
        useLocalAuth: false,
      );

      await expectLater(repository.sendOtp(phone), throwsA(same(remote.error)));
      await expectLater(
        repository.verifyOtp(phone: phone, otp: '1234'),
        throwsA(same(remote.error)),
      );
      await expectLater(
        repository.refreshToken('refresh'),
        throwsA(same(remote.error)),
      );
      await expectLater(repository.logout(), completes);
    },
  );
}

class _RecordingSessionStorage extends SecureSessionStorage {
  bool didClearRememberedPhone = false;

  @override
  Future<void> clearRememberedPhone() async {
    didClearRememberedPhone = true;
  }
}

class _LocalAuthStub extends AuthLocalDataSource {
  (String, String)? checkedOtp;

  @override
  Future<void> checkEmployeeOtp({
    required String phone,
    required String otp,
  }) async {
    checkedOtp = (phone, otp);
  }

  String? sentPhone;
  (String, String)? changedPin;
  (String, String, String)? resetCall;
  bool didLogout = false;

  @override
  Future<void> sendOtp(String phone) async => sentPhone = phone;

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async => {'id': 'local-user', 'name': 'Local', 'phone': phone};

  @override
  Future<Map<String, dynamic>> loginWithPin({
    required String phone,
    required String pin,
  }) async => {'id': 'local-user', 'name': 'Local', 'phone': phone};

  @override
  Future<String> refreshToken(String refreshToken) async => 'local-refresh';

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async => changedPin = (currentPin, newPin);

  @override
  Future<void> resetPin({
    required String phone,
    required String verificationCode,
    required String newPin,
  }) async => resetCall = (phone, verificationCode, newPin);

  @override
  Future<void> logout() async => didLogout = true;

  @override
  Future<void> deleteAccount() async {}
}

class _RemoteAuthStub extends AuthRemoteDataSource {
  _RemoteAuthStub() : super(ApiService(baseUrl: ''), SecureSessionStorage());

  String? sentPhone;
  (String, String)? changedPin;
  (String, String, String)? resetCall;
  bool didLogout = false;
  Object? error;
  (String, String)? checkedOtp;

  @override
  Future<bool> startEmployeeOnboarding(String phone) async {
    _throwIfNeeded();
    return true;
  }

  @override
  Future<void> checkEmployeeOtp({
    required String phone,
    required String otp,
  }) async {
    _throwIfNeeded();
    checkedOtp = (phone, otp);
  }

  void _throwIfNeeded() {
    if (error case final value?) throw value;
  }

  @override
  Future<void> sendOtp(
    String phone, {
    String firstName = 'Utilisateur',
    String lastName = 'Jambaar Pay',
  }) async {
    _throwIfNeeded();
    sentPhone = phone;
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async {
    _throwIfNeeded();
    return {'id': 'remote-user', 'name': 'Remote', 'phone': phone};
  }

  @override
  Future<Map<String, dynamic>> loginWithPin({
    required String phone,
    required String pin,
  }) async {
    _throwIfNeeded();
    return {'id': 'remote-user', 'name': 'Remote', 'phone': phone};
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    _throwIfNeeded();
    return 'remote-refresh';
  }

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    _throwIfNeeded();
    changedPin = (currentPin, newPin);
  }

  @override
  Future<void> resetPin({
    required String phone,
    required String verificationCode,
    required String newPin,
  }) async {
    _throwIfNeeded();
    resetCall = (phone, verificationCode, newPin);
  }

  @override
  Future<void> logout() async {
    _throwIfNeeded();
    didLogout = true;
  }

  @override
  Future<void> deleteAccount() async {
    _throwIfNeeded();
  }
}
