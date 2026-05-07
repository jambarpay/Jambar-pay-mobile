import '../../../domain/value_objects/money.dart';

class MoneyDto {
  final double amount;
  final String currency;

  const MoneyDto({required this.amount, required this.currency});

  factory MoneyDto.fromJson(Map<String, dynamic> json) {
    return MoneyDto(
      amount: (json['montant'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'XOF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'montant': amount,
      'currency': currency,
    };
  }

  Money toDomain() => Money(amount: amount, currency: currency);

  factory MoneyDto.fromDomain(Money money) {
    return MoneyDto(amount: money.amount, currency: money.currency);
  }
}
