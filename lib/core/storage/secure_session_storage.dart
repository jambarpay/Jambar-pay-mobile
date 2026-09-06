import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CachedEmployeeQr {
  const CachedEmployeeQr({
    required this.userId,
    required this.content,
    this.expiresAt,
  });

  final String userId;
  final String content;
  final DateTime? expiresAt;

  bool get isUsable =>
      content.isNotEmpty &&
      (expiresAt == null || expiresAt!.isAfter(DateTime.now()));

  bool get isExpired => expiresAt != null && !isUsable;
}

class SecureSessionStorage {
  SecureSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _rememberedPhoneKey = 'auth.remembered_phone';
  static const _pinVerifierKey = 'auth.pin_verifier';
  static const _userProfileKey = 'auth.user_profile';
  static const _employeeQrKey = 'auth.employee_qr';
  static const _walletCacheKey = 'cache.wallet';
  static const _transactionsCacheKey = 'cache.transactions';
  static const _restaurantsCacheKey = 'cache.restaurants';

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

  Future<void> savePinVerifier({
    required String userId,
    required String pin,
  }) async {
    if (userId.trim().isEmpty || !RegExp(r'^\d{4}$').hasMatch(pin)) return;

    await _storage.write(key: _pinVerifierKey, value: _pinDigest(userId, pin));
  }

  Future<bool> verifyPin({required String userId, required String pin}) async {
    final storedVerifier = await _storage.read(key: _pinVerifierKey);
    if (storedVerifier == null || storedVerifier.isEmpty) return false;
    return storedVerifier == _pinDigest(userId, pin);
  }

  String _pinDigest(String userId, String pin) =>
      sha256.convert(utf8.encode('${userId.trim()}:$pin')).toString();

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

  /// Stores non-secret profile data in the platform secure storage.
  ///
  /// `FlutterSecureStorage` uses Keychain on iOS and Keystore-backed
  /// encrypted storage on Android. Only a PIN verifier is persisted; the PIN
  /// itself is never stored.
  Future<void> saveUserProfile({
    required String id,
    required String name,
    required String phone,
    String? avatarUrl,
  }) async {
    await _storage.write(
      key: _userProfileKey,
      value: jsonEncode({
        'id': id,
        'name': name,
        'phone': phone,
        'avatarUrl': avatarUrl,
      }),
    );
  }

  Future<Map<String, dynamic>?> readUserProfile() async {
    final encoded = await _storage.read(key: _userProfileKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return null;
      final profile = Map<String, dynamic>.from(decoded);
      if ((profile['id']?.toString() ?? '').trim().isEmpty) return null;
      return profile;
    } on FormatException {
      return null;
    }
  }

  Future<void> saveEmployeeQr({
    required String userId,
    required String content,
    DateTime? expiresAt,
  }) async {
    final normalizedContent = content.trim();
    if (userId.trim().isEmpty || normalizedContent.isEmpty) {
      await clearEmployeeQr();
      return;
    }

    await _storage.write(
      key: _employeeQrKey,
      value: jsonEncode({
        'userId': userId.trim(),
        'content': normalizedContent,
        'expiresAt': expiresAt?.toIso8601String(),
      }),
    );
  }

  Future<CachedEmployeeQr?> readEmployeeQr({String? userId}) async {
    final encoded = await _storage.read(key: _employeeQrKey);
    if (encoded == null || encoded.isEmpty) return null;

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map) return null;
      final data = Map<String, dynamic>.from(decoded);
      final cachedUserId = data['userId']?.toString() ?? '';
      final content = data['content']?.toString() ?? '';
      if (cachedUserId.isEmpty || content.isEmpty) return null;
      if (userId != null && cachedUserId != userId) return null;

      final rawExpiry = data['expiresAt']?.toString();
      return CachedEmployeeQr(
        userId: cachedUserId,
        content: content,
        expiresAt: rawExpiry == null || rawExpiry.isEmpty
            ? null
            : DateTime.tryParse(rawExpiry),
      );
    } on FormatException {
      return null;
    }
  }

  Future<void> clearEmployeeQr() => _storage.delete(key: _employeeQrKey);

  Future<void> saveWalletCache(Map<String, dynamic> wallet) async {
    await _writeJson(_walletCacheKey, wallet);
  }

  Future<Map<String, dynamic>?> readWalletCache() async {
    final decoded = await _readJson(_walletCacheKey);
    return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
  }

  Future<void> saveTransactionsCache(List<dynamic> transactions) async {
    await _writeJson(_transactionsCacheKey, transactions);
  }

  Future<List<dynamic>?> readTransactionsCache() async {
    final decoded = await _readJson(_transactionsCacheKey);
    return decoded is List ? List<dynamic>.from(decoded) : null;
  }

  Future<void> saveRestaurantsCache(List<dynamic> restaurants) async {
    await _writeJson(_restaurantsCacheKey, restaurants);
  }

  Future<List<dynamic>?> readRestaurantsCache() async {
    final decoded = await _readJson(_restaurantsCacheKey);
    return decoded is List ? List<dynamic>.from(decoded) : null;
  }

  Future<void> _writeJson(String key, Object value) async {
    await _storage.write(key: key, value: jsonEncode(value));
  }

  Future<dynamic> _readJson(String key) async {
    final encoded = await _storage.read(key: key);
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return jsonDecode(encoded);
    } on FormatException {
      return null;
    }
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userProfileKey),
      _storage.delete(key: _pinVerifierKey),
      _storage.delete(key: _employeeQrKey),
      _storage.delete(key: _walletCacheKey),
      _storage.delete(key: _transactionsCacheKey),
      _storage.delete(key: _restaurantsCacheKey),
    ]);
  }
}
