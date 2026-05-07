import '../value_objects/money.dart';

enum TransactionType { debit, credit }

enum TransactionStatus { pending, validated, failed }

class Transaction {
  final String id;
  final TransactionType type;
  final Money amount;
  final String label;
  final DateTime date;
  final TransactionStatus status;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.label,
    required this.date,
    required this.status,
  });

  bool get isCredit => type == TransactionType.credit;
  
  Money get signedAmount => isCredit ? amount : amount.negate;

  Transaction copyWith({
    String? id,
    TransactionType? type,
    Money? amount,
    String? label,
    DateTime? date,
    TransactionStatus? status,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      label: label ?? this.label,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          amount == other.amount &&
          label == other.label &&
          date == other.date &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, type, amount, label, date, status);
}
