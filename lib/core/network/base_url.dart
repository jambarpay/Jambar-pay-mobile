abstract final class BaseUrl {
  static const String defaultApiBase = 'http://149.202.61.30:30088';
  static const String apiPrefix = '/api/v1';

  static String get base =>
      const String.fromEnvironment('API_BASE', defaultValue: defaultApiBase);

  static String get userServiceBase => _serviceBase(
    const String.fromEnvironment('USER_SERVICE_BASE'),
    defaultApiBase,
  );

  static String get restaurantServiceBase => _serviceBase(
    const String.fromEnvironment('RESTAURANT_SERVICE_BASE'),
    defaultApiBase,
  );

  static String get qrServiceBase => _serviceBase(
    const String.fromEnvironment('QR_SERVICE_BASE'),
    defaultApiBase,
  );

  static String get paymentServiceBase => _serviceBase(
    const String.fromEnvironment('PAYMENT_SERVICE_BASE'),
    defaultApiBase,
  );

  static String get walletServiceBase => _serviceBase(
    const String.fromEnvironment('WALLET_SERVICE_BASE'),
    defaultApiBase,
  );

  static String _serviceBase(String serviceBase, String localDefault) {
    final configured = serviceBase.trim();
    if (configured.isNotEmpty) return _trimTrailingSlash(configured);

    const sharedBase = String.fromEnvironment('API_BASE');
    if (sharedBase.trim().isNotEmpty) {
      return _trimTrailingSlash(sharedBase.trim());
    }
    return localDefault;
  }

  static String _trimTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;

  static String transactions([String? id]) => id == null
      ? '$apiPrefix/payments/transactions'
      : '$apiPrefix/payments/transactions/$id';
  static String restaurants() => '$apiPrefix/restaurants';

  static String authRegisterStart() => '$apiPrefix/auth/register/start';
  static String authRegisterVerify() => '$apiPrefix/auth/register/verify';
  static String authRegisterResend() => '$apiPrefix/auth/register/resend';
  static String authLogout() => '$apiPrefix/auth/logout';
  static String authEmployeeLogin() => '$apiPrefix/auth/employee/login';
  static String walletByOwner(String ownerId) =>
      '$apiPrefix/wallets/owners/$ownerId';
  static String walletTopUp(String walletId) =>
      '$apiPrefix/wallets/$walletId/top-up';
  static String payWithQr() => '$apiPrefix/payments/qr';
  static String employeeQr() => '$apiPrefix/qrs/employee';
  static String qrImage(String reference) => '$apiPrefix/qrs/$reference/image';
}
