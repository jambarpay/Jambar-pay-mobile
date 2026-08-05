import '../entities/user.dart';
import '../value_objects/phone_number.dart';

abstract class AuthRepository {
  Future<void> sendOtp(PhoneNumber phone);

  Future<User> verifyOtp({
    required PhoneNumber phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  });

  Future<String> refreshToken(String refreshToken);
  Future<void> changePin({required String currentPin, required String newPin});
  Future<void> resetPin({
    required PhoneNumber phone,
    required String verificationCode,
    required String newPin,
  });
  Future<void> logout();
}
