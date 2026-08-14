import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureSessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _rememberedPhoneKey = 'auth.remembered_phone';

  final FlutterSecureStorage _storage;

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> readRememberedPhone() =>
      _storage.read(key: _rememberedPhoneKey);

  Future<void> saveRememberedPhone(String phone) async {
    final normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (normalizedPhone.isEmpty) {
      await _storage.delete(key: _rememberedPhoneKey);
      return;
    }

    await _storage.write(key: _rememberedPhoneKey, value: normalizedPhone);
  }

  Future<void> clearRememberedPhone() =>
      _storage.delete(key: _rememberedPhoneKey);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } else {
      await _storage.delete(key: _refreshTokenKey);
    }
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
