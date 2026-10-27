import '../../errors/app_failure.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';
import '../../value_objects/phone_number.dart';

class LoginWithPin {
  const LoginWithPin(this._authRepository);

  final AuthRepository _authRepository;

  Future<User> call({required PhoneNumber phone, required String pin}) {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const ValidationFailure(
        'Le code PIN doit contenir 4 chiffres.',
        code: 'invalid_pin',
      );
    }
    return _authRepository.loginWithPin(phone: phone, pin: pin);
  }
}
