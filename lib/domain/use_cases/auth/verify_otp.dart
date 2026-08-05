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
      throw Exception('Le code PIN doit contenir 4 chiffres.');
    }
    if (pinConfirmation != null &&
        !RegExp(r'^\d{4}$').hasMatch(pinConfirmation)) {
      throw Exception('La confirmation du PIN doit contenir 4 chiffres.');
    }
    if ((pin == null) != (pinConfirmation == null) ||
        (pin != null && pin != pinConfirmation)) {
      throw Exception('Les deux codes PIN doivent être identiques.');
    }
    return _authRepository.verifyOtp(
      phone: phone,
      otp: otp,
      pin: pin,
      pinConfirmation: pinConfirmation,
    );
  }
}
