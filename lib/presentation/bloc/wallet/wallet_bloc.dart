import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/wallet/get_wallet.dart';
import '../../../domain/use_cases/wallet/refresh_wallet.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({
    required GetWallet getWallet,
    required RefreshWallet refreshWallet,
  }) : _getWallet = getWallet,
       _refreshWallet = refreshWallet,
       super(const WalletInitial()) {
    on<WalletLoadRequested>(_onLoadRequested);
    on<WalletRefreshRequested>(_onRefreshRequested);
    on<WalletDebitApplied>(_onDebitApplied);
  }

  final GetWallet _getWallet;
  final RefreshWallet _refreshWallet;

  Future<void> _onLoadRequested(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      emit(WalletLoaded(await _getWallet()));
    } catch (error) {
      emit(WalletFailure(error.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    WalletRefreshRequested event,
    Emitter<WalletState> emit,
  ) async {
    try {
      emit(WalletLoaded(await _refreshWallet()));
    } catch (error) {
      emit(WalletFailure(error.toString()));
    }
  }

  void _onDebitApplied(WalletDebitApplied event, Emitter<WalletState> emit) {
    final currentState = state;
    if (currentState is! WalletLoaded) return;

    emit(
      WalletLoaded(
        currentState.wallet.copyWith(
          balance: currentState.wallet.balance - event.amount,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }
}
