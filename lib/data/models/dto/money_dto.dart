import '../../../domain/value_objects/money.dart';
import '../../../domain/errors/app_failure.dart';

class MoneyDto {
  final int amount;
  final String currency;

  const MoneyDto({required this.amount, required this.currency});

  factory MoneyDto.fromJson(Map<String, dynamic> json) {
    final amount = json['montant'] ?? json['amount'];
    if (amount is! num || !amount.isFinite) {
      throw const AppFailure(
        'Invalid monetary amount',
        kind: FailureKind.invalidResponse,
      );
    }
    return MoneyDto(
      amount: amount.round(),
      currency: json['currency']?.toString() ?? 'XOF',
    );
  }

  Map<String, dynamic> toJson() {
    return {'montant': amount, 'currency': currency};
  }

  Money toDomain() => Money(amount: amount, currency: currency);

  factory MoneyDto.fromDomain(Money money) {
    return MoneyDto(amount: money.amount, currency: money.currency);
  }
}
