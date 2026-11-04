import '../core/api_client.dart';
import '../core/api_config.dart';
import '../core/token_storage.dart';
import '../models/user_profile_data.dart';
import 'auth_repository.dart';

/// Real HTTP implementation of [AuthRepository] connecting to FastAPI backend
class HttpAuthRepository implements AuthRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  HttpAuthRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : tokenStorage = tokenStorage ?? TokenStorage(),
        apiClient = apiClient ?? ApiClient();

  @override
  Future<UserProfileData?> checkCurrentSession() async {
    try {
      final accessToken = await tokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return null;
      }

      // 1. Verify current session and get full profile
      try {
        return await getCurrentProfile();
      } on ApiException catch (e) {
        // If access token is expired (401), attempt refresh
        if (e.statusCode == 401) {
          final refreshedProfile = await _attemptTokenRefresh();
          if (refreshedProfile != null) {
            return refreshedProfile;
          }
        }
        // Session invalid
        await tokenStorage.clearAll();
        return null;
      }
    } catch (_) {
      // In case of network drops or unexpected issues during boot
      return null;
    }
  }

  Future<UserProfileData?> _attemptTokenRefresh() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await apiClient.post(
        ApiConfig.refreshToken,
        body: {'refresh_token': refreshToken},
        requiresAuth: false,
      );

      if (response is Map<String, dynamic> &&
          response.containsKey('access_token')) {
        await tokenStorage.saveTokens(
          accessToken: response['access_token'] as String,
          refreshToken:
              (response['refresh_token'] as String?) ?? refreshToken,
        );
        _persistFamilyContext(response);
        return await getCurrentProfile();
      }
    } catch (_) {
      await tokenStorage.clearAll();
    }
    return null;
  }

  @override
  Future<UserProfileData> getCurrentProfile() async {
    final meResp = await apiClient.get(ApiConfig.me, requiresAuth: true);
    Map<String, dynamic> me = {};
    if (meResp is Map<String, dynamic>) {
      me = meResp;
    }

    Map<String, dynamic> family = {};
    try {
      final familyResp = await apiClient.get(ApiConfig.family, requiresAuth: true);
      if (familyResp is Map<String, dynamic>) {
        family = familyResp;
      }
    } catch (_) {}

    final combined = <String, dynamic>{
      'user': me['user'] ?? {},
      'family': family,
      'member': {
        'id': me['member_id'],
        'role': me['role'],
      },
      'role': me['role'],
      'family_id': me['family_id'] ?? family['id'],
    };

    _persistFamilyContext(combined);
    return UserProfileData.fromAuthResponse(combined);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.post(
      ApiConfig.changePassword,
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      requiresAuth: true,
    );
    await tokenStorage.clearAll();
  }

  @override
  Future<UserProfileData> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConfig.login,
      body: {
        'email': email.trim(),
        'password': password,
      },
      requiresAuth: false,
    );

    if (response is Map<String, dynamic>) {
      final accessToken = response['access_token'] as String? ?? '';
      final refreshToken = response['refresh_token'] as String? ?? '';

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await tokenStorage.saveUserEmail(email.trim());
      _persistFamilyContext(response);

      // Now fetch full profile to ensure all counts are up to date
      try {
        return await getCurrentProfile();
      } catch (_) {
        return UserProfileData.fromAuthResponse(response);
      }
    }

    throw ApiException(
      statusCode: 500,
      message: 'Unexpected response structure from server during login.',
    );
  }

  @override
  Future<UserProfileData> registerAndCreateSpace({
    required String fullName,
    required String email,
    required String password,
    required String householdSpaceName,
  }) async {
    final body = {
      'email': email.trim(),
      'password': password,
      'full_name': fullName.trim(),
      'family_name': householdSpaceName.trim().isNotEmpty
          ? householdSpaceName.trim()
          : '${fullName.trim()} Family',
      'opening_cash_balance': '0.00',
      'currency': 'INR',
      'timezone': 'Asia/Kolkata',
      'accept_terms': true,
    };

    final response = await apiClient.post(
      ApiConfig.register,
      body: body,
      requiresAuth: false,
    );

    if (response is Map<String, dynamic>) {
      final accessToken = response['access_token'] as String? ?? '';
      final refreshToken = response['refresh_token'] as String? ?? '';

      await tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      await tokenStorage.saveUserEmail(email.trim());
      _persistFamilyContext(response);

      try {
        return await getCurrentProfile();
      } catch (_) {
        return UserProfileData.fromAuthResponse(response);
      }
    }

    throw ApiException(
      statusCode: 500,
      message: 'Unexpected response structure from server during registration.',
    );
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await apiClient.post(
          ApiConfig.logout,
          body: {'refresh_token': refreshToken},
          requiresAuth: true,
        );
      }
    } catch (_) {
      // Ignore network errors on logout to guarantee local wipe
    } finally {
      await tokenStorage.clearAll();
    }
  }

  void _persistFamilyContext(Map<String, dynamic> response) {
    if (response['family'] is Map<String, dynamic>) {
      final family = response['family'] as Map<String, dynamic>;
      if (family['id'] != null) {
        tokenStorage.saveActiveFamilyId(family['id'].toString());
      }
      if (family['family_name'] != null) {
        tokenStorage.saveActiveFamilyName(family['family_name'].toString());
      }
    } else if (response['family_id'] != null) {
      tokenStorage.saveActiveFamilyId(response['family_id'].toString());
    }
  }
}
