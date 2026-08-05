import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';
import '../../../core/session/current_user_session.dart';

class WalletRemoteDataSource {
  final ApiService apiService;

  WalletRemoteDataSource(
    this.apiService, [
    CurrentUserSession? currentUserSession,
  ]) : _currentUserSession = currentUserSession;

  final CurrentUserSession? _currentUserSession;

  String get _ownerId {
    final ownerId = _currentUserSession?.userId;
    if (ownerId == null || ownerId.isEmpty) {
      throw const ApiException(
        'Utilisateur requis pour charger le portefeuille.',
      );
    }
    return ownerId;
  }

  Future<Map<String, dynamic>> getWallet() async {
    final response = await apiService.get(BaseUrl.walletByOwner(_ownerId));
    if (response is! Map) {
      throw Exception('Invalid wallet response');
    }
    return Map<String, dynamic>.from(response);
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

  Future<Map<String, dynamic>> refreshWallet() async {
    return getWallet();
  }
}
