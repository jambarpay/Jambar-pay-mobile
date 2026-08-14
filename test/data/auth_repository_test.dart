import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/core/storage/secure_session_storage.dart';
import 'package:jambar_pay_mobile/data/datasources/local/auth_local_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/repositories/auth_repository_impl.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';

void main() {
  const phone = PhoneNumber('771234567');

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
    expect(remote.changedPin, ('1234', '5678'));
    expect(remote.resetCall, ('771234567', '9876', '5678'));
    expect(remote.didLogout, isTrue);
  });

  test(
    'AuthRepositoryImpl contextualizes errors and keeps logout safe',
    () async {
      final remote = _RemoteAuthStub()..error = StateError('offline');
      final repository = AuthRepositoryImpl(
        remote,
        _LocalAuthStub(),
        useLocalAuth: false,
      );

      await expectLater(
        repository.sendOtp(phone),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Erreur réseau'),
          ),
        ),
      );
      await expectLater(
        repository.verifyOtp(phone: phone, otp: '1234'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Échec de la vérification'),
          ),
        ),
      );
      await expectLater(
        repository.refreshToken('refresh'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Impossible de rafraîchir'),
          ),
        ),
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
}

class _RemoteAuthStub extends AuthRemoteDataSource {
  _RemoteAuthStub() : super(ApiService(baseUrl: ''), SecureSessionStorage());

  String? sentPhone;
  (String, String)? changedPin;
  (String, String, String)? resetCall;
  bool didLogout = false;
  Object? error;

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
}
