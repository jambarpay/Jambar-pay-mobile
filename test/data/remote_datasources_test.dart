import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/core/network/base_url.dart';
import 'package:jambar_pay_mobile/core/storage/secure_session_storage.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/wallet_remote_datasource.dart';

void main() {
  group('AuthRemoteDataSource', () {
    test('persists tokens and extracts the authenticated user', () async {
      final api = _RecordingApiService()
        ..postResponses[BaseUrl.utilisateursVerifyOtp()] = {
          'token': 'access',
          'refreshToken': 'refresh',
          'user': {'id': 'user-1', 'phone': '771234567'},
        };
      final storage = _RecordingSessionStorage();
      final source = AuthRemoteDataSource(api, storage);

      final user = await source.verifyOtp(phone: '771234567', otp: '1234');

      expect(user['id'], 'user-1');
      expect(api.token, 'access');
      expect(storage.savedTokens, ('access', 'refresh'));
      expect(api.lastData, {'phone': '771234567', 'otp': '1234'});
    });

    test('accepts a flat user response and rejects invalid payloads', () async {
      final api = _RecordingApiService();
      final source = AuthRemoteDataSource(api, _RecordingSessionStorage());

      api.postResponses[BaseUrl.utilisateursVerifyOtp()] = {
        'id': 'flat-user',
        'phone': '771234567',
      };
      expect(
        await source.verifyOtp(phone: '771234567', otp: '1234'),
        containsPair('id', 'flat-user'),
      );

      api.postResponses[BaseUrl.utilisateursVerifyOtp()] = <String>['invalid'];
      await expectLater(
        source.verifyOtp(phone: '771234567', otp: '1234'),
        throwsA(isA<Exception>()),
      );

      api.postResponses[BaseUrl.utilisateursVerifyOtp()] = {'user': 'invalid'};
      await expectLater(
        source.verifyOtp(phone: '771234567', otp: '1234'),
        throwsA(isA<ApiException>()),
      );
    });

    test('refreshes tokens and rejects missing access tokens', () async {
      final api = _RecordingApiService();
      final storage = _RecordingSessionStorage();
      final source = AuthRemoteDataSource(api, storage);
      api.postResponses[BaseUrl.utilisateursRefresh()] = {'token': 'new'};

      expect(await source.refreshToken('old-refresh'), 'new');
      expect(storage.savedTokens, ('new', 'old-refresh'));

      api.postResponses[BaseUrl.utilisateursRefresh()] = {'token': ''};
      await expectLater(
        source.refreshToken('old-refresh'),
        throwsA(isA<ApiException>()),
      );
    });

    test(
      'uses the expected authentication contracts and clears logout',
      () async {
        final api = _RecordingApiService();
        final storage = _RecordingSessionStorage();
        final source = AuthRemoteDataSource(api, storage);

        await source.sendOtp('771234567');
        expect(api.lastEndpoint, BaseUrl.utilisateursRegister());
        expect(api.lastData, {'phone': '771234567'});

        await source.changePin(currentPin: '1234', newPin: '5678');
        expect(api.lastEndpoint, BaseUrl.utilisateursChangePin());
        expect(api.lastData, {'currentPin': '1234', 'newPin': '5678'});

        await source.resetPin(
          phone: '771234567',
          verificationCode: '9876',
          newPin: '5678',
        );
        expect(api.lastEndpoint, BaseUrl.utilisateursResetPin());
        expect(api.lastData, {
          'phone': '771234567',
          'otp': '9876',
          'newPin': '5678',
        });

        api.token = 'access';
        api.postError = const ApiException('offline');
        await expectLater(source.logout(), throwsA(isA<ApiException>()));
        expect(api.token, isNull);
        expect(storage.wasCleared, isTrue);
      },
    );
  });

  group('TransactionRemoteDataSource', () {
    test('maps lists, details and filter query parameters', () async {
      final api = _RecordingApiService();
      final source = TransactionRemoteDataSource(api);
      api.getResponses[BaseUrl.transactions()] = <Object>[
        {'id': 'tx-1'},
      ];
      api.getResponses[BaseUrl.transactions('tx-1')] = {'id': 'tx-1'};

      expect(await source.getTransactions(), hasLength(1));
      expect(
        await source.getTransactionById('tx-1'),
        containsPair('id', 'tx-1'),
      );

      await source.getFilteredTransactions(
        type: 'DEBIT',
        startDate: DateTime.utc(2026, 1, 1),
        endDate: DateTime.utc(2026, 1, 31),
        status: 'validated',
      );
      expect(api.lastQueryParameters, {
        'type': 'DEBIT',
        'startDate': '2026-01-01T00:00:00.000Z',
        'endDate': '2026-01-31T00:00:00.000Z',
        'status': 'validated',
      });
    });

    test('returns safe empty values for malformed responses', () async {
      final api = _RecordingApiService();
      final source = TransactionRemoteDataSource(api);
      api.getResponses[BaseUrl.transactions()] = {'invalid': true};
      api.getResponses[BaseUrl.transactions('tx-1')] = <Object>[];

      expect(await source.getTransactions(), isEmpty);
      expect(await source.getTransactionById('tx-1'), isNull);
      expect(await source.getFilteredTransactions(), isEmpty);
      expect(api.lastQueryParameters, isNull);
    });
  });

  group('WalletRemoteDataSource', () {
    test('loads, updates and refreshes wallet payloads', () async {
      final api = _RecordingApiService();
      final source = WalletRemoteDataSource(api);
      final wallet = {
        'walletId': 'wallet-1',
        'balance': {'amount': 50000, 'currency': 'XOF'},
      };
      api.getResponses[BaseUrl.wallet()] = wallet;
      api.postResponses[BaseUrl.walletUpdate()] = wallet;

      expect(await source.getWallet(), wallet);
      expect(
        await source.updateBalanceAfterPayment(amount: 2500, isCredit: false),
        wallet,
      );
      expect(api.lastData, {'amount': 2500, 'type': 'DEBIT'});
      expect(await source.refreshWallet(), wallet);
    });

    test('rejects malformed wallet payloads', () async {
      final api = _RecordingApiService();
      final source = WalletRemoteDataSource(api);
      api.getResponses[BaseUrl.wallet()] = <Object>[];
      api.postResponses[BaseUrl.walletUpdate()] = <Object>[];

      await expectLater(source.getWallet(), throwsA(isA<Exception>()));
      await expectLater(
        source.updateBalanceAfterPayment(amount: 1, isCredit: true),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class _RecordingApiService extends ApiService {
  _RecordingApiService() : super(baseUrl: '');

  final Map<String, dynamic> getResponses = {};
  final Map<String, dynamic> postResponses = {};
  String? lastEndpoint;
  Map<String, dynamic>? lastData;
  Map<String, String>? lastQueryParameters;
  Object? postError;

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    lastEndpoint = endpoint;
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
    lastEndpoint = endpoint;
    lastData = data;
    final error = postError;
    if (error != null) throw error;
    return postResponses[endpoint] ?? const <String, dynamic>{};
  }
}

class _RecordingSessionStorage extends SecureSessionStorage {
  (String, String?)? savedTokens;
  bool wasCleared = false;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    savedTokens = (accessToken, refreshToken);
  }

  @override
  Future<void> clear() async {
    wasCleared = true;
  }
}
