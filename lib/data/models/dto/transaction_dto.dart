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
      label:
          json['label']?.toString() ?? json['merchantName']?.toString() ?? '',
      date: json['createdAt']?.toString() ?? json['date']?.toString() ?? '',
      status:
          json['statut']?.toString() ?? json['status']?.toString() ?? 'pending',
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
    final normalized = status.toLowerCase();
    if (normalized.contains('validated') ||
        normalized.contains('valide') ||
        normalized.contains('success')) {
      return TransactionStatus.validated;
    }
    if (normalized.contains('attente') || normalized.contains('pending')) {
      return TransactionStatus.pending;
    }
    if (normalized.contains('failed') ||
        normalized.contains('echoue') ||
        normalized.contains('échec')) {
      return TransactionStatus.failed;
    }
    return TransactionStatus.pending;
  }

  DateTime _parseDate(String rawDate) {
    final now = DateTime.now();
    final normalized = rawDate.trim().toLowerCase();

    final isoDate = DateTime.tryParse(rawDate);
    if (isoDate != null) {
      return isoDate.toLocal();
    }

    if (normalized.contains("aujourd'hui")) {
      return _parseRelativeDate(rawDate, now);
    }

    if (normalized.contains('hier')) {
      final yesterday = now.subtract(const Duration(days: 1));
      return _parseRelativeDate(rawDate, yesterday);
    }

    try {
      final sections = rawDate.split(',');
      final parts = sections.first.trim().split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          final time = sections.length > 1 ? _parseTime(sections[1]) : null;
          return DateTime(year, month, day, time?.hour ?? 0, time?.minute ?? 0);
        }
      }
    } catch (_) {
      // fall through
    }

    return DateTime.now();
  }

  DateTime _parseRelativeDate(String rawDate, DateTime baseDate) {
    final parts = rawDate.split(',');
    final time = parts.length > 1 ? _parseTime(parts[1]) : null;
    return DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
  }

  DateTime? _parseTime(String rawTime) {
    final match = RegExp(r'(\d{1,2})h(\d{1,2})').firstMatch(rawTime);
    if (match == null) {
      return null;
    }

    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null) {
      return null;
    }

    return DateTime(0, 1, 1, hour, minute);
  }
}
