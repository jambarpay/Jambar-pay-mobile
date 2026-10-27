import '../../../core/errors/failure_handling.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';
import '../../../core/session/current_user_session.dart';
import '../../../core/storage/secure_session_storage.dart';

class WalletRemoteDataSource {
  final ApiService apiService;

  WalletRemoteDataSource(
    this.apiService, [
    CurrentUserSession? currentUserSession,
    SecureSessionStorage? sessionStorage,
  ]) : _currentUserSession = currentUserSession,
       _sessionStorage = sessionStorage;

  final CurrentUserSession? _currentUserSession;
  final SecureSessionStorage? _sessionStorage;

  String get _ownerId {
    final ownerId = _currentUserSession?.userId;
    if (ownerId == null || ownerId.isEmpty) {
      throw const ApiException(
        'Utilisateur requis pour charger le portefeuille.',
      );
    }
    return ownerId;
  }

  Future<Map<String, dynamic>> getWallet({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final cached = await _sessionStorage?.readWalletCache();
        if (cached != null) return cached;
      } catch (error, stackTrace) {
        FailureDiagnostics.record(
          error,
          stackTrace,
          operation: 'wallet_remote_datasource',
        );
        // Continue with the network request when the cache is unavailable.
      }
    }
    try {
      final response = await apiService.get(BaseUrl.walletByOwner(_ownerId));
      if (response is! Map) {
        throw const ApiException(
          'Invalid wallet response',
          kind: FailureKind.invalidResponse,
        );
      }
      final wallet = Map<String, dynamic>.from(response);
      try {
        await _sessionStorage?.saveWalletCache(wallet);
      } catch (error, stackTrace) {
        FailureDiagnostics.record(
          error,
          stackTrace,
          operation: 'wallet_remote_datasource',
        );
        // Cache failures must not affect a successful network response.
      }
      return wallet;
    } catch (error) {
      if (!canUseCachedData(error)) rethrow;
      try {
        final cached = await _sessionStorage?.readWalletCache();
        if (cached != null) return cached;
      } catch (error, stackTrace) {
        FailureDiagnostics.record(
          error,
          stackTrace,
          operation: 'wallet_remote_datasource',
        );
        // Fall through to the original network error.
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBalanceAfterPayment({
    required int amount,
    required bool isCredit,
  }) async {
    if (!isCredit) {
      return getWallet();
    }
    final wallet = await getWallet();
    final walletId = wallet['id']?.toString() ?? '';
    if (walletId.isEmpty) {
      throw const ApiException('Identifiant du portefeuille manquant.');
    }
    final response = await apiService.patch(BaseUrl.walletTopUp(walletId), {
      'amount': amount,
      'currency': wallet['currency']?.toString() ?? 'XOF',
    });
    if (response is! Map) {
      throw const ApiException(
        'Invalid update response',
        kind: FailureKind.invalidResponse,
      );
    }
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> topUpWithProvider({
    required int amount,
    required String providerTransactionId,
  }) async {
    final wallet = await getWallet();
    final walletId =
        wallet['id']?.toString() ?? wallet['walletId']?.toString() ?? '';
    if (walletId.isEmpty) {
      throw const ApiException('Identifiant du portefeuille manquant.');
    }

    final response = await apiService.patch(BaseUrl.walletTopUp(walletId), {
      'amount': amount,
      'currency': wallet['currency']?.toString() ?? 'XOF',
      'providerTransactionId': providerTransactionId,
    });
    if (response is! Map) {
      throw const ApiException(
        'Invalid top-up response',
        kind: FailureKind.invalidResponse,
      );
    }
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> refreshWallet() async {
    return getWallet(forceRefresh: true);
  }
}
