/// Value Object for phone numbers with validation.
class PhoneNumber {
  final String value;

  const PhoneNumber(this.value);

  bool get isValid {
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    return digits.length == 9 && digits.startsWith(RegExp(r'[7-8]'));
  }

  String get formatted {
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    if (digits.length != 9) return value;
    
    return '${digits.substring(0, 2)} ${digits.substring(2, 5)} '
           '${digits.substring(5, 7)} ${digits.substring(7, 9)}';
  }

  String get digits => value.replaceAll(RegExp(r'\s+'), '');

  @override
  String toString() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumber && value == other.value;

  @override
  int get hashCode => value.hashCode;
}
