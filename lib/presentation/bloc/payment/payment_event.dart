import 'package:equatable/equatable.dart';
import '../../../domain/value_objects/money.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class QrScanned extends PaymentEvent {
  final String qrToken;
  final String merchantName;
  final Money amount;

  const QrScanned({
    required this.qrToken,
    required this.merchantName,
    required this.amount,
  });

  @override
  List<Object?> get props => [qrToken, merchantName, amount];
}

class PaymentConfirmed extends PaymentEvent {
  final String pin;

  const PaymentConfirmed(this.pin);

  @override
  List<Object?> get props => [pin];
}

class CancelPayment extends PaymentEvent {
  const CancelPayment();
}

class PaymentReset extends PaymentEvent {
  const PaymentReset();
}
