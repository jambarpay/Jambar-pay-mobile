class PhoneValidation {
  static bool isValidSenegalPhone(String input) {
    final digitsOnly = input.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^(7[05678])[0-9]{7}$').hasMatch(digitsOnly);
  }

  static String? validate(String input) {
    if (input.trim().isEmpty) {
      return 'Le numero de telephone est obligatoire.';
    }

    if (!isValidSenegalPhone(input)) {
      return 'Le numero de telephone est invalide.';
    }

    return null;
  }
}
