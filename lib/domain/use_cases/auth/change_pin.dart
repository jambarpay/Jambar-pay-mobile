import '../../repositories/auth_repository.dart';

class ChangePin {
  const ChangePin(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call({
    required String currentPin,
    required String newPin,
  }) async {
    if (!RegExp(r'^\d{4}$').hasMatch(currentPin)) {
      throw Exception('Le code secret actuel doit contenir 4 chiffres.');
    }
    if (!RegExp(r'^\d{4}$').hasMatch(newPin)) {
      throw Exception('Le code secret doit contenir 4 chiffres.');
    }
    await _authRepository.changePin(currentPin: currentPin, newPin: newPin);
  }
}
