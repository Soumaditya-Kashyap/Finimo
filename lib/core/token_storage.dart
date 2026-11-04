import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token manager storing access token, refresh token, and active family ID
class TokenStorage {
  static const _accessTokenKey = 'finimo_access_token';
  static const _refreshTokenKey = 'finimo_refresh_token';
  static const _activeFamilyIdKey = 'finimo_active_family_id';
  static const _activeFamilyNameKey = 'finimo_active_family_name';
  static const _userEmailKey = 'finimo_user_email';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (_) {}
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveFamilyId(String familyId) async {
    try {
      await _storage.write(key: _activeFamilyIdKey, value: familyId);
    } catch (_) {}
  }

  Future<String?> getActiveFamilyId() async {
    try {
      return await _storage.read(key: _activeFamilyIdKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveActiveFamilyName(String familyName) async {
    try {
      await _storage.write(key: _activeFamilyNameKey, value: familyName);
    } catch (_) {}
  }

  Future<String?> getActiveFamilyName() async {
    try {
      return await _storage.read(key: _activeFamilyNameKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _userEmailKey, value: email);
    } catch (_) {}
  }

  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
