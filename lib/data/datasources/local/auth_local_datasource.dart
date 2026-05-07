class AuthLocalDataSource {
  static const String _testOtp = '1234';
  static const String _testUserId = 'test-user-123';
  static const String _testUserName = 'Test User';

  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print('📱 [LOCAL] OTP envoyé à $phone (test mode)');
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    print('🧪 [AuthLocalDatasource] Checking OTP:');
    print('   Expected: "$_testOtp" (length=${_testOtp.length})');
    print('   Received: "$otp" (length=${otp.length})');
    print('   Match: ${otp == _testOtp}');

    if (otp != _testOtp) {
      print('❌ [AuthLocalDatasource] OTP incorrect!');
      throw Exception('Code secret incorrect');
    }

    print('✅ [LOCAL] Authentification réussie pour $phone');

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

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    print('👋 [LOCAL] Déconnexion simulée');
  }
}
