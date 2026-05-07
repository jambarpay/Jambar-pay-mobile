import '../ApiService/ApiService.dart';
import '../di.dart' as di;
import '../ApiService/BaseUrl.dart';
import '../Entity/UserEntity.dart';

class UserService {
  final ApiService apiService;

  UserService({ApiService? apiService})
    : apiService = apiService ?? di.apiService;

  Future<UserEntity?> register(Map<String, dynamic> data) async {
    final response = await apiService.post(
      BaseUrl.utilisateursRegister(),
      data,
    );
    if (response is! Map) {
      return null;
    }

    return UserEntity.fromJson(Map<String, dynamic>.from(response));
  }

  Future<UserEntity?> login(Map<String, dynamic> data) async {
    final response = await apiService.post(BaseUrl.utilisateursLogin(), data);
    if (response is! Map) {
      return null;
    }

    final user = UserEntity.fromJson(Map<String, dynamic>.from(response));
    apiService.setToken(user.token);
    return user;
  }

  Future<dynamic> refresh(Map<String, dynamic> data) {
    return apiService.post(BaseUrl.utilisateursRefresh(), data);
  }

  Future<dynamic> verifyOtp(Map<String, dynamic> data) {
    return apiService.post(BaseUrl.utilisateursVerifyOtp(), data);
  }
}
