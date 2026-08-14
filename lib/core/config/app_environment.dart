abstract final class AppEnvironment {
  static const useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: false,
  );

  static const useLocalAuth = bool.fromEnvironment(
    'USE_LOCAL_AUTH',
    defaultValue: false,
  );
}
