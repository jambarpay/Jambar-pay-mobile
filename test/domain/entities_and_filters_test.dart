import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/core/config/api_messages.dart';
import 'package:jambar_pay_mobile/core/network/base_url.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/domain/entities/user.dart';
import 'package:jambar_pay_mobile/domain/entities/wallet.dart';
import 'package:jambar_pay_mobile/domain/repositories/payment_repository.dart';
import 'package:jambar_pay_mobile/domain/repositories/transaction_repository.dart';
import 'package:jambar_pay_mobile/domain/use_cases/transactions/filter_transactions.dart';
import 'package:jambar_pay_mobile/domain/use_cases/transactions/get_transaction_by_id.dart';
import 'package:jambar_pay_mobile/domain/value_objects/money.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';

void main() {
  test('domain entities support immutable value-style updates', () {
    final date = DateTime(2030, 1, 1);
    final transaction = Transaction(
      id: 'tx-1',
      type: TransactionType.debit,
      amount: Money.xof(2500),
      label: 'Le FOOD',
      date: date,
      status: TransactionStatus.pending,
    );
    expect(transaction.isCredit, isFalse);
    expect(transaction.signedAmount, Money.xof(-2500));
    final credited = transaction.copyWith(
      type: TransactionType.credit,
      status: TransactionStatus.validated,
    );
    expect(credited.isCredit, isTrue);
    expect(credited.signedAmount, Money.xof(2500));
    expect(transaction.copyWith(), transaction);
    expect(transaction.hashCode, transaction.copyWith().hashCode);

    const user = User(
      id: 'user-1',
      name: 'Awa',
      phone: PhoneNumber('771234567'),
    );
    final renamed = user.copyWith(name: 'Awa Ndiaye', avatarUrl: 'avatar.png');
    expect(renamed.name, 'Awa Ndiaye');
    expect(user.copyWith(), user);
    expect(user.hashCode, user.copyWith().hashCode);

    final wallet = Wallet(
      walletId: 'wallet-1',
      balance: Money.xof(50000),
      status: WalletStatus.active,
      lastUpdated: date,
    );
    final frozen = wallet.copyWith(status: WalletStatus.frozen);
    expect(frozen.status, WalletStatus.frozen);
    expect(wallet.copyWith(), wallet);
    expect(wallet.hashCode, wallet.copyWith().hashCode);

    final initiation = PaymentInitiation(
      token: 'token',
      merchantName: 'Le FOOD',
      amount: Money.xof(2500),
      expiresAt: date,
    );
    final changed = initiation.copyWith(merchantName: 'Chez Binta');
    expect(changed.token, 'token');
    expect(changed.merchantName, 'Chez Binta');
  });

  group('FilterTransactions', () {
    final filter = const FilterTransactions();
    final now = DateTime.now();
    late List<Transaction> transactions;

    setUp(() {
      transactions = [
        _transaction('today', 'Le FOOD', now, 1000),
        _transaction(
          'yesterday',
          'Keur Delice',
          now.subtract(const Duration(days: 1)),
          2500,
        ),
        _transaction(
          'old',
          'Ancien restaurant',
          now.subtract(const Duration(days: 40)),
          5000,
        ),
      ];
    });

    test('filters today, the current week and the current month', () {
      expect(
        filter(transactions: transactions, filter: 'today').map((tx) => tx.id),
        ['today'],
      );
      expect(
        filter(transactions: transactions, filter: 'thisWeek'),
        contains(transactions.first),
      );
      expect(
        filter(transactions: transactions, filter: 'thisMonth'),
        contains(transactions.first),
      );
      expect(filter(transactions: transactions, filter: 'all'), transactions);
    });

    test('searches labels, statuses, amounts and dates', () {
      expect(filter(transactions: transactions, filter: 'all', query: 'food'), [
        transactions.first,
      ]);
      expect(
        filter(transactions: transactions, filter: 'all', query: '-1 000'),
        [transactions.first],
      );
      expect(
        filter(transactions: transactions, filter: 'all', query: 'validated'),
        hasLength(3),
      );
      final dateQuery = '${now.day}/${now.month}/${now.year}';
      expect(
        filter(transactions: transactions, filter: 'all', query: dateQuery),
        contains(transactions.first),
      );
    });
  });

  test('GetTransactionById delegates to its repository', () async {
    final repository = _TransactionLookupRepository();
    final transaction = await GetTransactionById(repository)('tx-1');
    expect(repository.requestedId, 'tx-1');
    expect(transaction?.id, 'tx-1');
  });

  test('API endpoint and message helpers expose stable contracts', () {
    expect(BaseUrl.comptes(), '/comptes');
    expect(BaseUrl.comptes('1'), '/comptes/1');
    expect(BaseUrl.comptesByPhone('77'), '/comptes/phone/77');
    expect(BaseUrl.comptesTransfert(), '/comptes/transfert');
    expect(BaseUrl.comptesPayer(), '/comptes/payer');
    expect(BaseUrl.comptesSolde(), '/comptes/solde');
    expect(BaseUrl.comptesQr(), '/comptes/qr');
    expect(BaseUrl.comptesDashboard(), '/comptes/dashboard');
    expect(BaseUrl.transactions(), '/transactions');
    expect(BaseUrl.restaurants(), '/restaurants');
    expect(BaseUrl.utilisateursLogin(), '/utilisateurs/login');
    expect(BaseUrl.wallet(), '/wallet');
    expect(BaseUrl.walletUpdate(), '/wallet/update');
    expect(ApiMessages.http('API', 500), 'API error: 500');
    expect(ApiMessages.network, isNotEmpty);
  });
}

Transaction _transaction(String id, String label, DateTime date, int amount) =>
    Transaction(
      id: id,
      type: TransactionType.debit,
      amount: Money.xof(amount),
      label: label,
      date: date,
      status: TransactionStatus.validated,
    );

class _TransactionLookupRepository implements TransactionRepository {
  String? requestedId;

  @override
  Future<Transaction?> getTransactionById(String id) async {
    requestedId = id;
    return _transaction(id, 'Merchant', DateTime(2030), 1000);
  }

  @override
  Future<List<Transaction>> getTransactions() async => const [];

  @override
  Future<List<Transaction>> getFilteredTransactions({
    TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
    TransactionStatus? status,
  }) async => const [];
}
