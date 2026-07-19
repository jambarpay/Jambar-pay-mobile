import '../../core/network/api_service.dart';
import '../../core/network/base_url.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/value_objects/money.dart';
import '../models/dto/transaction_dto.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._apiService);

  final ApiService _apiService;

  @override
  Future<PaymentInitiation> initiatePayment({
    required String qrToken,
    required Money amount,
  }) async {
    final response = await _apiService.post(BaseUrl.comptesQr(), {
      'qrToken': qrToken,
      'amount': amount.amount,
      'currency': amount.currency,
    });
    if (response is! Map) {
      throw const ApiException('Réponse de paiement invalide.');
    }
    final data = Map<String, dynamic>.from(response);
    final responseAmount = data['amount'];
    final parsedAmount = responseAmount is Map
        ? Money(
            amount:
                (responseAmount['montant'] as num?)?.toDouble() ??
                amount.amount,
            currency: responseAmount['currency']?.toString() ?? amount.currency,
          )
        : amount;

    return PaymentInitiation(
      token: data['token']?.toString() ?? qrToken,
      merchantName: data['merchantName']?.toString() ?? 'Marchand',
      amount: parsedAmount,
      expiresAt:
          DateTime.tryParse(data['expiresAt']?.toString() ?? '') ??
          DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  @override
  Future<Transaction> confirmPayment({
    required String paymentToken,
    required String pin,
  }) async {
    if (pin.length != 4) {
      throw const ApiException('Le code secret doit contenir 4 chiffres.');
    }
    final response = await _apiService.post(BaseUrl.comptesPayer(), {
      'paymentToken': paymentToken,
      'pin': pin,
    });
    if (response is! Map) {
      throw const ApiException('Réponse de confirmation invalide.');
    }
    return TransactionDto.fromJson(
      Map<String, dynamic>.from(response),
    ).toDomain();
  }

  @override
  Future<void> cancelPayment(String paymentId) async {
    await _apiService.delete('${BaseUrl.comptesPayer()}/$paymentId');
  }
}
