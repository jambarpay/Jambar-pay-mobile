/// Senegalese mobile phone number represented without presentation concerns.
class PhoneNumber {
  const PhoneNumber(this.value);

  final String value;

  String get digits => value.replaceAll(RegExp(r'\D'), '');

  bool get isValid => RegExp(r'^(7[05678])\d{7}$').hasMatch(digits);

  String get formatted {
    if (digits.length != 9) return value;

    return '${digits.substring(0, 2)} ${digits.substring(2, 5)} '
        '${digits.substring(5, 7)} ${digits.substring(7, 9)}';
  }

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PhoneNumber && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
