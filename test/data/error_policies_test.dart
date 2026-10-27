import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/core/session/current_user_session.dart';
import 'package:jambar_pay_mobile/core/storage/secure_session_storage.dart';
import 'package:jambar_pay_mobile/data/datasources/local/auth_local_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/auth_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/restaurant_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/datasources/remote/wallet_remote_datasource.dart';
import 'package:jambar_pay_mobile/data/models/dto/money_dto.dart';
import 'package:jambar_pay_mobile/data/models/dto/transaction_dto.dart';
import 'package:jambar_pay_mobile/data/repositories/auth_repository_impl.dart';
import 'package:jambar_pay_mobile/data/repositories/wallet_repository_impl.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';

void main() {
  final permanentErrors = <Object>[
    for (final status in [400, 401, 403, 404, 408, 409, 410, 422, 429])
      ApiException('refused', statusCode: status),
    const ApiException('bad JSON', kind: FailureKind.invalidResponse),
    StateError('offline unauthorized 401'),
  ];

  for (final error in [
    ...permanentErrors,
    const ApiException('unavailable', statusCode: 503),
  ]) {
    test(
      'login never uses the cached PIN after ${error is AppFailure ? error.kind.name : error.runtimeType} (${error is AppFailure ? error.statusCode : null})',
      () async {
        final api = _FailingApi();
        addTearDown(api.dispose);
        final storage = _CachedStorage();
        final remote = _FailingAuth(api, storage, error);
        final session = CurrentUserSession();
        final repository = AuthRepositoryImpl(
          remote,
          AuthLocalDataSource(),
          sessionStorage: storage,
          currentUserSession: session,
        );
        await expectLater(
          repository.loginWithPin(
            phone: const PhoneNumber('771234567'),
            pin: '1234',
          ),
          throwsA(same(error)),
        );
        expect(storage.pinChecks, 0);
        expect(session.hasUser, isFalse);
      },
    );
  }

  for (final error in <Object>[
    const ApiException('offline', kind: FailureKind.network),
    TimeoutException('no response'),
  ]) {
    test(
      'real connection failure permits the existing offline PIN check: ${error.runtimeType}',
      () async {
        final api = _FailingApi();
        addTearDown(api.dispose);
        final storage = _CachedStorage();
        final repository = AuthRepositoryImpl(
          _FailingAuth(api, storage, error),
          AuthLocalDataSource(),
          sessionStorage: storage,
        );
        expect(
          (await repository.loginWithPin(
            phone: const PhoneNumber('771234567'),
            pin: '1234',
          )).id,
          'cached-user',
        );
        expect(storage.pinChecks, 1);
        storage.validPin = false;
        await expectLater(
          repository.loginWithPin(
            phone: const PhoneNumber('771234567'),
            pin: '0000',
          ),
          throwsA(same(error)),
        );
      },
    );
  }

  for (final name in ['wallet', 'transactions', 'restaurants']) {
    for (final error in permanentErrors) {
      test(
        '$name does not hide ${error is AppFailure ? '${error.kind.name}/${error.statusCode}' : error.runtimeType} behind cached data',
        () async {
          final api = _FailingApi()..error = error;
          addTearDown(api.dispose);
          final storage = _CachedStorage();
          await expectLater(_load(name, api, storage), throwsA(same(error)));
          expect(storage.cacheReads, 0);
        },
      );
    }
    for (final error in <Object>[
      const ApiException('offline', kind: FailureKind.network),
      const ApiException('timeout', kind: FailureKind.timeout),
      const ApiException('service down', statusCode: 503),
    ]) {
      test(
        '$name retains cached reads for transient ${error.toString()}',
        () async {
          final api = _FailingApi()..error = error;
          addTearDown(api.dispose);
          final storage = _CachedStorage();
          expect(await _load(name, api, storage), isNotNull);
          expect(storage.cacheReads, 1);
        },
      );
    }
    test('$name rejects malformed responses even when cache exists', () async {
      final api = _FailingApi()..response = 'invalid';
      addTearDown(api.dispose);
      final storage = _CachedStorage();
      await expectLater(
        _load(name, api, storage),
        throwsA(
          isA<AppFailure>().having(
            (e) => e.kind,
            'kind',
            FailureKind.invalidResponse,
          ),
        ),
      );
      expect(storage.cacheReads, 0);
    });
  }

  test(
    'missing or non-finite amounts and invalid transaction dates never become successful defaults',
    () {
      for (final amount in [null, '100', double.nan, double.infinity]) {
        expect(
          () => MoneyDto.fromJson({'amount': amount}),
          throwsA(isA<AppFailure>()),
        );
      }
      expect(
        () => TransactionDto.fromJson({
          'id': 't',
          'amount': 100,
          'date': 'not a date',
        }).toDomain(),
        throwsA(isA<AppFailure>()),
      );
      expect(MoneyDto.fromJson({'amount': 0}).amount, 0);
    },
  );

  test(
    'a wallet with a missing balance is rejected rather than displayed as zero',
    () async {
      final api = _FailingApi()..response = {'id': 'wallet'};
      addTearDown(api.dispose);
      final source = WalletRemoteDataSource(
        api,
        CurrentUserSession()..setUserId('user'),
      );
      await expectLater(
        WalletRepositoryImpl(source).getWallet(),
        throwsA(
          isA<AppFailure>().having(
            (e) => e.kind,
            'kind',
            FailureKind.invalidResponse,
          ),
        ),
      );
    },
  );
}

Future<Object?> _load(String name, _FailingApi api, _CachedStorage storage) =>
    switch (name) {
      'wallet' => WalletRemoteDataSource(
        api,
        CurrentUserSession()..setUserId('user'),
        storage,
      ).getWallet(forceRefresh: true),
      'transactions' => TransactionRemoteDataSource(
        api,
        storage,
      ).getTransactions(),
      _ => RestaurantRemoteDataSource(
        api,
        storage,
      ).getRestaurants(forceRefresh: true),
    };

class _FailingApi extends ApiService {
  _FailingApi() : super(baseUrl: 'https://example.test');
  Object? error;
  Object? response;
  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (error case final failure?) throw failure;
    return response;
  }
}

class _FailingAuth extends AuthRemoteDataSource {
  _FailingAuth(super.apiService, super.sessionStorage, this.failure);
  final Object failure;
  @override
  Future<Map<String, dynamic>> loginWithPin({
    required String phone,
    required String pin,
  }) async => throw failure;
}

class _CachedStorage extends SecureSessionStorage {
  int pinChecks = 0;
  int cacheReads = 0;
  bool validPin = true;
  @override
  Future<Map<String, dynamic>?> readUserProfile() async => {
    'id': 'cached-user',
    'name': 'Test',
    'phone': '771234567',
  };
  @override
  Future<bool> verifyPin({required String userId, required String pin}) async {
    pinChecks++;
    return validPin;
  }

  @override
  Future<Map<String, dynamic>?> readWalletCache() async {
    cacheReads++;
    return {'id': 'wallet', 'balance': 1000};
  }

  @override
  Future<List<dynamic>?> readTransactionsCache() async {
    cacheReads++;
    return [
      {'id': 'tx'},
    ];
  }

  @override
  Future<List<dynamic>?> readRestaurantsCache() async {
    cacheReads++;
    return [
      {'id': 'restaurant'},
    ];
  }
}
