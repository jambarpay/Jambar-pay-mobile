import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jambar_pay_mobile/core/config/api_messages.dart';
import 'package:jambar_pay_mobile/core/network/api_service.dart';

void main() {
  group('ApiService', () {
    test('builds authenticated GET requests with query parameters', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'https://example.test/items?page=2');
        expect(request.headers['authorization'], 'Bearer access-token');
        expect(request.headers['accept'], 'application/json');
        expect(request.headers['x-client'], 'mobile');
        return http.Response(jsonEncode({'items': <Object>[]}), 200);
      });
      final service = ApiService(
        baseUrl: 'https://example.test/',
        client: client,
        token: 'access-token',
      );
      addTearDown(service.dispose);

      final response = await service.get(
        'items',
        queryParameters: const {'page': '2'},
        headers: const {'X-Client': 'mobile'},
      );

      expect(response, {'items': <Object>[]});
    });

    test('encodes POST, PUT and PATCH bodies and executes DELETE', () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        return http.Response('{}', 200);
      });
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: client,
      );
      addTearDown(service.dispose);

      await service.post('/resource', {'value': 1});
      await service.put('/resource', {'value': 2});
      await service.patch('/resource', {'value': 3});
      await service.delete('/resource');

      expect(requests.map((request) => request.method), [
        'POST',
        'PUT',
        'PATCH',
        'DELETE',
      ]);
      expect(jsonDecode(requests[0].body), {'value': 1});
      expect(jsonDecode(requests[1].body), {'value': 2});
      expect(jsonDecode(requests[2].body), {'value': 3});
      expect(requests[3].body, isEmpty);
    });

    test('supports empty and non-JSON successful responses', () async {
      var invocation = 0;
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient((request) async {
          invocation += 1;
          return invocation == 1
              ? http.Response('', 204)
              : http.Response('accepted', 200);
        }),
      );
      addTearDown(service.dispose);

      expect(await service.get('/empty'), isNull);
      expect(await service.get('/text'), 'accepted');
    });

    test('surfaces a server message and status code', () async {
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient(
          (request) async =>
              http.Response(jsonEncode({'message': 'Solde insuffisant'}), 422),
        ),
      );
      addTearDown(service.dispose);

      await expectLater(
        service.post('/payment', const {}),
        throwsA(
          isA<ApiException>()
              .having((error) => error.message, 'message', 'Solde insuffisant')
              .having((error) => error.statusCode, 'statusCode', 422),
        ),
      );
    });

    test('hides SMS provider details behind a safe message', () async {
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient(
          (request) async => http.Response('Twilio account unverified', 500),
        ),
      );
      addTearDown(service.dispose);

      await expectLater(
        service.post('/otp', const {}),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            ApiMessages.smsError,
          ),
        ),
      );
    });

    test('maps client errors and timeouts to network exceptions', () async {
      final offlineService = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient(
          (request) async => throw http.ClientException('offline'),
        ),
      );
      addTearDown(offlineService.dispose);

      await expectLater(
        offlineService.get('/resource'),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('offline'),
          ),
        ),
      );

      final timeoutService = ApiService(
        baseUrl: 'https://example.test',
        client: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return http.Response('{}', 200);
        }),
      );
      addTearDown(timeoutService.dispose);

      await expectLater(
        timeoutService.get(
          '/resource',
          timeout: const Duration(milliseconds: 1),
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            contains('timeout'),
          ),
        ),
      );
    });

    test('can clear an authentication token', () async {
      final client = MockClient((request) async {
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response('{}', 200);
      });
      final service = ApiService(
        baseUrl: 'https://example.test',
        client: client,
        token: 'old-token',
      );
      addTearDown(service.dispose);

      service.setToken(null);
      await service.get('/resource');

      expect(const ApiException('failure').toString(), 'failure');
    });
  });
}
