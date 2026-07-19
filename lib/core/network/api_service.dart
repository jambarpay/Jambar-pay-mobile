import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_messages.dart';
import 'base_url.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
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
    final headers = <String, String>{'Content-Type': 'application/json'};
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

  Future<dynamic> _decodeBody(http.Response response) async {
    if (response.body.isEmpty) {
      return null;
    }

    try {
      return json.decode(response.body);
    } catch (_) {
      return response.body;
    }
  }

  Future<dynamic> _request(Future<http.Response> future) async {
    try {
      final response = await future;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return await _decodeBody(response);
      }

      if (response.body.contains('twilio') ||
          response.body.contains('unverified')) {
        throw ApiException(
          ApiMessages.smsError,
          statusCode: response.statusCode,
        );
      }

      throw ApiException(
        ApiMessages.http('HTTP', response.statusCode),
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw ApiException('${ApiMessages.network}: timeout');
    } on ApiException {
      rethrow;
    } on http.ClientException catch (error) {
      throw ApiException('${ApiMessages.network}: ${error.message}');
    }
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = _buildUri(endpoint, queryParameters);
    final merged = {..._defaultHeaders, ...?headers};
    return _request(_client.get(uri, headers: merged).timeout(timeout));
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = _buildUri(endpoint);
    final merged = {..._defaultHeaders, ...?headers};
    return _request(
      _client
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
      _client
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
      _client
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
    return _request(_client.delete(uri, headers: merged).timeout(timeout));
  }

  void dispose() => _client.close();
}
