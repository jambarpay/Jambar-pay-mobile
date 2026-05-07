import '../../repositories/auth_repository.dart';
import '../../value_objects/phone_number.dart';

class SendOtp {
  final AuthRepository _authRepository;

  SendOtp(this._authRepository);

  Future<void> call(PhoneNumber phone) {
    return _authRepository.sendOtp(phone);
  }
}
