import '../value_objects/money.dart';

enum WalletStatus { active, inactive, frozen }

class Wallet {
  final String walletId;
  final Money balance;
  final WalletStatus status;
  final DateTime lastUpdated;

  const Wallet({
    required this.walletId,
    required this.balance,
    required this.status,
    required this.lastUpdated,
  });

  Wallet copyWith({
    String? walletId,
    Money? balance,
    WalletStatus? status,
    DateTime? lastUpdated,
  }) {
    return Wallet(
      walletId: walletId ?? this.walletId,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Wallet &&
          runtimeType == other.runtimeType &&
          walletId == other.walletId &&
          balance == other.balance &&
          status == other.status &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode => Object.hash(walletId, balance, status, lastUpdated);
}
