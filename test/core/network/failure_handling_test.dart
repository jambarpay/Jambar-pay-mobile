import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jambar_pay_mobile/core/errors/failure_handling.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/presentation/utils/failure_messages.dart';

void main() {
  final statusKinds = {
    400: FailureKind.validation,
    401: FailureKind.unauthenticated,
    403: FailureKind.forbidden,
    404: FailureKind.notFound,
    408: FailureKind.timeout,
    409: FailureKind.conflict,
    410: FailureKind.expired,
    422: FailureKind.validation,
    429: FailureKind.rateLimited,
    500: FailureKind.server,
    503: FailureKind.server,
  };
  for (final entry in statusKinds.entries) {
    test(
      'HTTP ${entry.key} keeps its category and metadata without permitting offline login',
      () async {
        final client = ApiService(
          baseUrl: 'https://example.test',
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({
                'code': 'BUSINESS_CODE',
                'message': 'Message métier',
              }),
              entry.key,
              headers: {
                'retry-after': '120',
                'x-correlation-id': 'request-123',
              },
            ),
          ),
        );
        addTearDown(client.dispose);
        await expectLater(
          client.get('/resource'),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'status', entry.key)
                .having((error) => error.kind, 'kind', entry.value)
                .having((error) => error.code, 'code', 'BUSINESS_CODE')
                .having(
                  (error) => error.retryAfter,
                  'retry',
                  const Duration(minutes: 2),
                )
                .having(
                  (error) => error.correlationId,
                  'correlation',
                  'request-123',
                )
                .having(
                  (error) => error.allowsOfflineLogin,
                  'offline login',
                  isFalse,
                ),
          ),
        );
      },
    );
  }

  test('normalization never identifies a failure by words in its message', () {
    expect(
      classifyFailure(StateError('offline timeout unauthorized 401')).kind,
      FailureKind.unexpected,
    );
    expect(
      classifyFailure(TimeoutException('secret')).kind,
      FailureKind.timeout,
    );
    expect(
      classifyFailure(http.ClientException('secret')).kind,
      FailureKind.network,
    );
    expect(
      classifyFailure(const FormatException('secret')).kind,
      FailureKind.invalidResponse,
    );
    const failure = ApiException('denied', statusCode: 403);
    expect(classifyFailure(failure), same(failure));
    expect(canUseCachedData(failure), isFalse);
    expect(
      canUseCachedData(
        const ApiException('offline', kind: FailureKind.network),
      ),
      isTrue,
    );
    expect(
      canUseCachedData(const ApiException('down', statusCode: 503)),
      isTrue,
    );
    expect(
      canUseCachedData(
        const ApiException('bad', kind: FailureKind.invalidResponse),
      ),
      isFalse,
    );
  });

  for (final error in [
    TimeoutException('private transport details'),
    http.ClientException('private transport details'),
  ]) {
    test('transport ${error.runtimeType} retains its original stack', () async {
      final originalStack = StackTrace.fromString('original_transport_frame');
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient(
          (_) => Error.throwWithStackTrace(error, originalStack),
        ),
      );
      addTearDown(service.dispose);
      try {
        await service.get('/resource');
        fail('Expected a transport failure');
      } on ApiException catch (failure, stackTrace) {
        expect(failure.kind, classifyFailure(error).kind);
        expect(failure.message, isNot(contains('private')));
        expect(stackTrace.toString(), contains('original_transport_frame'));
      }
    });
  }

  test(
    'invalid declared JSON is a protocol failure with its correlation ID',
    () async {
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient(
          (_) async => http.Response(
            '{broken',
            200,
            headers: {
              'content-type': 'application/json',
              'x-correlation-id': 'request-json',
            },
          ),
        ),
      );
      addTearDown(service.dispose);
      await expectLater(
        service.get('/resource'),
        throwsA(
          isA<ApiException>()
              .having(
                (error) => error.kind,
                'kind',
                FailureKind.invalidResponse,
              )
              .having(
                (error) => error.correlationId,
                'correlation',
                'request-json',
              ),
        ),
      );
    },
  );

  test(
    'messages are localized, hide technical details and preserve business errors',
    () {
      for (final language in ['fr', 'en']) {
        final loc = AppLocalizations(Locale(language));
        for (final kind in FailureKind.values) {
          final message = failureMessage(
            AppFailure('secret.jwt PIN=1234 stacktrace', kind: kind),
            localizations: loc,
          );
          expect(message, isNotEmpty);
          expect(message, isNot(contains('1234')));
          expect(message, isNot(contains('secret.jwt')));
        }
        expect(
          failureMessage(StateError('SQL password=secret'), localizations: loc),
          loc.errorUnexpected,
        );
        expect(
          failureMessage(
            const ApiException('<html>password=secret</html>', statusCode: 400),
            localizations: loc,
          ),
          loc.errorValidation,
        );
        expect(
          failureMessage(
            const ApiException('Solde insuffisant', statusCode: 422),
            localizations: loc,
          ),
          'Solde insuffisant',
        );
        expect(
          failureMessage(
            const ValidationFailure('pin', code: 'invalid_pin'),
            localizations: loc,
          ),
          loc.errorInvalidPinFormat,
        );
        expect(
          failureMessage(
            const ValidationFailure('otp', code: 'invalid_otp'),
            localizations: loc,
          ),
          loc.errorInvalidOtpFormat,
        );
        expect(
          failureMessage(
            const ValidationFailure('phone', code: 'invalid_phone'),
            localizations: loc,
          ),
          loc.invalidPhoneNumber,
        );
        expect(
          failureMessage(
            const ValidationFailure('mismatch', code: 'pin_mismatch'),
            localizations: loc,
          ),
          loc.codeMismatch,
        );
        expect(
          failureMessage(
            const ApiException('invalid', statusCode: 401),
            context: FailureContext.otp,
            localizations: loc,
          ),
          loc.errorInvalidOtp,
        );
        expect(
          failureMessage(
            const ApiException('network', kind: FailureKind.timeout),
            context: FailureContext.paymentConfirmation,
            localizations: loc,
          ),
          loc.errorPaymentUncertain,
        );
      }
    },
  );

  test(
    'diagnostics omit messages, URLs, credentials and unsafe correlation IDs',
    () {
      const failure = ApiException(
        'Bearer secret PIN=1234 https://host/private',
        statusCode: 503,
        correlationId: 'request-1',
        code: 'secret',
      );
      expect(
        FailureDiagnostics.describe(failure, operation: 'auth.login'),
        'operation=auth.login kind=server status=503 correlation=request-1',
      );
      final unsafe = FailureDiagnostics.describe(
        const ApiException('secret', correlationId: 'Bearer secret\n'),
        operation: 'https://host/private',
      );
      expect(unsafe, 'operation=unknown kind=unexpected');
      final loc = AppLocalizations(const Locale('fr'));
      expect(
        failureMessage(
          failure,
          localizations: loc,
          stackTrace: StackTrace.current,
        ),
        loc.loginServiceUnavailable,
      );
    },
  );
}
