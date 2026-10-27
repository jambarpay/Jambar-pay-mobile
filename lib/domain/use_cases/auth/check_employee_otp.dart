import '../../errors/app_failure.dart';
import '../../repositories/auth_repository.dart';
import '../../value_objects/phone_number.dart';

class CheckEmployeeOtp {
  final AuthRepository _repository;

  CheckEmployeeOtp(this._repository);

  Future<void> call({required PhoneNumber phone, required String otp}) {
    if (!phone.isValid) {
      throw const ValidationFailure(
        'Code OTP ou numéro de téléphone invalide.',
        code: 'invalid_phone',
      );
    }
    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      throw const ValidationFailure(
        'Le code OTP doit contenir 6 chiffres.',
        code: 'invalid_otp',
      );
    }
    return _repository.checkEmployeeOtp(phone: phone, otp: otp);
  }
}
