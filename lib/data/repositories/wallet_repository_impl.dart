import '../../domain/repositories/wallet_repository.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/value_objects/money.dart';
import '../datasources/remote/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<Wallet> getWallet() async {
    try {
      final json = await _remoteDataSource.getWallet();
      return _mapToWallet(json);
    } catch (e) {
      throw Exception('Impossible de charger le portefeuille: ${e.toString()}');
    }
  }

  @override
  Future<Wallet> updateBalanceAfterPayment({
    required Money amount,
    required bool isCredit,
  }) async {
    try {
      final json = await _remoteDataSource.updateBalanceAfterPayment(
        amount: amount.amount,
        isCredit: isCredit,
      );
      return _mapToWallet(json);
    } catch (e) {
      throw Exception('Impossible de mettre à jour le solde: ${e.toString()}');
    }
  }

  @override
  Future<Wallet> refreshWallet() async {
    try {
      final json = await _remoteDataSource.refreshWallet();
      return _mapToWallet(json);
    } catch (e) {
      throw Exception('Impossible de rafraîchir le portefeuille: ${e.toString()}');
    }
  }

  Wallet _mapToWallet(Map<String, dynamic> json) {
    final balance = Money(
      amount: (json['balance']?['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['balance']?['currency'] ?? 'XOF',
    );
    final statusStr = json['status']?.toString().toLowerCase() ?? 'active';
    final status = statusStr == 'active'
        ? WalletStatus.active
        : statusStr == 'frozen'
            ? WalletStatus.frozen
            : WalletStatus.inactive;

    return Wallet(
      walletId: json['walletId']?.toString() ?? '',
      balance: balance,
      status: status,
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
