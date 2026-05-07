class Money {
  final double amount;
  final String currency;

  const Money({
    required this.amount,
    required this.currency,
  });

  factory Money.xof(double amount) => Money(amount: amount, currency: 'XOF');

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
    assert(currency == other.currency, 'Cannot add different currencies');
    return Money(amount: amount + other.amount, currency: currency);
  }

  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract different currencies');
    return Money(amount: amount - other.amount, currency: currency);
  }

  Money copyWith({
    double? amount,
    String? currency,
  }) {
    return Money(
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
    );
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
