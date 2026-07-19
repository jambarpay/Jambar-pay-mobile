import 'package:equatable/equatable.dart';

import '../../../domain/value_objects/money.dart';

sealed class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

final class WalletLoadRequested extends WalletEvent {
  const WalletLoadRequested();
}

final class WalletRefreshRequested extends WalletEvent {
  const WalletRefreshRequested();
}

final class WalletDebitApplied extends WalletEvent {
  const WalletDebitApplied(this.amount);

  final Money amount;

  @override
  List<Object?> get props => [amount];
}
