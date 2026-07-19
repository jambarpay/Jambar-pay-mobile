import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/core/network/base_url.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/wallet_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/models/dto/money_dto.dart';
import 'package:jambar_pay_mobile/data/models/dto/transaction_dto.dart';
import 'package:jambar_pay_mobile/data/models/dto/user_dto.dart';
import 'package:jambar_pay_mobile/data/repositories/payment_repository_impl.dart';
import 'package:jambar_pay_mobile/data/repositories/transaction_repository_impl.dart';
import 'package:jambar_pay_mobile/data/repositories/wallet_repository_impl.dart';
import 'package:jambar_pay_mobile/domain/entities/transaction.dart';
import 'package:jambar_pay_mobile/domain/entities/wallet.dart';
import 'package:jambar_pay_mobile/domain/value_objects/money.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';

void main() {
  group('DTO contracts', () {
    test('MoneyDto supports both backend amount field names', () {
      expect(
        MoneyDto.fromJson({'montant': 1200.4, 'currency': 'XOF'}).amount,
        1200,
      );
      expect(MoneyDto.fromJson({'amount': 2400}).amount, 2400);

      final dto = MoneyDto.fromDomain(Money.xof(3500));
      expect(dto.toJson(), {'montant': 3500, 'currency': 'XOF'});
      expect(dto.toDomain(), Money.xof(3500));
    });

    test('UserDto converts API and domain representations', () {
      final dto = UserDto.fromJson({
        '_id': 'user-1',
        'name': 'Awa',
        'phone': '771234567',
        'avatarUrl': 'avatar.png',
      });

      final user = dto.toDomain();
      expect(user.phone, const PhoneNumber('771234567'));
      expect(UserDto.fromDomain(user).toJson(), dto.toJson());
    });

    test('TransactionDto parses amount variants, statuses and dates', () {
      final iso = TransactionDto.fromJson({
        'id': 'tx-1',
        'type': 'CREDIT',
        'amount': {'amount': 1000, 'currency': 'XOF'},
        'merchantName': 'Recharge',
        'date': '2026-01-10T12:30:00.000Z',
        'status': 'success',
      }).toDomain();
      expect(iso.type, TransactionType.credit);
      expect(iso.amount, Money.xof(1000));
      expect(iso.status, TransactionStatus.validated);

      final pending = TransactionDto.fromJson({
        'id': 'tx-2',
        'amount': 2500,
        'date': '10/02/2026, 08h05',
        'status': 'en attente',
      }).toDomain();
      expect(pending.amount, Money.xof(2500));
      expect(pending.status, TransactionStatus.pending);
      expect(pending.date, DateTime(2026, 2, 10, 8, 5));

      final failed = TransactionDto.fromJson({
        'id': 'tx-3',
        'status': 'échec',
      }).toDomain();
      expect(failed.status, TransactionStatus.failed);
    });

    test('TransactionDto serializes its canonical backend shape', () {
      const dto = TransactionDto(
        id: 'tx-1',
        type: 'DEBIT',
        amount: MoneyDto(amount: 500, currency: 'XOF'),
        label: 'Restaurant',
        date: '2026-01-01',
        status: 'pending',
      );

      expect(dto.toJson(), {
        '_id': 'tx-1',
        'type': 'DEBIT',
        'montant': {'montant': 500, 'currency': 'XOF'},
        'label': 'Restaurant',
        'date': '2026-01-01',
        'statut': 'pending',
      });
    });
  });

  group('PaymentRepositoryImpl', () {
    test('initiates, confirms and cancels a payment', () async {
      final api = _RepositoryApiService();
      final repository = PaymentRepositoryImpl(api);
      api.postResponses[BaseUrl.comptesQr()] = {
        'token': 'payment-token',
        'merchantName': 'Le FOOD',
        'amount': {'amount': 3500, 'currency': 'XOF'},
        'expiresAt': '2030-01-01T00:00:00.000Z',
      };

      final initiation = await repository.initiatePayment(
        qrToken: 'qr-token',
        amount: Money.xof(3500),
      );
      expect(initiation.token, 'payment-token');
      expect(initiation.amount, Money.xof(3500));
      expect(api.lastData, {
        'qrToken': 'qr-token',
        'amount': 3500,
        'currency': 'XOF',
      });

      api.postResponses[BaseUrl.comptesPayer()] = {
        'id': 'tx-1',
        'type': 'DEBIT',
        'amount': {'amount': 3500, 'currency': 'XOF'},
        'merchantName': 'Le FOOD',
        'date': '2030-01-01T00:00:00.000Z',
        'status': 'validated',
      };
      final transaction = await repository.confirmPayment(
        paymentToken: initiation.token,
        pin: '1234',
      );
      expect(transaction.id, 'tx-1');
      expect(transaction.amount, Money.xof(3500));

      await repository.cancelPayment('payment-1');
      expect(api.deletedEndpoint, '/comptes/payer/payment-1');
    });

    test('rejects invalid pins and malformed responses', () async {
      final api = _RepositoryApiService();
      final repository = PaymentRepositoryImpl(api);

      await expectLater(
        repository.confirmPayment(paymentToken: 'token', pin: '12'),
        throwsA(isA<ApiException>()),
      );

      api.postResponses[BaseUrl.comptesQr()] = <Object>[];
      await expectLater(
        repository.initiatePayment(qrToken: 'token', amount: Money.xof(1)),
        throwsA(isA<ApiException>()),
      );

      api.postResponses[BaseUrl.comptesPayer()] = <Object>[];
      await expectLater(
        repository.confirmPayment(paymentToken: 'token', pin: '1234'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('TransactionRepositoryImpl', () {
    test(
      'maps lists, details and filters through the domain boundary',
      () async {
        final api = _RepositoryApiService();
        final repository = TransactionRepositoryImpl(
          TransactionRemoteDataSource(api),
        );
        final payload = {
          'id': 'tx-1',
          'type': 'DEBIT',
          'amount': {'amount': 900, 'currency': 'XOF'},
          'date': '2030-01-01T00:00:00.000Z',
          'status': 'pending',
        };
        api.getResponses[BaseUrl.transactions()] = [payload];
        api.getResponses[BaseUrl.transactions('tx-1')] = payload;

        expect((await repository.getTransactions()).single.id, 'tx-1');
        expect((await repository.getTransactionById('tx-1'))?.id, 'tx-1');
        expect(
          await repository.getFilteredTransactions(
            type: TransactionType.debit,
            status: TransactionStatus.validated,
          ),
          hasLength(1),
        );
        expect(api.lastQueryParameters?['type'], 'DEBIT');
        expect(api.lastQueryParameters?['status'], 'validated');
      },
    );

    test('returns null for a missing transaction', () async {
      final api = _RepositoryApiService();
      final repository = TransactionRepositoryImpl(
        TransactionRemoteDataSource(api),
      );
      api.getResponses[BaseUrl.transactions('missing')] = <Object>[];

      expect(await repository.getTransactionById('missing'), isNull);
    });
  });

  group('WalletRepositoryImpl', () {
    test('maps wallet statuses and preserves integer money', () async {
      final api = _RepositoryApiService();
      final repository = WalletRepositoryImpl(WalletRemoteDataSource(api));
      api.getResponses[BaseUrl.wallet()] = _walletJson('active');

      final active = await repository.getWallet();
      expect(active.status, WalletStatus.active);
      expect(active.balance, Money.xof(50000));

      api.postResponses[BaseUrl.walletUpdate()] = _walletJson('frozen');
      final frozen = await repository.updateBalanceAfterPayment(
        amount: Money.xof(2500),
        isCredit: false,
      );
      expect(frozen.status, WalletStatus.frozen);
      expect(api.lastData, {'amount': 2500, 'type': 'DEBIT'});

      api.getResponses[BaseUrl.wallet()] = _walletJson('disabled');
      expect((await repository.refreshWallet()).status, WalletStatus.inactive);
    });
  });
}

Map<String, dynamic> _walletJson(String status) => {
  'walletId': 'wallet-1',
  'balance': {'amount': 50000, 'currency': 'XOF'},
  'status': status,
  'lastUpdated': '2030-01-01T00:00:00.000Z',
};

class _RepositoryApiService extends ApiService {
  _RepositoryApiService() : super(baseUrl: '');

  final Map<String, dynamic> getResponses = {};
  final Map<String, dynamic> postResponses = {};
  Map<String, dynamic>? lastData;
  Map<String, String>? lastQueryParameters;
  String? deletedEndpoint;

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    lastQueryParameters = queryParameters;
    return getResponses[endpoint];
  }

  @override
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    lastData = data;
    return postResponses[endpoint];
  }

  @override
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    deletedEndpoint = endpoint;
    return const <String, dynamic>{};
  }
}
