abstract class AuthMessageProvider {
  String get phoneTooLong;
  String get invalidPhoneNumber;
  String incorrectSecretCode(int remainingAttempts);
  String get loginServiceUnavailable;
  String retryInDuration(Duration duration);
  String get youCanRetryNow;
}
