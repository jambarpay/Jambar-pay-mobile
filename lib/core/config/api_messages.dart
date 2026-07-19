abstract final class ApiMessages {
  static const String smsError =
      'Erreur lors de la vérification SMS. Veuillez réessayer.';
  static const String network = 'Erreur réseau';

  static String http(String source, int statusCode) {
    return '$source error: $statusCode';
  }
}
