import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/phone_number.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../models/dto/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final bool _useLocalAuth;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource, {
    bool useLocalAuth = false,
  }) : _useLocalAuth = useLocalAuth;

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
  }) async {
    try {
      final response = _useLocalAuth
          ? await _localDataSource.verifyOtp(
              phone: phone.digits,
              otp: otp,
            )
          : await _remoteDataSource.verifyOtp(
              phone: phone.digits,
              otp: otp,
            );
      final userDto = UserDto.fromJson(response);
      return userDto.toDomain();
    } catch (e) {
      throw Exception('Échec de la vérification: ${e.toString()}');
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
  Future<void> logout() async {
    try {
      if (_useLocalAuth) {
        await _localDataSource.logout();
      } else {
        await _remoteDataSource.logout();
      }
    } catch (_) {
      // Ignore errors on logout
    }
  }
}
