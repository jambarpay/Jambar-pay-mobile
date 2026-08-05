class AuthLocalDataSource {
  static const String _testUserId = 'test-user-123';
  static const String _testUserName = 'Abdoulaye Diallo';
  String _currentPin = '1234';

  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (otp != '123456' && otp != _currentPin) {
      throw Exception('Code secret incorrect');
    }
    if (pin != null &&
        (!RegExp(r'^\d{4}$').hasMatch(pin) || pin != pinConfirmation)) {
      throw Exception('Le code PIN doit contenir 4 chiffres et être confirmé');
    }
    if (pin != null) {
      _currentPin = pin;
    }

    return {
      '_id': _testUserId,
      'name': _testUserName,
      'phone': phone,
      'avatarUrl': null,
    };
  }

  Future<String> refreshToken(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'mock-refresh-token-${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!RegExp(r'^\d{4}$').hasMatch(currentPin) ||
        !RegExp(r'^\d{4}$').hasMatch(newPin)) {
      throw Exception('Le code PIN doit contenir 4 chiffres.');
    }
    if (currentPin != _currentPin) {
      throw Exception('Code secret actuel incorrect.');
    }
    _currentPin = newPin;
  }

  Future<void> resetPin({
    required String phone,
    required String verificationCode,
    required String newPin,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!RegExp(r'^\d{4}$').hasMatch(newPin)) {
      throw Exception('Le code PIN doit contenir 4 chiffres.');
    }
    if (verificationCode != _currentPin) {
      throw Exception('Code de vérification incorrect.');
    }
    _currentPin = newPin;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
