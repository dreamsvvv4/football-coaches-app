import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final TokenStorage instance = TokenStorage._internal();
  static const _key = 'auth_token';
  static const _userKey = 'current_user_json';
  static const _onboardingPrefix = 'onboarding_';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  TokenStorage._internal();

  Future<void> saveToken(String token) => _storage.write(key: _key, value: token);

  Future<String?> readToken() => _storage.read(key: _key);

  Future<void> deleteToken() => _storage.delete(key: _key);

  Future<void> saveUserJson(String json) => _storage.write(key: _userKey, value: json);

  Future<String?> readUserJson() => _storage.read(key: _userKey);

  Future<void> deleteUserJson() => _storage.delete(key: _userKey);

    Future<void> saveOnboardingJson(String userId, String json) =>
      _storage.write(key: '$_onboardingPrefix$userId', value: json);

    Future<String?> readOnboardingJson(String userId) =>
      _storage.read(key: '$_onboardingPrefix$userId');
}
