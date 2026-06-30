import 'dart:async';
import 'package:http/http.dart' as http;
import 'ApiService.dart';

class MockApiService extends ApiService {
  late final Map<String, dynamic> _mockResponses = _buildMockResponses();

  MockApiService({String baseUrl = ''}) : super(baseUrl: baseUrl);

  Map<String, dynamic> _buildMockResponses() {
    final now = DateTime.now();

    DateTime atTime(DateTime date, int hour, int minute) {
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    final today = now;
    final yesterday = now.subtract(const Duration(days: 1));

    return {
      '/utilisateurs/register': {'success': true, 'message': 'SMS envoyé'},
      '/utilisateurs/verify-otp': {
        'token': 'mock_token_12345',
        'refreshToken': 'mock_refresh_token',
        'user': {'id': '123', 'phone': '777453164', 'name': 'Abdoulaye Diallo'},
      },
      '/wallet': {'balance': 50000.0, 'currency': 'CFA'},
      '/transactions': [
        {
          '_id': 'trx_1',
          'type': 'DEBIT',
          'montant': {'montant': 3500.0, 'currency': 'XOF'},
          'label': 'Le FOOD',
          'createdAt': atTime(today, 13, 22).toIso8601String(),
          'statut': 'valide',
        },
        {
          '_id': 'trx_2',
          'type': 'DEBIT',
          'montant': {'montant': 2500.0, 'currency': 'XOF'},
          'label': 'Keur Delice',
          'createdAt': atTime(today, 9, 10).toIso8601String(),
          'statut': 'valide',
        },
        {
          '_id': 'trx_3',
          'type': 'CREDIT',
          'montant': {'montant': 15000.0, 'currency': 'XOF'},
          'label': 'Recharge employeur',
          'createdAt': atTime(yesterday, 18, 40).toIso8601String(),
          'statut': 'valide',
        },
        {
          '_id': 'trx_4',
          'type': 'DEBIT',
          'montant': {'montant': 4200.0, 'currency': 'XOF'},
          'label': 'Chez Binta',
          'createdAt': now
              .subtract(const Duration(days: 2, hours: 4))
              .toIso8601String(),
          'statut': 'valide',
        },
        {
          '_id': 'trx_5',
          'type': 'DEBIT',
          'montant': {'montant': 1800.0, 'currency': 'XOF'},
          'label': 'Express Cafe',
          'createdAt': now
              .subtract(const Duration(days: 3, hours: 8))
              .toIso8601String(),
          'statut': 'en attente',
        },
        {
          '_id': 'trx_6',
          'type': 'DEBIT',
          'montant': {'montant': 3900.0, 'currency': 'XOF'},
          'label': 'Yassa Rapide',
          'createdAt': now
              .subtract(const Duration(days: 4, hours: 3))
              .toIso8601String(),
          'statut': 'valide',
        },
      ],
      '/utilisateurs/refresh': {
        'token': 'mock_new_token',
        'refreshToken': 'mock_refresh_token',
      },
      '/logout': {'success': true},
    };
  }

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    print('🧪 [MockApiService] GET $endpoint');
    await Future.delayed(Duration(milliseconds: 500)); // Simulate delay

    final mockResponse = _mockResponses[endpoint];
    if (mockResponse != null) {
      return mockResponse;
    }

    throw Exception('Mock response not found for: $endpoint');
  }

  @override
  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    print('🧪 [MockApiService] POST $endpoint - Data: $data');
    await Future.delayed(Duration(milliseconds: 800)); // Simulate delay

    final mockResponse = _mockResponses[endpoint];
    if (mockResponse != null) {
      return mockResponse;
    }

    throw Exception('Mock response not found for: $endpoint');
  }

  @override
  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    print('🧪 [MockApiService] PUT $endpoint - Data: $data');
    await Future.delayed(Duration(milliseconds: 500));

    final mockResponse = _mockResponses[endpoint];
    if (mockResponse != null) {
      return mockResponse;
    }

    throw Exception('Mock response not found for: $endpoint');
  }

  @override
  Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    print('🧪 [MockApiService] PATCH $endpoint - Data: $data');
    await Future.delayed(Duration(milliseconds: 500));

    final mockResponse = _mockResponses[endpoint];
    if (mockResponse != null) {
      return mockResponse;
    }

    throw Exception('Mock response not found for: $endpoint');
  }

  @override
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    print('🧪 [MockApiService] DELETE $endpoint');
    await Future.delayed(Duration(milliseconds: 500));

    final mockResponse = _mockResponses[endpoint];
    if (mockResponse != null) {
      return mockResponse;
    }

    throw Exception('Mock response not found for: $endpoint');
  }

  void addMockResponse(String endpoint, Map<String, dynamic> response) {
    _mockResponses[endpoint] = response;
  }
}
