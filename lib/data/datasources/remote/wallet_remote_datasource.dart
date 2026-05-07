import '../../../ApiService/ApiService.dart';
import '../../../ApiService/BaseUrl.dart';

class WalletRemoteDataSource {
  final ApiService apiService;

  WalletRemoteDataSource(this.apiService);

  Future<Map<String, dynamic>> getWallet() async {
    final response = await apiService.get(BaseUrl.wallet());
    if (response is! Map) {
      throw Exception('Invalid wallet response');
    }
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> updateBalanceAfterPayment({
    required double amount,
    required bool isCredit,
  }) async {
    final response = await apiService.post(
      BaseUrl.walletUpdate(),
      {
        'amount': amount,
        'type': isCredit ? 'CREDIT' : 'DEBIT',
      },
    );
    if (response is! Map) {
      throw Exception('Invalid update response');
    }
    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> refreshWallet() async {
    return getWallet();
  }
}
