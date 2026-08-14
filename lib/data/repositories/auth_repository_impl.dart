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
  Future<void> sendOtp(PhoneNumber phone) async {
    try {
      if (_useLocalAuth) {
        await _localDataSource.sendOtp(phone.digits);
      } else {
        await _remoteDataSource.sendOtp(phone.digits);
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  @override
  Future<User> verifyOtp({
    required PhoneNumber phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async {
    try {
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
      return user;
    } catch (e) {
      throw Exception('Échec de la vérification: ${e.toString()}');
    }
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
      return user;
    } catch (e) {
      throw Exception('Échec de la connexion: ${e.toString()}');
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    try {
      return _useLocalAuth
          ? await _localDataSource.refreshToken(refreshToken)
          : await _remoteDataSource.refreshToken(refreshToken);
    } catch (e) {
      throw Exception('Impossible de rafraîchir le token: ${e.toString()}');
    }
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
  }

  Future<void> _rememberPhone(PhoneNumber phone) async {
    try {
      await _sessionStorage?.saveRememberedPhone(phone.digits);
    } catch (_) {
      // A storage failure must not turn a successful authentication into an
      // error. The phone is only a convenience for the next login.
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
    } catch (_) {
      // Ignore errors on logout
    } finally {
      _currentUserSession?.clear();
    }
  }
}
