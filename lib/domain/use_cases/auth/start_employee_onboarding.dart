import '../../repositories/auth_repository.dart';
import '../../value_objects/phone_number.dart';

class StartEmployeeOnboarding {
  final AuthRepository _authRepository;

  StartEmployeeOnboarding(this._authRepository);

  Future<bool> call(PhoneNumber phone) {
    return _authRepository.startEmployeeOnboarding(phone);
  }
}
