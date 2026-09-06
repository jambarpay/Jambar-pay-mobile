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
      await _rememberUser(user);
      await _rememberPin(user, pin);
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
      await _rememberUser(user);
      await _rememberPin(user, pin);
      return user;
    } catch (e) {
      final offlineUser = await _tryOfflineLogin(phone: phone, pin: pin);
      if (offlineUser != null) return offlineUser;
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
    } catch (_) {
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
    } catch (_) {
      // Secure storage is a cache for the authenticated profile. A storage
      // issue must not make a valid authentication fail.
    }
  }

  Future<void> _rememberPin(User user, String? pin) async {
    if (pin == null) return;
    try {
      await _sessionStorage?.savePinVerifier(userId: user.id, pin: pin);
    } catch (_) {
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
    } catch (_) {
      return null;
    }
  }

  Future<User?> _readCachedUser() async {
    try {
      final profile = await _sessionStorage?.readUserProfile();
      return profile == null ? null : UserDto.fromJson(profile).toDomain();
    } catch (_) {
      return null;
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
      try {
        await _sessionStorage?.clearRememberedPhone();
        await _sessionStorage?.clear();
      } catch (_) {
        // The local auth state must still be cleared when storage is
        // temporarily unavailable.
      }
    }
  }
}
