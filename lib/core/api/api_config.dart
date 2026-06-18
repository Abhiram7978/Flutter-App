/// API configuration.
///
/// IMPORTANT: [apiKey] is hardcoded per the project decision to keep this
/// a single-user personal tool for Phase 1. Do not commit a real production
/// key to a public repository — if this app is ever distributed beyond
/// personal use, replace this with a secure runtime-entry flow instead.
class ApiConfig {
  const ApiConfig._();

  /// Base URL of the FastAPI backend.
  ///
  /// - Android emulator talking to a host machine: use 10.0.2.2 instead of
  ///   localhost.
  /// - Physical device on the same LAN: use the host machine's LAN IP.
  /// - Production: replace with your deployed domain (https://...).
  static const String baseUrl = 'http://10.0.2.2:8000';

  /// X-API-Key header value. Must match API_KEY in the backend's .env file.
  static const String apiKey = 'REPLACE_WITH_YOUR_API_KEY';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String apiKeyHeader = 'X-API-Key';
}
