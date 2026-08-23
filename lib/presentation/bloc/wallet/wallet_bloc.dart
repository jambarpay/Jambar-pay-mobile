import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/use_cases/wallet/get_wallet.dart';
import '../../../domain/use_cases/wallet/refresh_wallet.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  WalletBloc({
    required GetWallet getWallet,
    required RefreshWallet refreshWallet,
    bool backgroundSync = true,
  }) : _getWallet = getWallet,
       _refreshWallet = refreshWallet,
       _backgroundSync = backgroundSync,
       super(const WalletInitial()) {
    on<WalletLoadRequested>(_onLoadRequested);
    on<WalletRefreshRequested>(_onRefreshRequested);
    on<WalletDebitApplied>(_onDebitApplied);
  }

  final GetWallet _getWallet;
  final RefreshWallet _refreshWallet;
  final bool _backgroundSync;

  Future<void> _onLoadRequested(
    WalletLoadRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());
    try {
      emit(WalletLoaded(await _getWallet()));
      if (_backgroundSync) {
        try {
          emit(WalletLoaded(await _refreshWallet()));
        } catch (_) {
          // The cached wallet remains usable while the device is offline.
        }
      }
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
