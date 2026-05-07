import '../../repositories/payment_repository.dart';
import '../../value_objects/money.dart';

class InitiatePayment {
  final PaymentRepository _paymentRepository;

  InitiatePayment(this._paymentRepository);

  Future<PaymentInitiation> call({
    required String qrToken,
    required Money amount,
  }) {
    return _paymentRepository.initiatePayment(
      qrToken: qrToken,
      amount: amount,
    );
  }
}
