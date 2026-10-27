import '../../core/errors/failure_handling.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/phone_number.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/dto/user_dto.dart';
import '../../core/session/current_user_session.dart';
import '../../core/storage/secure_session_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final bool _useLocalAuth;
  final CurrentUserSession? _currentUserSession;
  final SecureSessionStorage? _sessionStorage;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource, {
    bool useLocalAuth = false,
    CurrentUserSession? currentUserSession,
    SecureSessionStorage? sessionStorage,
  }) : _useLocalAuth = useLocalAuth,
       _currentUserSession = currentUserSession,
       _sessionStorage = sessionStorage;

  @override
  Future<bool> startEmployeeOnboarding(PhoneNumber phone) async {
    if (_useLocalAuth) {
      return await _localDataSource.startEmployeeOnboarding(phone.digits);
    }
    return await _remoteDataSource.startEmployeeOnboarding(phone.digits);
  }

  @override
  Future<void> sendOtp(PhoneNumber phone) async {
    if (_useLocalAuth) {
      await _localDataSource.sendOtp(phone.digits);
    } else {
      await _remoteDataSource.sendOtp(phone.digits);
    }
  }

  @override
  Future<void> checkEmployeeOtp({
    required PhoneNumber phone,
    required String otp,
  }) {
    // No offline fallback, user/session persistence, or PIN creation on this path.
    return _useLocalAuth
        ? _localDataSource.checkEmployeeOtp(phone: phone.digits, otp: otp)
        : _remoteDataSource.checkEmployeeOtp(phone: phone.digits, otp: otp);
  }

  @override
  Future<User> verifyOtp({
    required PhoneNumber phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async {
    final response = _useLocalAuth
        ? await _localDataSource.verifyOtp(
            phone: phone.digits,
            otp: otp,
            pin: pin,
            pinConfirmation: pinConfirmation,
          )
        : await _remoteDataSource.verifyOtp(
            phone: phone.digits,
            otp: otp,
            pin: pin,
            pinConfirmation: pinConfirmation,
          );
    final userDto = UserDto.fromJson(response);
    final user = userDto.toDomain();
    _currentUserSession?.setUserId(user.id);
    await _rememberPhone(phone);
    await _rememberUser(user);
    await _rememberPin(user, pin);
    return user;
  }

  @override
  Future<User> loginWithPin({
    required PhoneNumber phone,
    required String pin,
  }) async {
    try {
      final response = _useLocalAuth
          ? await _localDataSource.loginWithPin(phone: phone.digits, pin: pin)
          : await _remoteDataSource.loginWithPin(phone: phone.digits, pin: pin);
      final user = UserDto.fromJson(response).toDomain();
      _currentUserSession?.setUserId(user.id);
      await _rememberPhone(phone);
      await _rememberUser(user);
      await _rememberPin(user, pin);
      return user;
    } catch (error) {
      if (classifyFailure(error).allowsOfflineLogin) {
        final offlineUser = await _tryOfflineLogin(phone: phone, pin: pin);
        if (offlineUser != null) return offlineUser;
      }
      rethrow;
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    return _useLocalAuth
        ? await _localDataSource.refreshToken(refreshToken)
        : await _remoteDataSource.refreshToken(refreshToken);
  }

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (_useLocalAuth) {
      await _localDataSource.changePin(currentPin: currentPin, newPin: newPin);
    } else {
      await _remoteDataSource.changePin(currentPin: currentPin, newPin: newPin);
    }
    final user = await _readCachedUser();
    if (user != null) await _rememberPin(user, newPin);
  }

  @override
  Future<void> resetPin({
    required PhoneNumber phone,
    required String verificationCode,
    required String newPin,
  }) async {
    if (_useLocalAuth) {
      await _localDataSource.resetPin(
        phone: phone.digits,
        verificationCode: verificationCode,
        newPin: newPin,
      );
    } else {
      await _remoteDataSource.resetPin(
        phone: phone.digits,
        verificationCode: verificationCode,
        newPin: newPin,
      );
    }
    await _rememberPhone(phone);
    final user = await _readCachedUser();
    if (user != null) await _rememberPin(user, newPin);
  }

  Future<void> _rememberPhone(PhoneNumber phone) async {
    try {
      await _sessionStorage?.saveRememberedPhone(phone.digits);
    } catch (error, stackTrace) {
      FailureDiagnostics.record(
        error,
        stackTrace,
        operation: 'auth_repository_impl',
      );
      // A storage failure must not turn a successful authentication into an
      // error. The phone is only a convenience for the next login.
    }
  }

  Future<void> _rememberUser(User user) async {
    try {
      await _sessionStorage?.saveUserProfile(
        id: user.id,
        name: user.name,
        phone: user.phone.value,
        avatarUrl: user.avatarUrl,
      );
    } catch (error, stackTrace) {
      FailureDiagnostics.record(
        error,
        stackTrace,
        operation: 'auth_repository_impl',
      );
      // Secure storage is a cache for the authenticated profile. A storage
      // issue must not make a valid authentication fail.
    }
  }

  Future<void> _rememberPin(User user, String? pin) async {
    if (pin == null) return;
    try {
      await _sessionStorage?.savePinVerifier(userId: user.id, pin: pin);
    } catch (error, stackTrace) {
      FailureDiagnostics.record(
        error,
        stackTrace,
        operation: 'auth_repository_impl',
      );
      // Local PIN verification is an offline convenience; a storage failure
      // must not invalidate an otherwise successful online login.
    }
  }

  Future<User?> _tryOfflineLogin({
    required PhoneNumber phone,
    required String pin,
  }) async {
    try {
      final user = await _readCachedUser();
      if (user == null || user.phone.digits != phone.digits) return null;
      final verified = await _sessionStorage?.verifyPin(
        userId: user.id,
        pin: pin,
      );
      if (verified != true) return null;
      _currentUserSession?.setUserId(user.id);
      return user;
    } catch (error, stackTrace) {
      FailureDiagnostics.record(
        error,
        stackTrace,
        operation: 'auth_repository_impl',
      );
      return null;
    }
  }

  Future<User?> _readCachedUser() async {
    try {
      final profile = await _sessionStorage?.readUserProfile();
      return profile == null ? null : UserDto.fromJson(profile).toDomain();
    } catch (error, stackTrace) {
      FailureDiagnostics.record(
        error,
        stackTrace,
        operation: 'auth_repository_impl',
      );
      return null;
    }
  }

  @override
  Future<void> deleteAccount() async {
    if (_useLocalAuth) {
      await _localDataSource.deleteAccount();
    } else {
      await _remoteDataSource.deleteAccount();
    }
    _currentUserSession?.clear();
    try {
      await _sessionStorage?.clearRememberedPhone();
      await _sessionStorage?.clear();
    } catch (error, stackTrace) {
      FailureDiagnostics.record(
        error,
        stackTrace,
        operation: 'auth_repository_impl',
      );
      // The account is already disabled remotely; local cleanup is best effort.
    }
  }

  @override
  Future<void> logout() async {
    try {
      if (_useLocalAuth) {
        await _localDataSource.logout();
      } else {
        await _remoteDataSource.logout();
      }
    } catch (error, stackTrace) {
      FailureDiagnostics.record(
        error,
        stackTrace,
        operation: 'auth_repository_impl',
      );
      // Ignore errors on logout
    } finally {
      _currentUserSession?.clear();
      try {
        await _sessionStorage?.clearRememberedPhone();
        await _sessionStorage?.clear();
      } catch (error, stackTrace) {
        FailureDiagnostics.record(
          error,
          stackTrace,
          operation: 'auth_repository_impl',
        );
        // The local auth state must still be cleared when storage is
        // temporarily unavailable.
      }
    }
  }
}
