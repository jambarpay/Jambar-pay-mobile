import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/domain/entities/user.dart';
import 'package:jambar_pay_mobile/domain/entities/wallet.dart';
import 'package:jambar_pay_mobile/domain/repositories/auth_repository.dart';
import 'package:jambar_pay_mobile/domain/repositories/payment_repository.dart';
import 'package:jambar_pay_mobile/domain/repositories/transaction_repository.dart';
import 'package:jambar_pay_mobile/domain/repositories/wallet_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/change_pin.dart';
import 'package:jambar_pay_mobile/domain/use_cases/auth/logout.dart';
import 'package:jambar_pay_mobile/domain/use_cases/payment/confirm_payment.dart';
import 'package:jambar_pay_mobile/domain/use_cases/payment/initiate_payment.dart';
import 'package:jambar_pay_mobile/domain/use_cases/transactions/filter_transactions.dart';
import 'package:jambar_pay_mobile/domain/use_cases/transactions/get_transactions.dart';
import 'package:jambar_pay_mobile/domain/use_cases/wallet/get_wallet.dart';
import 'package:jambar_pay_mobile/domain/use_cases/wallet/refresh_wallet.dart';
import 'package:jambar_pay_mobile/domain/value_objects/money.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/payment/payment_state.dart';
import 'package:jambar_pay_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/profile/profile_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/profile/profile_state.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/transactions/transaction_state.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_event.dart';
import 'package:jambar_pay_mobile/presentation/bloc/wallet/wallet_state.dart';

void main() {
  group('ProfileBloc', () {
    test('loads profile state and toggles dark mode', () async {
      final repository = _ProfileAuthRepository();
      final bloc = ProfileBloc(
        changePin: ChangePin(repository),
        logout: Logout(repository),
      );
      addTearDown(bloc.close);

      final loaded = expectLater(
        bloc.stream,
        emitsInOrder([isA<ProfileLoading>(), isA<ProfileLoaded>()]),
      );
      bloc.add(const ProfileLoadRequested());
      await loaded;

      final dark = expectLater(
        bloc.stream,
        emits(
          isA<ProfileLoaded>().having(
            (state) => state.isDarkMode,
            'isDarkMode',
            isTrue,
          ),
        ),
      );
      bloc.add(const DarkModeChanged(true));
      await dark;
    });

    test('reports PIN change success and failure', () async {
      final repository = _ProfileAuthRepository();
      final bloc = ProfileBloc(
        changePin: ChangePin(repository),
        logout: Logout(repository),
      );
      addTearDown(bloc.close);

      final success = expectLater(
        bloc.stream,
        emitsInOrder([isA<PinChangeInProgress>(), isA<PinChangeSuccess>()]),
      );
      bloc.add(const PinChangeRequested(currentPin: '1234', newPin: '5678'));
      await success;
      expect(repository.changedPin, ('1234', '5678'));

      repository.changeError = StateError('invalid current PIN');
      final failure = expectLater(
        bloc.stream,
        emitsInOrder([isA<PinChangeInProgress>(), isA<PinChangeFailure>()]),
      );
      bloc.add(const PinChangeRequested(currentPin: '0000', newPin: '5678'));
      await failure;
    });

    test('always completes logout even when the service fails', () async {
      final repository = _ProfileAuthRepository()
        ..logoutError = StateError('offline');
      final bloc = ProfileBloc(
        changePin: ChangePin(repository),
        logout: Logout(repository),
      );
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<LogoutInProgress>(), isA<LogoutComplete>()]),
      );
      bloc.add(const LogoutRequested());
      await expectation;
    });
  });

  group('WalletBloc', () {
    test('loads, debits and refreshes the wallet', () async {
      final repository = _WalletTestRepository();
      final bloc = WalletBloc(
        getWallet: GetWallet(repository),
        refreshWallet: RefreshWallet(repository),
      );
      addTearDown(bloc.close);

      final loaded = expectLater(
        bloc.stream,
        emitsInOrder([isA<WalletLoading>(), isA<WalletLoaded>()]),
      );
      bloc.add(const WalletLoadRequested());
      await loaded;

      final debited = expectLater(
        bloc.stream,
        emits(
          isA<WalletLoaded>().having(
            (state) => state.wallet.balance.amount,
            'balance',
            47500,
          ),
        ),
      );
      bloc.add(WalletDebitApplied(Money.xof(2500)));
      await debited;

      repository.wallet = repository.wallet.copyWith(balance: Money.xof(60000));
      final refreshed = expectLater(
        bloc.stream,
        emits(
          isA<WalletLoaded>().having(
            (state) => state.wallet.balance.amount,
            'balance',
            60000,
          ),
        ),
      );
      bloc.add(const WalletRefreshRequested());
      await refreshed;
    });

    test('emits failures from load and refresh operations', () async {
      final repository = _WalletTestRepository()..error = StateError('offline');
      final bloc = WalletBloc(
        getWallet: GetWallet(repository),
        refreshWallet: RefreshWallet(repository),
      );
      addTearDown(bloc.close);

      final loadFailure = expectLater(
        bloc.stream,
        emitsInOrder([isA<WalletLoading>(), isA<WalletFailure>()]),
      );
      bloc.add(const WalletLoadRequested());
      await loadFailure;

      repository.error = StateError('timeout');
      final refreshFailure = expectLater(
        bloc.stream,
        emits(isA<WalletFailure>()),
      );
      bloc.add(const WalletRefreshRequested());
      await refreshFailure;
    });
  });

  group('TransactionBloc', () {
    test('paginates, searches, clears and registers transactions', () async {
      final repository = _TransactionTestRepository(
        List.generate(6, _transactionAt),
      );
      final bloc = TransactionBloc(
        getTransactions: GetTransactions(repository),
        filterTransactions: const FilterTransactions(),
      );
      addTearDown(bloc.close);

      bloc.add(const TransactionsLoadRequested());
      final initial =
          await bloc.stream.firstWhere((state) => state is TransactionLoaded)
              as TransactionLoaded;
      expect(initial.visibleTransactions, hasLength(4));
      expect(initial.hasMore, isTrue);

      bloc.add(const TransactionsLoadMoreRequested());
      final paged =
          await bloc.stream.firstWhere(
                (state) => state is TransactionLoaded && state.hasMore == false,
              )
              as TransactionLoaded;
      expect(paged.visibleTransactions, hasLength(6));

      bloc.add(const SearchQueryChanged('Merchant 2'));
      final searched =
          await bloc.stream.firstWhere(
                (state) =>
                    state is TransactionLoaded && state.searchQuery != null,
              )
              as TransactionLoaded;
      expect(searched.filteredTransactions.single.label, 'Merchant 2');

      bloc.add(const SearchCleared());
      await bloc.stream.firstWhere(
        (state) => state is TransactionLoaded && state.searchQuery == null,
      );

      final local = _transactionAt(99);
      bloc.add(LocalTransactionRegistered(local));
      final updated =
          await bloc.stream.firstWhere(
                (state) =>
                    state is TransactionLoaded &&
                    state.allTransactions.first.id == local.id,
              )
              as TransactionLoaded;
      expect(updated.allTransactions, hasLength(7));
    });

    test('emits empty and failure states', () async {
      final emptyRepository = _TransactionTestRepository(const []);
      final emptyBloc = TransactionBloc(
        getTransactions: GetTransactions(emptyRepository),
        filterTransactions: const FilterTransactions(),
      );
      addTearDown(emptyBloc.close);
      emptyBloc.add(const TransactionsLoadRequested());
      expect(
        await emptyBloc.stream.firstWhere((s) => s is TransactionEmpty),
        isA<TransactionEmpty>(),
      );

      final failingRepository = _TransactionTestRepository(const [])
        ..error = StateError('offline');
      final failureBloc = TransactionBloc(
        getTransactions: GetTransactions(failingRepository),
        filterTransactions: const FilterTransactions(),
      );
      addTearDown(failureBloc.close);
      failureBloc.add(const TransactionsLoadRequested());
      expect(
        await failureBloc.stream.firstWhere((s) => s is TransactionFailure),
        isA<TransactionFailure>(),
      );
    });
  });

  test('PaymentBloc surfaces repository failures', () async {
    final repository = _FailingPaymentRepository();
    final bloc = PaymentBloc(
      initiatePayment: InitiatePayment(repository),
      confirmPayment: ConfirmPayment(repository),
    );
    addTearDown(bloc.close);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder([isA<PaymentProcessing>(), isA<PaymentFailure>()]),
    );
    bloc.add(
      QrScanned(
        qrToken: 'token',
        merchantName: 'Merchant',
        amount: Money.xof(1000),
      ),
    );
    await expectation;
  });
}

Transaction _transactionAt(int index) => Transaction(
  id: 'tx-$index',
  type: TransactionType.debit,
  amount: Money.xof(1000 + index),
  label: 'Merchant $index',
  date: DateTime.now().subtract(Duration(days: index)),
  status: TransactionStatus.validated,
);

class _ProfileAuthRepository implements AuthRepository {
  (String, String)? changedPin;
  Object? changeError;
  Object? logoutError;

  @override
  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (changeError case final error?) throw error;
    changedPin = (currentPin, newPin);
  }

  @override
  Future<void> logout() async {
    if (logoutError case final error?) throw error;
  }

  @override
  Future<String> refreshToken(String refreshToken) async => refreshToken;

  @override
  Future<void> resetPin({
    required PhoneNumber phone,
    required String verificationCode,
    required String newPin,
  }) async {}

  @override
  Future<void> sendOtp(PhoneNumber phone) async {}

  @override
  Future<User> verifyOtp({
    required PhoneNumber phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async => User(id: 'user', name: 'Test', phone: phone);
}

class _WalletTestRepository implements WalletRepository {
  Wallet wallet = Wallet(
    walletId: 'wallet-1',
    balance: Money.xof(50000),
    status: WalletStatus.active,
    lastUpdated: DateTime(2030),
  );
  Object? error;

  @override
  Future<Wallet> getWallet() async {
    if (error case final value?) throw value;
    return wallet;
  }

  @override
  Future<Wallet> refreshWallet() => getWallet();

  @override
  Future<Wallet> updateBalanceAfterPayment({
    required Money amount,
    required bool isCredit,
  }) async => wallet;
}

class _TransactionTestRepository implements TransactionRepository {
  _TransactionTestRepository(this.transactions);

  final List<Transaction> transactions;
  Object? error;

  @override
  Future<List<Transaction>> getTransactions() async {
    if (error case final value?) throw value;
    return transactions;
  }

  @override
  Future<Transaction?> getTransactionById(String id) async => null;

  @override
  Future<List<Transaction>> getFilteredTransactions({
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
  }) async => transactions;
}

class _FailingPaymentRepository implements PaymentRepository {
  @override
  Future<PaymentInitiation> initiatePayment({
    required String qrToken,
    required Money amount,
  }) async => throw StateError('offline');

  @override
  Future<Transaction> confirmPayment({
    required String paymentToken,
    required String pin,
  }) async => throw StateError('offline');

  @override
  Future<void> cancelPayment(String paymentId) async {}
}
