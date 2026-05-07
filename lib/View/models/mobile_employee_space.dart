enum PaymentStatus { pending, success, failed }

enum PaymentStep {
  idle,
  qrScanned,
  awaitingConfirmation,
  processing,
  confirmed,
  failed,
}

enum NotificationType { info, payment, alert }

class AuthStateModel {
  final String? userId;
  final String? token;
  final bool isAuthenticated;
  final bool loading;

  const AuthStateModel({
    this.userId,
    this.token,
    this.isAuthenticated = false,
    this.loading = false,
  });

  AuthStateModel copyWith({
    String? userId,
    String? token,
    bool? isAuthenticated,
    bool? loading,
  }) {
    return AuthStateModel(
      userId: userId ?? this.userId,
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      loading: loading ?? this.loading,
    );
  }
}

class UserProfileModel {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.phone,
    this.avatarUrl,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? avatarUrl,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class MoneyModel {
  final double amount;
  final String currency;
  final String formatted;
  final String symbol;

  const MoneyModel({
    required this.amount,
    required this.currency,
    required this.formatted,
    required this.symbol,
  });

  factory MoneyModel.xof(num amount) {
    final normalized = amount.toDouble();
    return MoneyModel(
      amount: normalized,
      currency: 'XOF',
      formatted: '${_formatThousands(normalized.toInt())} Fcfa',
      symbol: 'F',
    );
  }

  static String _formatThousands(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[index]);
    }

    if (value.isNegative) {
      return '-${buffer.toString()}';
    }

    return buffer.toString();
  }
}

class QRScanResultModel {
  final String token;
  final String merchantName;
  final MoneyModel amount;
  final String expiresAt;

  const QRScanResultModel({
    required this.token,
    required this.merchantName,
    required this.amount,
    required this.expiresAt,
  });

  QRScanResultModel copyWith({
    String? token,
    String? merchantName,
    MoneyModel? amount,
    String? expiresAt,
  }) {
    return QRScanResultModel(
      token: token ?? this.token,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class PaymentResultModel {
  final String paymentId;
  final PaymentStatus status;
  final MoneyModel amount;
  final String date;
  final String? receiptUrl;

  const PaymentResultModel({
    required this.paymentId,
    required this.status,
    required this.amount,
    required this.date,
    this.receiptUrl,
  });

  PaymentResultModel copyWith({
    String? paymentId,
    PaymentStatus? status,
    MoneyModel? amount,
    String? date,
    String? receiptUrl,
  }) {
    return PaymentResultModel(
      paymentId: paymentId ?? this.paymentId,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }
}

class WalletSummaryModel {
  final String walletId;
  final MoneyModel balance;
  final String status;
  final String lastUpdated;

  const WalletSummaryModel({
    required this.walletId,
    required this.balance,
    required this.status,
    required this.lastUpdated,
  });

  WalletSummaryModel copyWith({
    String? walletId,
    MoneyModel? balance,
    String? status,
    String? lastUpdated,
  }) {
    return WalletSummaryModel(
      walletId: walletId ?? this.walletId,
      balance: balance ?? this.balance,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class TransactionItemModel {
  final String id;
  final String type;
  final MoneyModel amount;
  final String label;
  final String date;
  final String status;

  const TransactionItemModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.label,
    required this.date,
    required this.status,
  });

  bool get isCredit => type.toUpperCase() == 'CREDIT';

  String get signedAmount => '${isCredit ? '+' : '-'}${amount.formatted}';
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.read,
  });
}

class PaymentUIState {
  final PaymentStep step;
  final QRScanResultModel? scanResult;
  final PaymentResultModel? currentPayment;
  final String? error;
  final bool loading;

  const PaymentUIState({
    this.step = PaymentStep.idle,
    this.scanResult,
    this.currentPayment,
    this.error,
    this.loading = false,
  });

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

class RestaurantPartnerModel {
  final String id;
  final String name;
  final String distance;
  final String updatedAt;
  final bool isOpen;

  const RestaurantPartnerModel({
    required this.id,
    required this.name,
    required this.distance,
    required this.updatedAt,
    required this.isOpen,
  });
}

class AppState {
  final AuthStateModel auth;
  final UserProfileModel userProfile;
  final WalletSummaryModel? wallet;
  final PaymentUIState payment;
  final List<NotificationModel> notifications;
  final List<TransactionItemModel> transactions;
  final List<RestaurantPartnerModel> restaurants;
  final bool isLoading;

  const AppState({
    required this.auth,
    required this.userProfile,
    required this.wallet,
    required this.payment,
    required this.notifications,
    required this.transactions,
    required this.restaurants,
    this.isLoading = false,
  });

  AppState copyWith({
    AuthStateModel? auth,
    UserProfileModel? userProfile,
    WalletSummaryModel? wallet,
    PaymentUIState? payment,
    List<NotificationModel>? notifications,
    List<TransactionItemModel>? transactions,
    List<RestaurantPartnerModel>? restaurants,
    bool? isLoading,
  }) {
    return AppState(
      auth: auth ?? this.auth,
      userProfile: userProfile ?? this.userProfile,
      wallet: wallet ?? this.wallet,
      payment: payment ?? this.payment,
      notifications: notifications ?? this.notifications,
      transactions: transactions ?? this.transactions,
      restaurants: restaurants ?? this.restaurants,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory AppState.employeeDemo() {
    final profile = const UserProfileModel(
      id: 'usr_emp_001',
      name: 'Abdoulaye Diallo',
      phone: '76 483 14 41',
    );
    final lunchAmount = MoneyModel.xof(3500);

    return AppState(
      auth: const AuthStateModel(
        userId: 'usr_emp_001',
        token: 'mobile-demo-token',
        isAuthenticated: false,
      ),
      userProfile: profile,
      wallet: WalletSummaryModel(
        walletId: 'wal_emp_221',
        balance: MoneyModel.xof(45000),
        status: 'Actif',
        lastUpdated: "Aujourd'hui, 13h45",
      ),
      payment: PaymentUIState(
        step: PaymentStep.confirmed,
        scanResult: QRScanResultModel(
          token: 'qr-food-13h22',
          merchantName: 'Le FOOD',
          amount: lunchAmount,
          expiresAt: '06/05/2026 14:30',
        ),
        currentPayment: PaymentResultModel(
          paymentId: 'PAY-060526-01',
          status: PaymentStatus.success,
          amount: lunchAmount,
          date: "Aujourd'hui, 13h22",
        ),
      ),
      notifications: const [
        NotificationModel(
          id: 'notif_1',
          title: 'Paiement confirme',
          body: 'Votre paiement chez Le FOOD a ete confirme.',
          type: 'PAYMENT',
          read: false,
        ),
        NotificationModel(
          id: 'notif_2',
          title: 'Solde mis a jour',
          body: 'Votre portefeuille a ete synchronise avec succes.',
          type: 'INFO',
          read: true,
        ),
      ],
      transactions: [
        TransactionItemModel(
          id: 'trx_1',
          type: 'DEBIT',
          amount: lunchAmount,
          label: 'Le FOOD',
          date: "Aujourd'hui, 13h22",
          status: 'Valide',
        ),
        TransactionItemModel(
          id: 'trx_2',
          type: 'DEBIT',
          amount: MoneyModel.xof(2500),
          label: 'Keur Delice',
          date: "Aujourd'hui, 09h10",
          status: 'Valide',
        ),
        TransactionItemModel(
          id: 'trx_3',
          type: 'CREDIT',
          amount: MoneyModel.xof(15000),
          label: 'Recharge employeur',
          date: '05/05/2026, 18h40',
          status: 'Valide',
        ),
        TransactionItemModel(
          id: 'trx_4',
          type: 'DEBIT',
          amount: MoneyModel.xof(4200),
          label: 'Chez Binta',
          date: '04/05/2026, 12h05',
          status: 'Valide',
        ),
        TransactionItemModel(
          id: 'trx_5',
          type: 'DEBIT',
          amount: MoneyModel.xof(1800),
          label: 'Express Cafe',
          date: '03/05/2026, 08h24',
          status: 'En attente',
        ),
        TransactionItemModel(
          id: 'trx_6',
          type: 'DEBIT',
          amount: MoneyModel.xof(3900),
          label: 'Yassa Rapide',
          date: '02/05/2026, 13h01',
          status: 'Valide',
        ),
      ],
      restaurants: const [
        RestaurantPartnerModel(
          id: 'rest_1',
          name: 'Le FOOD',
          distance: '0.3 km',
          updatedAt: "Aujourd'hui, 13h22",
          isOpen: true,
        ),
        RestaurantPartnerModel(
          id: 'rest_2',
          name: 'Keur Delice',
          distance: '0.2 km',
          updatedAt: "Aujourd'hui, 11h05",
          isOpen: true,
        ),
        RestaurantPartnerModel(
          id: 'rest_3',
          name: 'Chez Binta',
          distance: '0.4 km',
          updatedAt: 'Hier, 12h15',
          isOpen: false,
        ),
        RestaurantPartnerModel(
          id: 'rest_4',
          name: 'Express Cafe',
          distance: '0.5 km',
          updatedAt: "Aujourd'hui, 08h30",
          isOpen: true,
        ),
        RestaurantPartnerModel(
          id: 'rest_5',
          name: 'Yassa Rapide',
          distance: '0.7 km',
          updatedAt: '05/05/2026, 13h01',
          isOpen: false,
        ),
      ],
    );
  }
}
