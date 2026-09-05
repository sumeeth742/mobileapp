abstract final class BackendConfiguration {
  /// Supply with --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000.
  static const String baseUrl = String.fromEnvironment('BACKEND_BASE_URL');

  /// Development-only token. Production will use the Supabase access token.
  static const String developmentToken = String.fromEnvironment('DEV_AUTH_TOKEN');

  static bool get isConfigured => baseUrl.isNotEmpty && developmentToken.isNotEmpty;
}
