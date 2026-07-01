import '../../entities/transaction.dart';

class FilterTransactions {
  const FilterTransactions();

  List<Transaction> call({
    required List<Transaction> transactions,
    required String filter,
    String? query,
  }) {
    var result = transactions;
    final now = DateTime.now();

    switch (filter) {
      case 'today':
        result = result.where((transaction) {
          final date = transaction.date;
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        }).toList();
        break;
      case 'thisWeek':
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        result = result.where((transaction) {
          return !transaction.date.isBefore(startOfWeek) &&
              transaction.date.isBefore(endOfWeek);
        }).toList();
        break;
      case 'thisMonth':
        result = result.where((transaction) {
          return transaction.date.year == now.year &&
              transaction.date.month == now.month;
        }).toList();
        break;
      default:
        break;
    }

    if (query != null && query.isNotEmpty) {
      final normalizedQuery = query.toLowerCase();
      result = result.where((transaction) {
        return transaction.label.toLowerCase().contains(normalizedQuery) ||
            transaction.status.toString().toLowerCase().contains(
              normalizedQuery,
            ) ||
            transaction.signedAmount.signedAmount.toLowerCase().contains(
              normalizedQuery,
            ) ||
            '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'
                .contains(normalizedQuery);
      }).toList();
    }

    return result;
  }
}
