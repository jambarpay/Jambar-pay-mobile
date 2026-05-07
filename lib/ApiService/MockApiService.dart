import 'dart:async';
import 'package:http/http.dart' as http;
import 'ApiService.dart';

class MockApiService extends ApiService {
  final Map<String, dynamic> _mockResponses = {
    '/utilisateurs/register': {'success': true, 'message': 'SMS envoyé'},
    '/utilisateurs/verify-otp': {
      'token': 'mock_token_12345',
      'refreshToken': 'mock_refresh_token',
      'user': {
        'id': '123',
        'phone': '777453164',
        'name': 'Test User',
      }
    },
    '/wallet': {
      'balance': 50000.0,
      'currency': 'CFA',
    },
    '/utilisateurs/refresh': {
      'token': 'mock_new_token',
      'refreshToken': 'mock_refresh_token',
    },
    '/logout': {'success': true}
  };

  MockApiService({String baseUrl = ''}) : super(baseUrl: baseUrl);

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
