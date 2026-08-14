import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/core/network/base_url.dart';
import 'package:jambar_pay_mobile/core/storage/secure_session_storage.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/wallet_remote_datasource.dart';
import 'package:jambar_pay_mobile/core/session/current_user_session.dart';

void main() {
  group('AuthRemoteDataSource', () {
    test('persists tokens and extracts the authenticated user', () async {
      final api = _RecordingApiService()
        ..postResponses[BaseUrl.authRegisterVerify()] = {
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
      expect(api.lastData, {'phoneNumber': '771234567', 'otp': '1234'});
    });

    test('shares a new employee token with every backend client', () async {
      final userApi = _RecordingApiService()
        ..postResponses[BaseUrl.authEmployeeLogin()] = {
          'data': {
            'accessToken': 'fresh-token',
            'profile': {'id': 'employee-1', 'name': 'Salarié Test'},
          },
        };
      final paymentApi = _RecordingApiService()..token = 'stale-token';
      final restaurantApi = _RecordingApiService();
      final source = AuthRemoteDataSource(
        userApi,
        _RecordingSessionStorage(),
        authenticatedClients: [paymentApi, restaurantApi],
      );

      await source.loginWithPin(phone: '782917770', pin: '1501');

      expect(userApi.token, 'fresh-token');
      expect(paymentApi.token, 'fresh-token');
      expect(restaurantApi.token, 'fresh-token');
      expect(userApi.lastIncludeAuthorization, isFalse);
    });

    test('accepts a flat user response and rejects invalid payloads', () async {
      final api = _RecordingApiService();
      final source = AuthRemoteDataSource(api, _RecordingSessionStorage());

      api.postResponses[BaseUrl.authRegisterVerify()] = {
        'id': 'flat-user',
        'phoneNumber': '771234567',
      };
      expect(
        await source.verifyOtp(phone: '771234567', otp: '1234'),
        containsPair('id', 'flat-user'),
      );

      api.postResponses[BaseUrl.authRegisterVerify()] = <String>['invalid'];
      await expectLater(
        source.verifyOtp(phone: '771234567', otp: '1234'),
        throwsA(isA<Exception>()),
      );

      api.postResponses[BaseUrl.authRegisterVerify()] = {'user': 'invalid'};
      await expectLater(
        source.verifyOtp(phone: '771234567', otp: '1234'),
        throwsA(isA<ApiException>()),
      );
    });

    test('reports unsupported backend session refresh', () async {
      final api = _RecordingApiService();
      final storage = _RecordingSessionStorage();
      final source = AuthRemoteDataSource(api, storage);
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
        expect(api.lastEndpoint, BaseUrl.authRegisterResend());
        expect(api.lastData, {'phoneNumber': '771234567'});
        expect(api.lastIncludeAuthorization, isFalse);

        await expectLater(
          source.changePin(currentPin: '1234', newPin: '5678'),
          throwsA(isA<ApiException>()),
        );

        await expectLater(
          source.resetPin(
            phone: '771234567',
            verificationCode: '9876',
            newPin: '5678',
          ),
          throwsA(isA<ApiException>()),
        );

        api.token = 'access';
        await source.logout();
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

    test('maps the backend paginated transaction response', () async {
      final api = _RecordingApiService();
      final source = TransactionRemoteDataSource(api);
      api.getResponses[BaseUrl.transactions()] = {
        'content': [
          {'id': 'tx-1'},
        ],
        'page': 0,
        'size': 50,
        'totalElements': 1,
        'totalPages': 1,
      };

      expect(await source.getTransactions(), hasLength(1));
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
      final session = CurrentUserSession()..setUserId('user-1');
      final source = WalletRemoteDataSource(api, session);
      final wallet = {'id': 'wallet-1', 'balance': 50000, 'currency': 'XOF'};
      api.getResponses[BaseUrl.walletByOwner('user-1')] = wallet;
      api.patchResponses[BaseUrl.walletTopUp('wallet-1')] = wallet;

      expect(await source.getWallet(), wallet);
      expect(
        await source.updateBalanceAfterPayment(amount: 2500, isCredit: true),
        wallet,
      );
      expect(api.lastData, {'amount': 2500, 'currency': 'XOF'});
      expect(await source.refreshWallet(), wallet);
    });

    test('rejects malformed wallet payloads', () async {
      final api = _RecordingApiService();
      final session = CurrentUserSession()..setUserId('user-1');
      final source = WalletRemoteDataSource(api, session);
      api.getResponses[BaseUrl.walletByOwner('user-1')] = <Object>[];

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
  final Map<String, dynamic> patchResponses = {};
  String? lastEndpoint;
  Map<String, dynamic>? lastData;
  Map<String, String>? lastQueryParameters;
  bool? lastIncludeAuthorization;
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
    bool includeAuthorization = true,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    lastEndpoint = endpoint;
    lastData = data;
    lastIncludeAuthorization = includeAuthorization;
    final error = postError;
    if (error != null) throw error;
    return postResponses[endpoint] ?? const <String, dynamic>{};
  }

  @override
  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    lastEndpoint = endpoint;
    lastData = data;
    return patchResponses[endpoint];
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
