import '../../../domain/entities/transaction.dart';
import 'money_dto.dart';

class TransactionDto {
  final String id;
  final String type;
  final MoneyDto amount;
  final String label;
  final String date;
  final String status;

  const TransactionDto({
    required this.id,
    required this.type,
    required this.amount,
    required this.label,
    required this.date,
    required this.status,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'DEBIT',
      amount: MoneyDto.fromJson(json['montant'] as Map<String, dynamic>? ?? {}),
      label: json['label']?.toString() ?? json['merchantName']?.toString() ?? '',
      date: json['createdAt']?.toString() ?? json['date']?.toString() ?? '',
      status: json['statut']?.toString() ?? json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'montant': amount.toJson(),
      'label': label,
      'date': date,
      'statut': status,
    };
  }

  Transaction toDomain() {
    final txType = type.toUpperCase() == 'CREDIT'
        ? TransactionType.credit
        : TransactionType.debit;
    
    final txStatus = _parseStatus(status);
    final parsedDate = _parseDate(date);
    
    return Transaction(
      id: id,
      type: txType,
      amount: amount.toDomain(),
      label: label,
      date: parsedDate,
      status: txStatus,
    );
  }

  TransactionStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'valide':
      case 'validated':
      case 'success':
        return TransactionStatus.validated;
      case 'en attente':
      case 'pending':
        return TransactionStatus.pending;
      case 'echoue':
      case 'failed':
        return TransactionStatus.failed;
      default:
        return TransactionStatus.pending;
    }
  }

  DateTime _parseDate(String rawDate) {
    final now = DateTime.now();
    final normalized = rawDate.trim().toLowerCase();

    if (normalized.contains("aujourd'hui")) {
      return DateTime(now.year, now.month, now.day);
    }

    if (normalized.contains('hier')) {
      final yesterday = now.subtract(const Duration(days: 1));
      return DateTime(yesterday.year, yesterday.month, yesterday.day);
    }

    try {
      final parts = normalized.split(',').first.trim().split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {
      // fall through
    }

    return DateTime.now();
  }
}
