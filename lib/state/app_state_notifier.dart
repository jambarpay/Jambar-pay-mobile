import 'package:flutter/foundation.dart';
import 'package:jambar_pay_mobile/View/models/mobile_employee_space.dart';

class AppStateNotifier extends ChangeNotifier {
  AppState _state;

  AppStateNotifier() : _state = AppState.employeeDemo();

  AppState get state => _state;

  void updateState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

  void setUserProfile(UserProfileModel profile) {
    _state = _state.copyWith(userProfile: profile);
    notifyListeners();
  }

  void setUserPhone(String formattedPhone) {
    _state = _state.copyWith(
      userProfile: _state.userProfile.copyWith(phone: formattedPhone),
    );
    notifyListeners();
  }

  void authenticate({required bool isAuthenticated, String? userId}) {
    _state = _state.copyWith(
      auth: _state.auth.copyWith(
        isAuthenticated: isAuthenticated,
        userId: userId ?? _state.auth.userId,
      ),
    );
    notifyListeners();
  }

  void setDarkMode(bool value) {
    notifyListeners();
  }

  void registerSimulatedPayment(
    QRScanResultModel scanResult,
    PaymentResultModel paymentResult,
  ) {
    final currentWallet = _state.wallet;
    final updatedWallet = currentWallet?.copyWith(
      balance: MoneyModel.xof(
        currentWallet.balance.amount - paymentResult.amount.amount,
      ),
      lastUpdated: paymentResult.date,
    );

    final newTransaction = TransactionItemModel(
      id: 'trx_${DateTime.now().millisecondsSinceEpoch}',
      type: 'DEBIT',
      amount: paymentResult.amount,
      label: scanResult.merchantName,
      date: paymentResult.date,
      status: 'Valide',
    );

    final newNotification = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Paiement reussi',
      body:
          'Votre paiement de ${paymentResult.amount.formatted} chez '
          '${scanResult.merchantName} a ete confirme.',
      type: 'PAYMENT',
      read: false,
    );

    _state = _state.copyWith(
      wallet: updatedWallet,
      payment: _state.payment.copyWith(
        step: PaymentStep.confirmed,
        scanResult: scanResult,
        currentPayment: paymentResult,
        loading: false,
        error: null,
      ),
      transactions: [newTransaction, ..._state.transactions],
      notifications: [newNotification, ..._state.notifications],
    );

    notifyListeners();
  }
}
