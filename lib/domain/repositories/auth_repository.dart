import '../entities/user.dart';
import '../value_objects/phone_number.dart';

abstract class AuthRepository {
  Future<void> sendOtp(PhoneNumber phone);

  /// Returns true when this phone belongs to a pending employee and an OTP was sent.
  /// The default keeps lightweight test/fallback repositories compatible.
  Future<bool> startEmployeeOnboarding(PhoneNumber phone) async => false;

  Future<User> verifyOtp({
    required PhoneNumber phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  });

  Future<User> loginWithPin({required PhoneNumber phone, required String pin});

  Future<String> refreshToken(String refreshToken);
  Future<void> changePin({required String currentPin, required String newPin});
  Future<void> resetPin({
    required PhoneNumber phone,
    required String verificationCode,
    required String newPin,
  });
  Future<void> logout();
  Future<void> deleteAccount();
}
