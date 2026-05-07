import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/value_objects/money.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

class PaymentQrScanned extends PaymentState {
  final String qrToken;
  final String merchantName;
  final Money amount;

  const PaymentQrScanned({
    required this.qrToken,
    required this.merchantName,
    required this.amount,
  });

  @override
  List<Object?> get props => [qrToken, merchantName, amount];
}

class PaymentProcessing extends PaymentState {
  final String qrToken;
  final String merchantName;
  final Money amount;

  const PaymentProcessing({
    required this.qrToken,
    required this.merchantName,
    required this.amount,
  });

  @override
  List<Object?> get props => [qrToken, merchantName, amount];
}

class PaymentSuccess extends PaymentState {
  final Transaction transaction;

  const PaymentSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}


class PaymentFailure extends PaymentState {
  final String errorMessage;

  const PaymentFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class PaymentCancelled extends PaymentState {
  const PaymentCancelled();
}
