import 'package:flutter/widgets.dart';
import 'package:jambar_pay_mobile/l10n/app_localizations.dart';

String localizeRelativeDate(BuildContext context, String rawValue) {
  final loc = AppLocalizations.of(context);
  final value = rawValue.trim();

  final todayMatch = RegExp(
    r"^(Aujourd'hui|Today)\s*,\s*(.+)$",
    caseSensitive: false,
  ).firstMatch(value);
  if (todayMatch != null) {
    return loc.todayAt(todayMatch.group(2)!);
  }

  final yesterdayMatch = RegExp(
    r'^(Hier|Yesterday)\s*,\s*(.+)$',
    caseSensitive: false,
  ).firstMatch(value);
  if (yesterdayMatch != null) {
    return loc.yesterdayAt(yesterdayMatch.group(2)!);
  }

  final dateMatch = RegExp(
    r'^(\d{1,2}/\d{1,2}/\d{4})\s*,\s*(.+)$',
  ).firstMatch(value);
  if (dateMatch != null) {
    return loc.dateTime(dateMatch.group(1)!, dateMatch.group(2)!);
  }

  return value;
}

String localizeWalletStatus(BuildContext context, String rawValue) {
  final normalized = rawValue.trim().toLowerCase();
  final loc = AppLocalizations.of(context);

  if (normalized == 'actif' || normalized == 'active') {
    return loc.active;
  }

  return rawValue;
}

String localizeTransactionLabel(BuildContext context, String rawValue) {
  final normalized = rawValue.trim().toLowerCase();

  if (normalized == 'recharge employeur' || normalized == 'employer top-up') {
    return AppLocalizations.of(context).employerTopUp;
  }

  return rawValue;
}
