import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Config/Config.dart';
import 'BaseUrl.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;
  String? token;

  ApiService({this.baseUrl = BaseUrl.defaultApiBase, http.Client? client, this.token})
    : _client = client ?? http.Client();

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

      print('ApiService ERROR ${response.statusCode}: ${response.body}');

      if (response.body.contains('twilio') ||
          response.body.contains('unverified')) {
        throw Exception(ApiMessages.smsError);
      }

      throw Exception(ApiMessages.http('HTTP', response.statusCode));
    } on TimeoutException {
      throw Exception('${ApiMessages.network}: timeout');
    } catch (e) {
      throw Exception('${ApiMessages.network}: $e');
    }
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) {
    final uri = _buildUri(endpoint, queryParameters);
    print('ApiService: GET $uri');
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
    print('ApiService: POST $uri');
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
