import '../../repositories/wallet_repository.dart';
import '../../entities/wallet.dart';

class RefreshWallet {
  final WalletRepository _walletRepository;

  RefreshWallet(this._walletRepository);

  Future<Wallet> call() {
    return _walletRepository.refreshWallet();
  }
}
