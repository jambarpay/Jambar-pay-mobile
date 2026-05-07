class ChangePin {
  Future<void> call({
    required String currentPin,
    required String newPin,
  }) async {
    if (currentPin.length != 4) {
      throw Exception('Le code secret actuel doit contenir 4 chiffres.');
    }
    if (newPin.length != 4) {
      throw Exception('Le code secret doit contenir 4 chiffres.');
    }
  }
}
