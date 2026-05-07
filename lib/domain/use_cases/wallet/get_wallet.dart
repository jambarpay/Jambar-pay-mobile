import '../../repositories/wallet_repository.dart';
import '../../entities/wallet.dart';

class GetWallet {
  final WalletRepository _walletRepository;

  GetWallet(this._walletRepository);

  Future<Wallet> call() {
    return _walletRepository.getWallet();
  }
}
