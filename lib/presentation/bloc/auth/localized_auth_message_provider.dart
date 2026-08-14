import 'package:jambar_pay_mobile/l10n/app_localizations.dart';
import 'package:jambar_pay_mobile/language_controller.dart';

import 'auth_message_provider.dart';

class LocalizedAuthMessageProvider implements AuthMessageProvider {
  AppLocalizations get _loc =>
      AppLocalizations(LanguageController.localeNotifier.value);

  @override
  String get phoneTooLong => _loc.phoneTooLong;

  @override
  String get invalidPhoneNumber => _loc.invalidPhoneNumber;

  @override
  String incorrectSecretCode(int remainingAttempts) {
    final attemptLabel = _loc.locale.languageCode == 'fr'
        ? (remainingAttempts > 1 ? 'tentatives' : 'tentative')
        : (remainingAttempts > 1 ? 'attempts' : 'attempt');
    return _loc.incorrectSecretCode(remainingAttempts, attemptLabel);
  }

  @override
  String get loginServiceUnavailable => _loc.loginServiceUnavailable;

  @override
  String retryInDuration(Duration duration) {
    final normalized = duration.isNegative ? Duration.zero : duration;
    final totalSeconds = normalized.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final languageCode = _loc.locale.languageCode;

    if (minutes > 0) {
      if (seconds == 0) {
        if (languageCode == 'fr') {
          final minuteLabel = minutes > 1 ? 'minutes' : 'minute';
          return _loc.retryIn('$minutes $minuteLabel');
        }

        final minuteLabel = minutes > 1 ? 'minutes' : 'minute';
        return _loc.retryIn('$minutes $minuteLabel');
      }

      if (languageCode == 'fr') {
        return _loc.retryIn('$minutes min ${seconds}s');
      }
      return _loc.retryIn(
        '$minutes'
        'm $seconds'
        's',
      );
    }

    return _loc.retryIn(
      '$seconds'
      's',
    );
  }

  @override
  String get youCanRetryNow => _loc.youCanRetryNow;
}
