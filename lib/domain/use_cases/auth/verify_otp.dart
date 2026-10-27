import '../../errors/app_failure.dart';
import '../../repositories/auth_repository.dart';
import '../../entities/user.dart';
import '../../value_objects/phone_number.dart';

class VerifyOtp {
  final AuthRepository _authRepository;

  VerifyOtp(this._authRepository);

  Future<User> call({
    required PhoneNumber phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) {
    if (pin != null && !RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const ValidationFailure(
        'Le code PIN doit contenir 4 chiffres.',
        code: 'invalid_pin',
      );
    }
    if (pinConfirmation != null &&
        !RegExp(r'^\d{4}$').hasMatch(pinConfirmation)) {
      throw const ValidationFailure(
        'La confirmation du PIN doit contenir 4 chiffres.',
        code: 'invalid_pin',
      );
    }
    if ((pin == null) != (pinConfirmation == null) ||
        (pin != null && pin != pinConfirmation)) {
      throw const ValidationFailure(
        'Les deux codes PIN doivent être identiques.',
        code: 'pin_mismatch',
      );
    }
    return _authRepository.verifyOtp(
      phone: phone,
      otp: otp,
      pin: pin,
      pinConfirmation: pinConfirmation,
    );
  }
}
