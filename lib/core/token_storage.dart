import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token manager storing access token, refresh token, and active family ID
class TokenStorage {
  static const _accessTokenKey = 'finimo_access_token';
  static const _refreshTokenKey = 'finimo_refresh_token';
  static const _activeFamilyIdKey = 'finimo_active_family_id';

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
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveActiveFamilyId(String familyId) async {
    await _storage.write(key: _activeFamilyIdKey, value: familyId);
  }

  Future<String?> getActiveFamilyId() async {
    return _storage.read(key: _activeFamilyIdKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
