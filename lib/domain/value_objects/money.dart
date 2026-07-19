class Money {
  final int amount;
  final String currency;

  Money({required num amount, required this.currency})
    : amount = amount.round();

  factory Money.xof(num amount) => Money(amount: amount, currency: 'XOF');

  String get formatted {
    final digits = amount.abs().toStringAsFixed(0);
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[index]);
    }

    final sign = amount.isNegative ? '-' : '';
    return '$sign$buffer Fcfa';
  }

  String get signedAmount {
    final sign = amount >= 0 ? '+' : '';
    return '$sign$formatted';
  }

  Money get negate => Money(amount: -amount, currency: currency);

  Money operator +(Money other) {
    _requireSameCurrency(other);
    return Money(amount: amount + other.amount, currency: currency);
  }

  Money operator -(Money other) {
    _requireSameCurrency(other);
    return Money(amount: amount - other.amount, currency: currency);
  }

  Money copyWith({int? amount, String? currency}) {
    return Money(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
  }

  void _requireSameCurrency(Money other) {
    if (currency != other.currency) {
      throw ArgumentError.value(
        other.currency,
        'other.currency',
        'Cannot operate on $currency and ${other.currency}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, currency);

  @override
  String toString() => 'Money(amount: $amount, currency: $currency)';
}
