import '../entities/user.dart';
import '../value_objects/phone_number.dart';

abstract class AuthRepository {
  Future<void> sendOtp(PhoneNumber phone);

  Future<User> verifyOtp({
    required PhoneNumber phone,
    required String otp,
  });
  
  Future<String> refreshToken(String refreshToken);
  Future<void> logout();
}
