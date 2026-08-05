import '../../core/network/api_service.dart';
import '../../core/network/base_url.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/value_objects/money.dart';
import '../models/dto/transaction_dto.dart';
import '../../core/session/current_user_session.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(
    this._apiService, {
    CurrentUserSession? currentUserSession,
  }) : _currentUserSession = currentUserSession;

  final ApiService _apiService;
  final CurrentUserSession? _currentUserSession;
  Money? _pendingAmount;

  @override
  Future<PaymentInitiation> initiatePayment({
    required String qrToken,
    required Money amount,
  }) async {
    _pendingAmount = amount;
    return PaymentInitiation(
      token: qrToken,
      merchantName: 'Restaurant partenaire',
      amount: amount,
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  @override
  Future<Transaction> confirmPayment({
    required String paymentToken,
    required String pin,
  }) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const ApiException('Le code secret doit contenir 4 chiffres.');
    }
    final payerUserId = _currentUserSession?.userId;
    if (payerUserId == null || payerUserId.isEmpty) {
      throw const ApiException('Utilisateur payeur introuvable.');
    }
    final amount = _pendingAmount;
    if (amount == null) {
      throw const ApiException('Montant du paiement introuvable.');
    }
    final response = await _apiService.post(BaseUrl.payWithQr(), {
      'payerUserId': payerUserId,
      'qrContent': paymentToken,
      'amount': amount.amount,
      'currency': amount.currency,
      'pin': pin,
    });
    if (response is! Map) {
      throw const ApiException('Réponse de confirmation invalide.');
    }
    final transaction = TransactionDto.fromJson(
      Map<String, dynamic>.from(response),
    ).toDomain();
    _pendingAmount = null;
    return transaction;
  }

  @override
  Future<void> cancelPayment(String paymentId) async {
    _pendingAmount = null;
  }
}
