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
      } catch (_) {
        // Continue with the network request when the cache is unavailable.
      }
    }
    try {
      final response = await apiService.get(BaseUrl.walletByOwner(_ownerId));
      if (response is! Map) {
        throw Exception('Invalid wallet response');
      }
      final wallet = Map<String, dynamic>.from(response);
      try {
        await _sessionStorage?.saveWalletCache(wallet);
      } catch (_) {
        // Cache failures must not affect a successful network response.
      }
      return wallet;
    } catch (error) {
      try {
        final cached = await _sessionStorage?.readWalletCache();
        if (cached != null) return cached;
      } catch (_) {
        // Fall through to the original network error.
      }
      throw error;
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
      throw Exception('Invalid update response');
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
      throw Exception('Invalid top-up response');
    }
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> refreshWallet() async {
    return getWallet(forceRefresh: true);
  }
}
