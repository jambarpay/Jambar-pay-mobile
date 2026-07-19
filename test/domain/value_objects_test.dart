import 'package:flutter_test/flutter_test.dart';
import 'package:jambar_pay_mobile/domain/value_objects/money.dart';
import 'package:jambar_pay_mobile/domain/value_objects/phone_number.dart';

void main() {
  group('PhoneNumber', () {
    test('accepts supported Senegalese mobile prefixes', () {
      for (final prefix in ['70', '75', '76', '77', '78']) {
        expect(PhoneNumber('${prefix}1234567').isValid, isTrue);
      }
    });

    test('normalizes and formats presentation characters', () {
      const phone = PhoneNumber('77-123 45 67');

      expect(phone.digits, '771234567');
      expect(phone.formatted, '77 123 45 67');
    });

    test('rejects invalid prefixes and lengths', () {
      expect(const PhoneNumber('331234567').isValid, isFalse);
      expect(const PhoneNumber('77123456').isValid, isFalse);
    });
  });

  group('Money', () {
    test('formats XOF amounts and preserves the sign', () {
      expect(Money.xof(12500).formatted, '12 500 Fcfa');
      expect(Money.xof(-12500).formatted, '-12 500 Fcfa');
    });

    test('adds and subtracts amounts of the same currency', () {
      expect((Money.xof(5000) - Money.xof(1250)).amount, 3750);
      expect((Money.xof(5000) + Money.xof(1250)).amount, 6250);
    });

    test('rejects arithmetic across different currencies in release too', () {
      expect(
        () => Money.xof(5000) + Money(amount: 10, currency: 'EUR'),
        throwsArgumentError,
      );
    });
  });
}
