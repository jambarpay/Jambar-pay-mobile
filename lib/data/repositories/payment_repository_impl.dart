import '../../domain/repositories/payment_repository.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/value_objects/money.dart';
class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl();

  @override
  Future<PaymentInitiation> initiatePayment({
    required String qrToken,
    required Money amount,
  }) async {

    await Future.delayed(const Duration(milliseconds: 500));
    
    return PaymentInitiation(
      token: qrToken,
      merchantName: 'Marchand',
      amount: amount,
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
    );
  }

  @override
  Future<Transaction> confirmPayment({
    required String paymentToken,
    required String pin,
  }) async {
    // PIN verification should be done via backend API
    // This is a placeholder implementation
    // TODO: Replace with actual backend verification
    if (pin.length != 4) {
      throw Exception('Code secret doit contenir 4 chiffres');
    }

    final now = DateTime.now();
    final transaction = Transaction(
      id: 'trx_${now.millisecondsSinceEpoch}',
      type: TransactionType.debit,
      amount: Money(amount: 3500, currency: 'XOF'),
      label: 'Paiement marchand',
      date: now,
      status: TransactionStatus.validated,
    );

    return transaction;
  }

  @override
  Future<void> cancelPayment(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
