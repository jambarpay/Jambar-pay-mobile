import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';
import '../../value_objects/phone_number.dart';

class VerifyOtp {
  final AuthRepository _authRepository;

  VerifyOtp(this._authRepository);

  Future<User> call({
    required PhoneNumber phone,
    required String otp,
  }) {
    return _authRepository.verifyOtp(phone: phone, otp: otp);
  }
}
