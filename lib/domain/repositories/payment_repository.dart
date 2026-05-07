import '../entities/transaction.dart';
import '../value_objects/money.dart';

abstract class PaymentRepository {
  Future<PaymentInitiation> initiatePayment({
    required String qrToken,
    required Money amount,
  });
  
  Future<Transaction> confirmPayment({
    required String paymentToken,
    required String pin,
  });

  Future<void> cancelPayment(String paymentId);
}

class PaymentInitiation {
  final String token;
  final String merchantName;
  final Money amount;
  final DateTime expiresAt;

  const PaymentInitiation({
    required this.token,
    required this.merchantName,
    required this.amount,
    required this.expiresAt,
  });

  PaymentInitiation copyWith({
    String? token,
    String? merchantName,
    Money? amount,
    DateTime? expiresAt,
  }) {
    return PaymentInitiation(
      token: token ?? this.token,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
