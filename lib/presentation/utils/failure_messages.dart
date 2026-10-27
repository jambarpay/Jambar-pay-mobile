import '../../core/errors/failure_handling.dart';
import '../../domain/errors/app_failure.dart';
import '../../l10n/app_localizations.dart';
import '../../language_controller.dart';

enum FailureContext { general, otp, paymentConfirmation }

String failureMessage(
  Object error, {
  FailureContext context = FailureContext.general,
  AppLocalizations? localizations,
  StackTrace? stackTrace,
  String operation = 'presentation',
}) {
  if (stackTrace != null) {
    FailureDiagnostics.record(error, stackTrace, operation: operation);
  }
  final failure = classifyFailure(error);
  final loc =
      localizations ??
      AppLocalizations(LanguageController.localeNotifier.value);
  final kind = failure.kind;
  // A missing acknowledgement does not prove that a payment was not executed.
  if (context == FailureContext.paymentConfirmation &&
      {
        FailureKind.network,
        FailureKind.timeout,
        FailureKind.server,
        FailureKind.invalidResponse,
        FailureKind.unexpected,
      }.contains(kind)) {
    return loc.errorPaymentUncertain;
  }
  if (context == FailureContext.otp && kind == FailureKind.unauthenticated) {
    return loc.errorInvalidOtp;
  }
  if (kind == FailureKind.validation && failure.statusCode == null) {
    return switch (failure.code) {
      'invalid_phone' => loc.invalidPhoneNumber,
      'invalid_pin' => loc.errorInvalidPinFormat,
      'invalid_otp' => loc.errorInvalidOtpFormat,
      'pin_mismatch' => loc.codeMismatch,
      _ => loc.errorValidation,
    };
  }
  // Only bounded business responses may supply UI text. Infrastructure errors
  // and authentication details always use our localized messages.
  if ({400, 404, 409, 410, 422, 429}.contains(failure.statusCode) &&
      _isBusinessMessage(failure.message)) {
    return failure.message.trim();
  }
  return switch (kind) {
    FailureKind.network => loc.errorNetwork,
    FailureKind.timeout => loc.errorTimeout,
    FailureKind.unauthenticated => loc.errorUnauthenticated,
    FailureKind.forbidden => loc.errorForbidden,
    FailureKind.notFound => loc.errorNotFound,
    FailureKind.conflict => loc.errorConflict,
    FailureKind.expired => loc.errorExpired,
    FailureKind.rateLimited => loc.errorRateLimited,
    FailureKind.validation => loc.errorValidation,
    FailureKind.server => loc.loginServiceUnavailable,
    FailureKind.invalidResponse => loc.errorInvalidResponse,
    FailureKind.unsupported => loc.errorUnsupported,
    FailureKind.unexpected => loc.errorUnexpected,
  };
}

bool _isBusinessMessage(String message) {
  final value = message.trim();
  return value.isNotEmpty &&
      value.length <= 300 &&
      !RegExp(
        r'[<>\r\n]|https?://|exception|stacktrace|bearer\s|eyJ[a-zA-Z0-9_-]+\.',
        caseSensitive: false,
      ).hasMatch(value) &&
      !RegExp(r'^HTTP error:', caseSensitive: false).hasMatch(value);
}
