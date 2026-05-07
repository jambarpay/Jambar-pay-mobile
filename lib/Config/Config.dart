class ApiMessages {
  static const String smsError =
      'Erreur lors de la verification SMS. Veuillez reessayer.';
  static const String network = 'Erreur reseau';

  static String http(String source, int statusCode) {
    return '$source error: $statusCode';
  }
}
