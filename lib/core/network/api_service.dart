import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_messages.dart';
import '../../domain/errors/app_failure.dart';
import 'base_url.dart';

export '../../domain/errors/app_failure.dart';

class ApiException extends AppFailure {
  const ApiException(
    super.message, {
    super.statusCode,
    super.kind,
    super.code,
    super.retryAfter,
    super.correlationId,
  });
}

/// Small authenticated JSON client used by remote data sources.
class ApiService {
  final String baseUrl;
  final http.Client _client;
  String? token;

  ApiService({String? baseUrl, http.Client? client, this.token})
    : baseUrl = baseUrl ?? BaseUrl.base,
      _client = client ?? http.Client();

  void setToken(String? t) => token = t;

  Map<String, String> get _defaultHeaders {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
    };
    if (token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParameters]) {
    final cleanedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final trimmedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return Uri.parse(
      '$trimmedBase$cleanedEndpoint',
    ).replace(queryParameters: queryParameters);
  }

  dynamic _decodeBody(http.Response response, {bool strict = false}) {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return json.decode(response.body);
    } on FormatException {
      if (strict && (response.headers['content-type'] ?? '').contains('json')) {
        throw ApiException(
          'Invalid JSON response',
          kind: FailureKind.invalidResponse,
          statusCode: response.statusCode,
          correlationId: response.headers['x-correlation-id'],
        );
      }
      return response.body;
    }
  }

  Future<dynamic> _request(Future<http.Response> Function() send) async {
    try {
      final response = await send();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _decodeBody(response, strict: true);
      }

      final decodedBody = _decodeBody(response);
      final serverMessage = response.statusCode < 500
          ? _serverMessage(decodedBody)
          : null;
      if (response.body.toLowerCase().contains('unverified')) {
        throw ApiException(
          ApiMessages.smsError,
          statusCode: response.statusCode,
          correlationId: response.headers['x-correlation-id'],
        );
      }

      throw ApiException(
        serverMessage ?? ApiMessages.http('HTTP', response.statusCode),
        statusCode: response.statusCode,
        code: decodedBody is Map && decodedBody['code'] is String
            ? decodedBody['code'] as String
            : null,
        retryAfter: _retryAfter(response.headers['retry-after']),
        correlationId: response.headers['x-correlation-id'],
      );
    } on TimeoutException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ApiException('Request timed out', kind: FailureKind.timeout),
        stackTrace,
      );
    } on ApiException {
      rethrow;
    } on http.ClientException catch (_, stackTrace) {
      Error.throwWithStackTrace(
        const ApiException('Network unavailable', kind: FailureKind.network),
        stackTrace,
      );
    }
  }

  String? _serverMessage(dynamic decodedBody) {
    if (decodedBody is Map) {
      final value = decodedBody['message'] ?? decodedBody['detail'];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Duration? _retryAfter(String? value) {
    final seconds = int.tryParse(value ?? '');
    if (seconds == null || seconds < 0) return null;
    return Duration(seconds: seconds);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = _buildUri(endpoint, queryParameters);
    final merged = {..._defaultHeaders, ...?headers};
    return _request(() => _client.get(uri, headers: merged).timeout(timeout));
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    bool includeAuthorization = true,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = _buildUri(endpoint);
    final merged = {..._defaultHeaders, ...?headers};
    if (!includeAuthorization) {
      merged.remove('Authorization');
    }
    return _request(
      () => _client
          .post(uri, headers: merged, body: json.encode(data))
          .timeout(timeout),
    );
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = _buildUri(endpoint);
    final merged = {..._defaultHeaders, ...?headers};
    return _request(
      () => _client
          .put(uri, headers: merged, body: json.encode(data))
          .timeout(timeout),
    );
  }

  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = _buildUri(endpoint);
    final merged = {..._defaultHeaders, ...?headers};
    return _request(
      () => _client
          .patch(uri, headers: merged, body: json.encode(data))
          .timeout(timeout),
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = _buildUri(endpoint);
    final merged = {..._defaultHeaders, ...?headers};
    return _request(
      () => _client.delete(uri, headers: merged).timeout(timeout),
    );
  }

  void dispose() => _client.close();
}
