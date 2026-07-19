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
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (otp != _currentPin) {
      throw Exception('Code secret incorrect');
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
    if (currentPin != _currentPin) {
      throw Exception('Code secret actuel incorrect.');
    }
    _currentPin = newPin;
  }

  Future<void> resetPin({required String phone, required String newPin}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentPin = newPin;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
