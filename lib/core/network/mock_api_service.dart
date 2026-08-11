import 'api_service.dart';
import 'base_url.dart';

final class MockApiService extends ApiService {
  late final Map<String, dynamic> _mockResponses = _buildMockResponses();
  final Map<String, Map<String, dynamic>> _pendingPayments = {};

  MockApiService({String baseUrl = ''}) : super(baseUrl: baseUrl);

  Map<String, dynamic> _buildMockResponses() {
    final now = DateTime.now();

    DateTime atTime(DateTime date, int hour, int minute) {
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    final today = now;
    final yesterday = now.subtract(const Duration(days: 1));

    return {
      BaseUrl.authRegisterStart(): {
        'success': true,
        'message': 'OTP sent',
        'data': {'otpCode': '123456', 'message': 'OTP sent via WhatsApp'},
      },
      BaseUrl.authRegisterVerify(): {
        'success': true,
        'message': 'OTP verified. Account created.',
        'data': {
          'id': '123',
          'phoneNumber': '777453164',
          'firstName': 'Abdoulaye',
          'lastName': 'Diallo',
          'role': 'EMPLOYE',
          'status': 'ACTIVE',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        },
      },
      '/utilisateurs/register': {'success': true, 'message': 'SMS envoyé'},
      '/utilisateurs/verify-otp': {
        'token': 'mock_token_12345',
        'refreshToken': 'mock_refresh_token',
        'user': {'id': '123', 'phone': '777453164', 'name': 'Abdoulaye Diallo'},
      },
      '/wallet': {
        'walletId': 'wallet-test-123',
        'balance': {'amount': 50000.0, 'currency': 'XOF'},
        'status': 'active',
        'lastUpdated': now.toIso8601String(),
      },
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
      '/restaurants': [
        {
          '_id': 'rest_1',
          'name': 'Le FOOD',
          'distanceKm': 0.3,
          'updatedAt': atTime(today, 13, 22).toIso8601String(),
          'isOpen': true,
          'latitude': 14.7165,
          'longitude': -17.4672,
        },
        {
          '_id': 'rest_2',
          'name': 'Keur Delice',
          'distanceKm': 0.2,
          'updatedAt': atTime(today, 11, 5).toIso8601String(),
          'isOpen': true,
          'latitude': 14.7174,
          'longitude': -17.466,
        },
        {
          '_id': 'rest_3',
          'name': 'Chez Binta',
          'distanceKm': 0.4,
          'updatedAt': atTime(yesterday, 12, 15).toIso8601String(),
          'isOpen': false,
          'latitude': 14.7153,
          'longitude': -17.469,
        },
      ],
      '/utilisateurs/refresh': {
        'token': 'mock_new_token',
        'refreshToken': 'mock_refresh_token',
      },
      '/utilisateurs/logout': {'success': true},
      BaseUrl.transactions(): [
        {
          'id': 'trx_1',
          'payerUserId': '123',
          'restaurantId': 'rest_1',
          'restaurantName': 'Le FOOD',
          'qrReference': 'QR-MOCK-1',
          'amount': 3500,
          'currency': 'XOF',
          'type': 'MEAL_PAYMENT',
          'method': 'QR_CODE',
          'status': 'SUCCESS',
          'createdAt': atTime(today, 13, 22).toIso8601String(),
          'completedAt': atTime(today, 13, 22).toIso8601String(),
        },
        {
          'id': 'trx_2',
          'payerUserId': '123',
          'restaurantId': 'rest_2',
          'restaurantName': 'Keur Delice',
          'qrReference': 'QR-MOCK-2',
          'amount': 15000,
          'currency': 'XOF',
          'type': 'WALLET_TOP_UP',
          'method': 'MANUAL',
          'status': 'SUCCESS',
          'createdAt': atTime(yesterday, 18, 40).toIso8601String(),
          'completedAt': atTime(yesterday, 18, 40).toIso8601String(),
        },
        {
          'id': 'trx_3',
          'payerUserId': '123',
          'restaurantId': 'rest_3',
          'restaurantName': 'Chez Binta',
          'qrReference': 'QR-MOCK-3',
          'amount': 4200,
          'currency': 'XOF',
          'type': 'MEAL_PAYMENT',
          'method': 'QR_CODE',
          'status': 'SUCCESS',
          'createdAt': now
              .subtract(const Duration(days: 2, hours: 4))
              .toIso8601String(),
          'completedAt': now
              .subtract(const Duration(days: 2, hours: 4))
              .toIso8601String(),
        },
        {
          'id': 'trx_4',
          'payerUserId': '123',
          'restaurantId': 'rest_4',
          'restaurantName': 'Express Cafe',
          'qrReference': 'QR-MOCK-4',
          'amount': 1800,
          'currency': 'XOF',
          'type': 'MEAL_PAYMENT',
          'method': 'QR_CODE',
          'status': 'PENDING',
          'createdAt': now
              .subtract(const Duration(days: 3, hours: 8))
              .toIso8601String(),
          'completedAt': null,
        },
        {
          'id': 'trx_5',
          'payerUserId': '123',
          'restaurantId': 'rest_5',
          'restaurantName': 'Yassa Rapide',
          'qrReference': 'QR-MOCK-5',
          'amount': 3900,
          'currency': 'XOF',
          'type': 'MEAL_PAYMENT',
          'method': 'QR_CODE',
          'status': 'SUCCESS',
          'createdAt': now
              .subtract(const Duration(days: 4, hours: 3))
              .toIso8601String(),
          'completedAt': now
              .subtract(const Duration(days: 4, hours: 3))
              .toIso8601String(),
        },
        {
          'id': 'trx_6',
          'payerUserId': '123',
          'restaurantId': 'rest_6',
          'restaurantName': 'Restaurant partenaire',
          'qrReference': 'QR-MOCK-6',
          'amount': 2500,
          'currency': 'XOF',
          'type': 'MEAL_PAYMENT',
          'method': 'QR_CODE',
          'status': 'FAILED',
          'failureReason': 'Paiement refusé',
          'createdAt': now
              .subtract(const Duration(days: 5, hours: 2))
              .toIso8601String(),
          'completedAt': null,
        },
      ],
      BaseUrl.restaurants(): [
        {
          'id': 'rest_1',
          'name': 'Le FOOD',
          'registrationNumber': 'SN-DKR-MOCK-1',
          'ownerId': 'owner-1',
          'phoneNumber': '771112233',
          'country': 'Sénégal',
          'city': 'Dakar',
          'district': 'Mermoz',
          'street': 'VDN',
          'status': 'ACTIVE',
          'paymentEligibilityStatus': 'ELIGIBLE',
          'distanceKm': 0.3,
          'updatedAt': atTime(today, 13, 22).toIso8601String(),
          'latitude': 14.7165,
          'longitude': -17.4672,
        },
        {
          'id': 'rest_2',
          'name': 'Keur Delice',
          'registrationNumber': 'SN-DKR-MOCK-2',
          'ownerId': 'owner-2',
          'phoneNumber': '772223344',
          'country': 'Sénégal',
          'city': 'Dakar',
          'district': 'Fann',
          'street': 'Avenue Cheikh Anta Diop',
          'status': 'PENDING',
          'paymentEligibilityStatus': 'NOT_ELIGIBLE',
          'distanceKm': 0.2,
          'updatedAt': atTime(today, 11, 5).toIso8601String(),
          'latitude': 14.7174,
          'longitude': -17.466,
        },
        {
          'id': 'rest_3',
          'name': 'Chez Binta',
          'registrationNumber': 'SN-DKR-MOCK-3',
          'ownerId': 'owner-3',
          'phoneNumber': '773334455',
          'country': 'Sénégal',
          'city': 'Dakar',
          'district': 'Médina',
          'street': 'Rue 11',
          'status': 'SUSPENDED',
          'paymentEligibilityStatus': 'SUSPENDED',
          'distanceKm': 0.4,
          'updatedAt': atTime(yesterday, 12, 15).toIso8601String(),
          'latitude': 14.7153,
          'longitude': -17.469,
        },
      ],
    };
  }

  @override
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    await Future.delayed(Duration(milliseconds: 500)); // Simulate delay

    if (endpoint.startsWith('${BaseUrl.apiPrefix}/wallets/owners/')) {
      return {
        'id': 'wallet-test-123',
        'ownerId': endpoint.split('/').last,
        'walletType': 'EMPLOYEE',
        'balance': 50000,
        'currency': 'XOF',
        'active': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }

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
    await Future.delayed(Duration(milliseconds: 800)); // Simulate delay

    if (endpoint == BaseUrl.authEmployeeLogin()) {
      if (data['pin']?.toString() != '1234') {
        throw const ApiException('Téléphone ou code PIN incorrect.');
      }
      return {
        'success': true,
        'message': 'Authentication successful',
        'data': {
          'accessToken': 'mock_employee_access_token',
          'tokenType': 'Bearer',
          'expiresAt': DateTime.now()
              .add(const Duration(hours: 1))
              .millisecondsSinceEpoch,
          'profile': {
            'id': 'test-user-123',
            'name': 'Abdoulaye Diallo',
            'email': '771234567@employees.jambaarpay.com',
            'role': 'EMPLOYE',
          },
        },
      };
    }

    if (endpoint == BaseUrl.payWithQr()) {
      final now = DateTime.now();
      return {
        'id': 'trx_${now.millisecondsSinceEpoch}',
        'payerUserId': data['payerUserId'],
        'restaurantId': 'rest_1',
        'restaurantName': 'Le FOOD',
        'qrReference': 'QR-MOCK-PAYMENT',
        'amount': data['amount'],
        'currency': data['currency'] ?? 'XOF',
        'type': 'MEAL_PAYMENT',
        'method': 'QR_CODE',
        'status': 'SUCCESS',
        'failureReason': null,
        'createdAt': now.toIso8601String(),
        'completedAt': now.toIso8601String(),
      };
    }

    if (endpoint == BaseUrl.employeeQr()) {
      final now = DateTime.now();
      return {
        'id': 'qr-employee-mock',
        'reference': 'QR-EMP-MOCK',
        'type': 'EMPLOYEE',
        'userId': data['userId'],
        'restaurantId': null,
        'pointOfSaleId': null,
        'qrContent': 'mock-signed-employee-qr-${data['userId']}',
        'status': 'ACTIVE',
        'issuedAt': now.toIso8601String(),
        'expiresAt': now.add(const Duration(minutes: 15)).toIso8601String(),
      };
    }

    if (endpoint == '/comptes/qr') {
      final token = data['qrToken']?.toString() ?? '';
      final amount = (data['amount'] as num?)?.toDouble() ?? 0;
      final payment = {
        'token': token,
        'merchantName': 'Restaurant partenaire',
        'amount': {
          'montant': amount,
          'currency': data['currency']?.toString() ?? 'XOF',
        },
        'expiresAt': DateTime.now()
            .add(const Duration(minutes: 15))
            .toIso8601String(),
      };
      _pendingPayments[token] = payment;
      return payment;
    }

    if (endpoint == '/comptes/payer') {
      if (data['pin']?.toString() != '1234') {
        throw const ApiException('Code secret incorrect.');
      }
      final token = data['paymentToken']?.toString() ?? '';
      final payment = _pendingPayments[token];
      if (payment == null) {
        throw const ApiException('Paiement introuvable ou expiré.');
      }
      final now = DateTime.now();
      return {
        '_id': 'trx_${now.millisecondsSinceEpoch}',
        'type': 'DEBIT',
        'montant': payment['amount'],
        'label': payment['merchantName'],
        'createdAt': now.toIso8601String(),
        'statut': 'valide',
      };
    }

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
