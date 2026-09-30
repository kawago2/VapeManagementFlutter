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

  static const String _databaseUrlKey = 'turso_stored_database_url_key';
  static const String _authTokenKey = 'turso_stored_auth_token_key';

  /// Mendapatkan database URL: utamakan env jika ada, fallback ke SharedPreferences
  static Future<String> getDatabaseUrl() async {
    if (_envDatabaseUrl.isNotEmpty) {
      return _envDatabaseUrl;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_databaseUrlKey) ?? '';
  }

  /// Menyimpan database URL ke SharedPreferences
  static Future<void> setDatabaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_databaseUrlKey, url.trim());
  }

  /// Mendapatkan auth token: utamakan env jika ada, fallback ke SharedPreferences
  static Future<String> getAuthToken() async {
    if (_envAuthToken.isNotEmpty) {
      return _envAuthToken;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) ?? '';
  }

  /// Menyimpan auth token ke SharedPreferences
  static Future<void> setAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token.trim());
  }

  /// Mengecek apakah kredensial (URL & Token) sudah tersedia
  static Future<bool> isConfigured() async {
    final url = await getDatabaseUrl();
    final token = await getAuthToken();
    return url.isNotEmpty && token.isNotEmpty;
  }
}
