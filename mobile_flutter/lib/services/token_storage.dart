import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final TokenStorage instance = TokenStorage._internal();
  static const _key = 'auth_token';
  static const _userKey = 'current_user_json';
  static const _onboardingPrefix = 'onboarding_';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  TokenStorage._internal();

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _key, value: token);
    } catch (_) {}
  }

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }

  Future<void> saveUserJson(String json) async {
    try {
      await _storage.write(key: _userKey, value: json);
    } catch (_) {}
  }

  Future<String?> readUserJson() async {
    try {
      return await _storage.read(key: _userKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUserJson() async {
    try {
      await _storage.delete(key: _userKey);
    } catch (_) {}
  }

  Future<void> saveOnboardingJson(String userId, String json) async {
    try {
      await _storage.write(key: '$_onboardingPrefix$userId', value: json);
    } catch (_) {}
  }

  Future<String?> readOnboardingJson(String userId) async {
    try {
      return await _storage.read(key: '$_onboardingPrefix$userId');
    } catch (_) {
      return null;
    }
  }
}
