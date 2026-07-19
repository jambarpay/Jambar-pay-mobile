import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_event.dart';
import 'payment_state.dart';
import '../../../domain/use_cases/payment/confirm_payment.dart';
import '../../../domain/use_cases/payment/initiate_payment.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final InitiatePayment _initiatePayment;
  final ConfirmPayment _confirmPayment;

  PaymentBloc({
    required InitiatePayment initiatePayment,
    required ConfirmPayment confirmPayment,
  }) : _initiatePayment = initiatePayment,
       _confirmPayment = confirmPayment,
       super(const PaymentInitial()) {
    on<QrScanned>(_onQrScanned);
    on<PaymentConfirmed>(_onPaymentConfirmed);
    on<CancelPayment>(_onPaymentCancelled);
    on<PaymentReset>(_onPaymentReset);
  }

  Future<void> _onQrScanned(QrScanned event, Emitter<PaymentState> emit) async {
    emit(
      PaymentProcessing(
        qrToken: event.qrToken,
        merchantName: event.merchantName,
        amount: event.amount,
      ),
    );
    try {
      final initiation = await _initiatePayment(
        qrToken: event.qrToken,
        amount: event.amount,
      );
      emit(
        PaymentQrScanned(
          qrToken: initiation.token,
          merchantName: initiation.merchantName,
          amount: initiation.amount,
        ),
      );
    } catch (error) {
      emit(PaymentFailure(error.toString()));
    }
  }

  Future<void> _onPaymentConfirmed(
    PaymentConfirmed event,
    Emitter<PaymentState> emit,
  ) async {
    if (state is! PaymentQrScanned) return;
    final current = state as PaymentQrScanned;

    emit(
      PaymentProcessing(
        qrToken: current.qrToken,
        merchantName: current.merchantName,
        amount: current.amount,
      ),
    );

    try {
      final transaction = await _confirmPayment(
        paymentToken: current.qrToken,
        pin: event.pin,
      );
      emit(PaymentSuccess(transaction));
    } catch (e) {
      emit(PaymentFailure('Paiement échoué: ${e.toString()}'));
    }
  }

  void _onPaymentCancelled(CancelPayment event, Emitter<PaymentState> emit) {
    emit(const PaymentCancelled());
  }

  void _onPaymentReset(PaymentReset event, Emitter<PaymentState> emit) {
    emit(const PaymentInitial());
  }
}
