import '../../repositories/auth_repository.dart';

class DeleteAccount {
  const DeleteAccount(this._authRepository);

  final AuthRepository _authRepository;

  Future<void> call() => _authRepository.deleteAccount();
}
