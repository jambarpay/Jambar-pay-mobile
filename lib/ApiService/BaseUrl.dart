class BaseUrl {
  static const String defaultApiBase = 'https://URL-production';
  
  static String get base => const String.fromEnvironment(
    'API_BASE',
    defaultValue: defaultApiBase,
  );

  static String comptes([String? id]) =>
      id == null ? '/comptes' : '/comptes/$id';
  static String comptesByPhone(String phone) => '/comptes/phone/$phone';
  static String comptesTransfert() => '/comptes/transfert';
  static String comptesPayer() => '/comptes/payer';
  static String comptesSolde() => '/comptes/solde';
  static String comptesQr() => '/comptes/qr';
  static String comptesDashboard() => '/comptes/dashboard';

  static String transactions([String? id]) =>
      id == null ? '/transactions' : '/transactions/$id';

  static String utilisateursRegister() => '/utilisateurs/register';
  static String utilisateursLogin() => '/utilisateurs/login';
  static String utilisateursRefresh() => '/utilisateurs/refresh';
  static String utilisateursVerifyOtp() => '/utilisateurs/verify-otp';
  static String logout() => '/utilisateurs/logout';
  static String wallet() => '/wallet';
  static String walletUpdate() => '/wallet/update';
}
