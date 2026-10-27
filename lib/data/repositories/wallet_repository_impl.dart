import '../../domain/repositories/wallet_repository.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/errors/app_failure.dart';
import '../datasources/remote/wallet_remote_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<Wallet> getWallet() async {
    final json = await _remoteDataSource.getWallet();
    return _mapToWallet(json);
  }

  @override
  Future<Wallet> updateBalanceAfterPayment({
    required Money amount,
    required bool isCredit,
  }) async {
    final json = await _remoteDataSource.updateBalanceAfterPayment(
      amount: amount.amount,
      isCredit: isCredit,
    );
    return _mapToWallet(json);
  }

  @override
  Future<Wallet> topUpWithProvider({
    required Money amount,
    required String providerTransactionId,
  }) async {
    final json = await _remoteDataSource.topUpWithProvider(
      amount: amount.amount,
      providerTransactionId: providerTransactionId,
    );
    return _mapToWallet(json);
  }

  @override
  Future<Wallet> refreshWallet() async {
    final json = await _remoteDataSource.refreshWallet();
    return _mapToWallet(json);
  }

  Wallet _mapToWallet(Map<String, dynamic> json) {
    final rawBalance = json['balance'];
    final rawAmount = rawBalance is Map ? rawBalance['amount'] : rawBalance;
    if (rawAmount is! num || !rawAmount.isFinite) {
      throw const AppFailure(
        'Invalid wallet balance',
        kind: FailureKind.invalidResponse,
      );
    }
    final balance = Money(
      amount: rawAmount.round(),
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
