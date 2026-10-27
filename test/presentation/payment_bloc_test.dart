import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/domain/errors/app_failure.dart';
import 'package:jambar_pay_mobile/domain/repositories/payment_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/payment/confirm_payment.dart';
import 'package:jambar_pay_mobile/domain/use_cases/payment/initiate_payment.dart';
import 'package:jambar_pay_mobile/domain/value_objects/money.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/language_controller.dart';
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

  for (final kind in [
    FailureKind.network,
    FailureKind.timeout,
    FailureKind.server,
    FailureKind.invalidResponse,
    FailureKind.unexpected,
  ]) {
    test('confirmation $kind reports uncertainty without retrying', () async {
      final repository = _FakePaymentRepository(
        confirmationError: AppFailure('private technical detail', kind: kind),
      );
      final bloc = _bloc(repository);
      addTearDown(bloc.close);
      await _scan(bloc);

      final result = bloc.stream.firstWhere((state) => state is PaymentFailure);
      bloc.add(const PaymentConfirmed('1234'));
      final failure = await result as PaymentFailure;
      final loc = AppLocalizations(LanguageController.localeNotifier.value);
      expect(failure.errorMessage, loc.errorPaymentUncertain);
      expect(repository.confirmationCalls, 1);

      // A second confirmation after failure must not send another payment.
      bloc.add(const PaymentConfirmed('1234'));
      bloc.add(const PaymentReset());
      await bloc.stream.firstWhere((state) => state is PaymentInitial);
      expect(repository.confirmationCalls, 1);
    });
  }

  test('an explicit business refusal keeps its actionable message', () async {
    final repository = _FakePaymentRepository(
      confirmationError: const AppFailure('Solde insuffisant', statusCode: 422),
    );
    final bloc = _bloc(repository);
    addTearDown(bloc.close);
    await _scan(bloc);

    final result = bloc.stream.firstWhere((state) => state is PaymentFailure);
    bloc.add(const PaymentConfirmed('1234'));
    final failure = await result as PaymentFailure;
    expect(failure.errorMessage, 'Solde insuffisant');
    expect(repository.confirmationCalls, 1);
  });
}

PaymentBloc _bloc(PaymentRepository repository) => PaymentBloc(
  initiatePayment: InitiatePayment(repository),
  confirmPayment: ConfirmPayment(repository),
);

Future<void> _scan(PaymentBloc bloc) async {
  final scanned = bloc.stream.firstWhere((state) => state is PaymentQrScanned);
  bloc.add(
    QrScanned(
      qrToken: 'merchant-token',
      merchantName: 'Le FOOD',
      amount: Money.xof(3500),
    ),
  );
  await scanned;
}

class _FakePaymentRepository implements PaymentRepository {
  _FakePaymentRepository({this.confirmationError});

  final Object? confirmationError;
  String? confirmedPin;
  int confirmationCalls = 0;

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
    confirmationCalls++;
    confirmedPin = pin;
    if (confirmationError != null) throw confirmationError!;
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
