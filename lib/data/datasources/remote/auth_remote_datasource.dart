import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';
import '../../../core/storage/secure_session_storage.dart';

class AuthRemoteDataSource {
  final ApiService apiService;
  final SecureSessionStorage sessionStorage;

  AuthRemoteDataSource(this.apiService, this.sessionStorage);

  Future<void> sendOtp(String phone) async {
    await apiService.post(BaseUrl.utilisateursRegister(), {'phone': phone});
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await apiService.post(BaseUrl.utilisateursVerifyOtp(), {
      'phone': phone,
      'otp': otp,
    });
    if (response is! Map) {
      throw Exception('Invalid response format');
    }
    final responseMap = Map<String, dynamic>.from(response);
    final accessToken = responseMap['token']?.toString();
    if (accessToken != null && accessToken.isNotEmpty) {
      apiService.setToken(accessToken);
      await sessionStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: responseMap['refreshToken']?.toString(),
      );
    }

    // Extract 'user' object if it exists (API structure)
    if (responseMap.containsKey('user')) {
      return Map<String, dynamic>.from(responseMap['user']);
    }
    return responseMap;
  }

  Future<String> refreshToken(String refreshToken) async {
    final response = await apiService.post(BaseUrl.utilisateursRefresh(), {
      'refreshToken': refreshToken,
    });
    if (response is! Map) {
      throw Exception('Invalid response format');
    }
    final token = response['token']?.toString() ?? '';
    if (token.isNotEmpty) {
      apiService.setToken(token);
      await sessionStorage.saveTokens(
        accessToken: token,
        refreshToken: response['refreshToken']?.toString() ?? refreshToken,
      );
    }
    return token;
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    await apiService.post(BaseUrl.utilisateursChangePin(), {
      'currentPin': currentPin,
      'newPin': newPin,
    });
  }

  Future<void> resetPin({required String phone, required String newPin}) async {
    await apiService.post(BaseUrl.utilisateursResetPin(), {
      'phone': phone,
      'newPin': newPin,
    });
  }

  Future<void> logout() async {
    try {
      await apiService.post(BaseUrl.logout(), {});
    } finally {
      apiService.setToken(null);
      await sessionStorage.clear();
    }
  }
}
