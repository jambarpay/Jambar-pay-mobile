enum FailureKind {
  network,
  timeout,
  unauthenticated,
  forbidden,
  notFound,
  conflict,
  expired,
  rateLimited,
  validation,
  server,
  invalidResponse,
  unsupported,
  unexpected,
}

/// An explicit failure category; messages are never used to make access decisions.
class AppFailure implements Exception {
  const AppFailure(
    this.message, {
    FailureKind? kind,
    this.statusCode,
    this.code,
    this.retryAfter,
    this.correlationId,
  }) : _kind = kind;

  final String message;
  final FailureKind? _kind;
  final int? statusCode;
  final String? code;
  final Duration? retryAfter;
  final String? correlationId;

  FailureKind get kind =>
      _kind ??
      switch (statusCode) {
        400 || 422 => FailureKind.validation,
        401 => FailureKind.unauthenticated,
        403 => FailureKind.forbidden,
        404 => FailureKind.notFound,
        408 => FailureKind.timeout,
        409 => FailureKind.conflict,
        410 => FailureKind.expired,
        429 => FailureKind.rateLimited,
        final status? when status >= 500 => FailureKind.server,
        _ => FailureKind.unexpected,
      };

  /// A server response is never evidence that the device is offline.
  bool get allowsOfflineLogin =>
      statusCode == null &&
      (kind == FailureKind.network || kind == FailureKind.timeout);

  bool get allowsCachedRead => allowsOfflineLogin || kind == FailureKind.server;

  @override
  String toString() => message;
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.code})
    : super(kind: FailureKind.validation);
}
