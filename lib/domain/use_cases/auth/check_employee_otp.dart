import '../../repositories/auth_repository.dart';
import '../../value_objects/phone_number.dart';

class CheckEmployeeOtp {
  final AuthRepository _repository;

  CheckEmployeeOtp(this._repository);

  Future<void> call({required PhoneNumber phone, required String otp}) {
    if (!phone.isValid || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      throw Exception('Code OTP ou numéro de téléphone invalide.');
    }
    return _repository.checkEmployeeOtp(phone: phone, otp: otp);
  }
}
