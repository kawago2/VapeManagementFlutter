import 'package:shared_preferences/shared_preferences.dart';

class TursoConfig {
  /// Default Turso Database URL injected from environment (via --dart-define or --dart-define-from-file=.env)
  static const String _envDatabaseUrl = String.fromEnvironment(
    'TURSO_DATABASE_URL',
    defaultValue: '',
  );

  /// Default Turso Auth Token injected from environment (via --dart-define or --dart-define-from-file=.env)
  static const String _envAuthToken = String.fromEnvironment(
    'TURSO_AUTH_TOKEN',
    defaultValue: '',
  );

  static const String _authTokenKey = 'turso_stored_auth_token_key';

  static String get databaseUrl => _envDatabaseUrl;

  static Future<String> getAuthToken() async {
    // 1. Prioritaskan token dari environment jika di-pass saat build/run
    if (_envAuthToken.isNotEmpty) {
      return _envAuthToken;
    }
    // 2. Fallback ke token yang disimpan user via UI SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) ?? '';
  }

  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token.trim());
  }

  static Future<bool> isConfigured() async {
    final token = await getAuthToken();
    return databaseUrl.isNotEmpty && token.isNotEmpty;
  }
}
