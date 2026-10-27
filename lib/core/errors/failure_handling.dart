import 'dart:async';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../domain/errors/app_failure.dart';

AppFailure classifyFailure(Object error) {
  if (error is AppFailure) return error;
  if (error is TimeoutException) {
    return const AppFailure('Request timed out', kind: FailureKind.timeout);
  }
  if (error is http.ClientException) {
    return const AppFailure('Network unavailable', kind: FailureKind.network);
  }
  if (error is FormatException || error is TypeError) {
    return const AppFailure(
      'Invalid response',
      kind: FailureKind.invalidResponse,
    );
  }
  return const AppFailure('Unexpected failure', kind: FailureKind.unexpected);
}

bool canUseCachedData(Object error) => classifyFailure(error).allowsCachedRead;

/// No exception message, payload, URL, token, PIN or user identifier is logged.
abstract final class FailureDiagnostics {
  static String describe(Object error, {required String operation}) {
    final failure = classifyFailure(error);
    final safeOperation = RegExp(r'^[a-z][a-z0-9_.]{0,63}$').hasMatch(operation)
        ? operation
        : 'unknown';
    final correlation = failure.correlationId;
    final safeCorrelation =
        correlation != null &&
        RegExp(r'^[A-Za-z0-9._:-]{1,128}$').hasMatch(correlation);
    return 'operation=$safeOperation kind=${failure.kind.name}'
        '${failure.statusCode == null ? '' : ' status=${failure.statusCode}'}'
        '${safeCorrelation ? ' correlation=$correlation' : ''}';
  }

  static void record(
    Object error,
    StackTrace stackTrace, {
    required String operation,
  }) {
    developer.log(
      describe(error, operation: operation),
      name: 'jambarpay.errors',
      level: 900,
      stackTrace: stackTrace,
    );
  }
}
