import '../../../core/network/api_service.dart';
import '../../../core/network/base_url.dart';
import '../../../core/storage/secure_session_storage.dart';

class AuthRemoteDataSource {
  final ApiService apiService;
  final SecureSessionStorage sessionStorage;

  AuthRemoteDataSource(this.apiService, this.sessionStorage);

  Future<void> sendOtp(
    String phone, {
    String firstName = 'Utilisateur',
    String lastName = 'Jambaar Pay',
  }) async {
    // Employees are provisioned by their enterprise. The mobile app only
    // requests a new OTP for an already-provisioned employee account.
    await apiService.post(BaseUrl.authRegisterResend(), {
      'phoneNumber': phone,
    });
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? pin,
    String? pinConfirmation,
  }) async {
    if (pin != null && !RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const ApiException('Le code PIN doit contenir 4 chiffres.');
    }
    if (pinConfirmation != null &&
        !RegExp(r'^\d{4}$').hasMatch(pinConfirmation)) {
      throw const ApiException('La confirmation du PIN doit contenir 4 chiffres.');
    }
    if ((pin == null) != (pinConfirmation == null) ||
        (pin != null && pin != pinConfirmation)) {
      throw const ApiException('Les deux codes PIN doivent être identiques.');
    }
    final response = await apiService.post(BaseUrl.authRegisterVerify(), {
      'phoneNumber': phone,
      'otp': otp,
      if (pin != null) 'pin': pin,
      if (pinConfirmation != null) 'pinConfirmation': pinConfirmation,
    });
    if (response is! Map) {
      throw Exception('Invalid response format');
    }
    final envelope = Map<String, dynamic>.from(response);
    final responseMap = envelope['data'] is Map
        ? Map<String, dynamic>.from(envelope['data'] as Map)
        : envelope;
    final accessToken = responseMap['token']?.toString();
    if (accessToken != null && accessToken.isNotEmpty) {
      apiService.setToken(accessToken);
      await sessionStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: responseMap['refreshToken']?.toString(),
      );
    }

    final user = responseMap['user'];
    if (user is Map) {
      return Map<String, dynamic>.from(user);
    }
    if (responseMap.containsKey('user')) {
      throw const ApiException('Invalid user response format');
    }

    // OTP verification provisions the PIN; obtain the normal employee JWT
    // only after the PIN has been persisted and confirmed by user-service.
    if (pin != null && pinConfirmation == pin) {
      final loginResponse = await apiService.post(BaseUrl.authEmployeeLogin(), {
        'phoneNumber': phone,
        'pin': pin,
      });
      if (loginResponse is Map) {
        final loginEnvelope = Map<String, dynamic>.from(loginResponse);
        final loginData = loginEnvelope['data'] is Map
            ? Map<String, dynamic>.from(loginEnvelope['data'] as Map)
            : loginEnvelope;
        final loginToken = loginData['accessToken']?.toString();
        if (loginToken != null && loginToken.isNotEmpty) {
          apiService.setToken(loginToken);
          await sessionStorage.saveTokens(accessToken: loginToken);
        }
      }
    }
    return responseMap;
  }

  Future<String> refreshToken(String refreshToken) async {
    throw const ApiException(
      'Le backend actuel ne fournit pas de renouvellement de session.',
    );
  }

  Future<void> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    throw const ApiException(
      'Le backend actuel ne fournit pas de changement de code secret.',
    );
  }

  Future<void> resetPin({
    required String phone,
    required String verificationCode,
    required String newPin,
  }) async {
    throw const ApiException(
      'Le backend actuel ne fournit pas de réinitialisation du code secret.',
    );
  }

  Future<void> logout() async {
    try {
      if (apiService.token != null && apiService.token!.isNotEmpty) {
        await apiService.post(BaseUrl.authLogout(), const {});
      }
    } finally {
      apiService.setToken(null);
      await sessionStorage.clear();
    }
  }
}
