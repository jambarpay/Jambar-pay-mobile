enum PaymentStatus { pending, success, failed }

enum PaymentStep {
  idle,
  qrScanned,
  awaitingConfirmation,
  processing,
  confirmed,
  failed,
}

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;
}

class MoneyModel {
  const MoneyModel({
    required this.amount,
    required this.currency,
    required this.formatted,
    required this.symbol,
  });

  final double amount;
  final String currency;
  final String formatted;
  final String symbol;

  factory MoneyModel.xof(num amount) {
    final normalized = amount.round();
    return MoneyModel(
      amount: normalized.toDouble(),
      currency: 'XOF',
      formatted: '${_formatThousands(normalized)} Fcfa',
      symbol: 'F',
    );
  }

  static String _formatThousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(' ');
      buffer.write(digits[index]);
    }
    return value.isNegative ? '-$buffer' : buffer.toString();
  }
}

class QRScanResultModel {
  const QRScanResultModel({
    required this.token,
    required this.merchantName,
    required this.amount,
    required this.expiresAt,
  });

  final String token;
  final String merchantName;
  final MoneyModel amount;
  final String expiresAt;
}

class PaymentResultModel {
  const PaymentResultModel({
    required this.paymentId,
    required this.status,
    required this.amount,
    required this.date,
    this.receiptUrl,
  });

  final String paymentId;
  final PaymentStatus status;
  final MoneyModel amount;
  final String date;
  final String? receiptUrl;
}

class WalletSummaryModel {
  const WalletSummaryModel({
    required this.walletId,
    required this.balance,
    required this.status,
    required this.lastUpdated,
  });

  final String walletId;
  final MoneyModel balance;
  final String status;
  final String lastUpdated;
}

class TransactionItemModel {
  const TransactionItemModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.label,
    required this.date,
    required this.status,
  });

  final String id;
  final String type;
  final MoneyModel amount;
  final String label;
  final String date;
  final String status;

  bool get isCredit => type.toUpperCase() == 'CREDIT';
  String get signedAmount => '${isCredit ? '+' : '-'}${amount.formatted}';
}

class PaymentUIState {
  const PaymentUIState({
    this.step = PaymentStep.idle,
    this.scanResult,
    this.currentPayment,
    this.error,
    this.loading = false,
  });

  final PaymentStep step;
  final QRScanResultModel? scanResult;
  final PaymentResultModel? currentPayment;
  final String? error;
  final bool loading;

  PaymentUIState copyWith({
    PaymentStep? step,
    QRScanResultModel? scanResult,
    PaymentResultModel? currentPayment,
    String? error,
    bool? loading,
  }) {
    return PaymentUIState(
      step: step ?? this.step,
      scanResult: scanResult ?? this.scanResult,
      currentPayment: currentPayment ?? this.currentPayment,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
}

class AppState {
  const AppState({
    required this.userProfile,
    this.wallet,
    this.payment = const PaymentUIState(),
  });

  final UserProfileModel userProfile;
  final WalletSummaryModel? wallet;
  final PaymentUIState payment;

  AppState copyWith({
    UserProfileModel? userProfile,
    WalletSummaryModel? wallet,
    bool clearWallet = false,
    PaymentUIState? payment,
  }) {
    return AppState(
      userProfile: userProfile ?? this.userProfile,
      wallet: clearWallet ? null : wallet ?? this.wallet,
      payment: payment ?? this.payment,
    );
  }
}
