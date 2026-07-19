import 'package:flutter/foundation.dart';

abstract final class AppEnvironment {
  static const useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: kDebugMode,
  );

  static const useLocalAuth = bool.fromEnvironment(
    'USE_LOCAL_AUTH',
    defaultValue: kDebugMode,
  );
}
