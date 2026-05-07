import '../../repositories/payment_repository.dart';
import '../../entities/transaction.dart';

class ConfirmPayment {
  final PaymentRepository _paymentRepository;

  ConfirmPayment(this._paymentRepository);

  Future<Transaction> call({
    required String paymentToken,
    required String pin,
  }) {
    return _paymentRepository.confirmPayment(
      paymentToken: paymentToken,
      pin: pin,
    );
  }
}
