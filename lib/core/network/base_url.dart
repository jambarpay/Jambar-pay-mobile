abstract final class BaseUrl {
  static const String defaultApiBase = 'https://api.jambaarpay.com';
  static const String apiPrefix = '/api/v1';

  static String get base =>
      const String.fromEnvironment('API_BASE', defaultValue: defaultApiBase);

  static String transactions([String? id]) => id == null
      ? '$apiPrefix/payments/transactions'
      : '$apiPrefix/payments/transactions/$id';
  static String homeSummary() => '$apiPrefix/mobile/home-summary';
  static String restaurants() => '$apiPrefix/restaurants';
  static String authRegisterStart() => '$apiPrefix/auth/register/start';
  static String authRegisterVerify() => '$apiPrefix/auth/register/verify';
  static String authRegisterResend() => '$apiPrefix/auth/register/resend';
  static String authLogout() => '$apiPrefix/auth/logout';
  static String authDeleteAccount() => '$apiPrefix/auth/account';
  static String authEmployeeLogin() => '$apiPrefix/auth/employee/login';
  static String walletByOwner(String ownerId) =>'$apiPrefix/wallets/owners/$ownerId';
  static String walletTopUp(String walletId) =>'$apiPrefix/wallets/$walletId/top-up';
  static String payWithQr() => '$apiPrefix/payments/qr';
  static String waveCheckoutLinks() => '$apiPrefix/wave/checkout-links';
  static String employeeQr() => '$apiPrefix/qrs/employee';
  static String qrImage(String reference) => '$apiPrefix/qrs/$reference/image';
}
