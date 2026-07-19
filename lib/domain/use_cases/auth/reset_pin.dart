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
      throw Exception('Numéro de téléphone invalide.');
    }
    if (!RegExp(r'^\d{4}$').hasMatch(newPin)) {
      throw Exception('Le code secret doit contenir 4 chiffres.');
    }
    if (!RegExp(r'^\d{4}$').hasMatch(verificationCode)) {
      throw Exception('Le code de vérification doit contenir 4 chiffres.');
    }
    await _authRepository.resetPin(
      phone: phone,
      verificationCode: verificationCode,
      newPin: newPin,
    );
  }
}
