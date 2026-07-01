import '../../repositories/auth_repository.dart';

class Logout {
  final AuthRepository _authRepository;

  Logout(this._authRepository);

  Future<void> call() {
    return _authRepository.logout();
  }
}
