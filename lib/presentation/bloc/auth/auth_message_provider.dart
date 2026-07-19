abstract class AuthMessageProvider {
  String get phoneTooLong;
  String get invalidPhoneNumber;
  String incorrectSecretCode(int remainingAttempts);
  String retryInDuration(Duration duration);
  String get youCanRetryNow;
}
