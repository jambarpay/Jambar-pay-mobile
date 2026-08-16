import '../entities/wallet.dart';
import '../value_objects/money.dart';

abstract class WalletRepository {
  Future<Wallet> getWallet();

  Future<Wallet> updateBalanceAfterPayment({
    required Money amount,
    required bool isCredit,
  });

  Future<Wallet> topUpWithProvider({
    required Money amount,
    required String providerTransactionId,
  });

  Future<Wallet> refreshWallet();
}
