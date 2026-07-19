import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/domain/repositories/payment_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/payment/confirm_payment.dart';
import 'package:jambar_pay_mobile/domain/use_cases/payment/initiate_payment.dart';
import 'package:jambar_pay_mobile/domain/value_objects/money.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_state.dart';

void main() {
  test('initiates and confirms a payment through its repository', () async {
    final repository = _FakePaymentRepository();
    final bloc = PaymentBloc(
      initiatePayment: InitiatePayment(repository),
      confirmPayment: ConfirmPayment(repository),
    );
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([
        isA<PaymentProcessing>(),
        isA<PaymentQrScanned>(),
        isA<PaymentProcessing>(),
        isA<PaymentSuccess>(),
      ]),
    );

    bloc.add(
      QrScanned(
        qrToken: 'merchant-token',
        merchantName: 'Le FOOD',
        amount: Money.xof(3500),
      ),
    );
    await bloc.stream.firstWhere((state) => state is PaymentQrScanned);
    bloc.add(const PaymentConfirmed('1234'));

    await expectation;
    expect(repository.confirmedPin, '1234');
  });
}

class _FakePaymentRepository implements PaymentRepository {
  String? confirmedPin;

  @override
  Future<PaymentInitiation> initiatePayment({
    required String qrToken,
    required Money amount,
  }) async {
    return PaymentInitiation(
      token: qrToken,
      merchantName: 'Le FOOD',
      amount: amount,
      expiresAt: DateTime(2030),
    );
  }

  @override
  Future<Transaction> confirmPayment({
    required String paymentToken,
    required String pin,
  }) async {
    confirmedPin = pin;
    return Transaction(
      id: 'transaction-1',
      type: TransactionType.debit,
      amount: Money.xof(3500),
      label: 'Le FOOD',
      date: DateTime(2030),
      status: TransactionStatus.validated,
    );
  }

  @override
  Future<void> cancelPayment(String paymentId) async {}
}
