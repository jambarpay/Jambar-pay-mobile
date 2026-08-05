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
      throw Exception(
        'Impossible de rafraîchir le portefeuille: ${e.toString()}',
      );
    }
  }

  Wallet _mapToWallet(Map<String, dynamic> json) {
    final rawBalance = json['balance'];
    final balance = Money(
      amount: rawBalance is Map
          ? (rawBalance['amount'] as num?)?.round() ?? 0
          : (rawBalance as num?)?.round() ?? 0,
      currency: rawBalance is Map
          ? rawBalance['currency']?.toString() ?? 'XOF'
          : json['currency']?.toString() ?? 'XOF',
    );
    final statusStr = json['status']?.toString().toLowerCase();
    final status = json['active'] == true || statusStr == 'active'
        ? WalletStatus.active
        : statusStr == 'frozen'
        ? WalletStatus.frozen
        : WalletStatus.inactive;

    return Wallet(
      walletId: json['walletId']?.toString() ?? json['id']?.toString() ?? '',
      balance: balance,
      status: status,
      lastUpdated:
          DateTime.tryParse(
            json['lastUpdated']?.toString() ??
                json['updatedAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }
}
