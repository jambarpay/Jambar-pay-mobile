import '../../../ApiService/ApiService.dart';
import '../../../ApiService/BaseUrl.dart';

class AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSource(this.apiService);

  Future<void> sendOtp(String phone) async {
    await apiService.post(
      BaseUrl.utilisateursRegister(),
      {'phone': phone},
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await apiService.post(
      BaseUrl.utilisateursVerifyOtp(),
      {'phone': phone, 'otp': otp},
    );
    if (response is! Map) {
      throw Exception('Invalid response format');
    }
    return Map<String, dynamic>.from(response);
  }

  Future<String> refreshToken(String refreshToken) async {
    final response = await apiService.post(
      BaseUrl.utilisateursRefresh(),
      {'refreshToken': refreshToken},
    );
    if (response is! Map) {
      throw Exception('Invalid response format');
    }
    return response['token']?.toString() ?? '';
  }

  Future<void> logout() async {
    await apiService.post(BaseUrl.logout(), {});
  }
}
