import '../../errors/app_failure.dart';
import '../../repositories/auth_repository.dart';
import '../../value_objects/phone_number.dart';

class ResetPin {
  const ResetPin(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({
    required PhoneNumber phone,
    required String verificationCode,
    required String newPin,
  }) async {
    if (!phone.isValid) {
      throw const ValidationFailure(
        'Numéro de téléphone invalide.',
        code: 'invalid_phone',
      );
    }
    if (!RegExp(r'^\d{4}$').hasMatch(newPin)) {
      throw const ValidationFailure(
        'Le code secret doit contenir 4 chiffres.',
        code: 'invalid_pin',
      );
    }
    if (!RegExp(r'^\d{6}$').hasMatch(verificationCode)) {
      throw const ValidationFailure(
        'Le code OTP doit contenir 6 chiffres.',
        code: 'invalid_otp',
      );
    }
    await _authRepository.resetPin(
      phone: phone,
      verificationCode: verificationCode,
      newPin: newPin,
    );
  }
}
