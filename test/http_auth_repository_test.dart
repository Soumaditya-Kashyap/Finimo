import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finimo/core/api_client.dart';
import 'package:finimo/core/token_storage.dart';
import 'package:finimo/models/user_profile_data.dart';
import 'package:finimo/services/http_auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // In-memory secure storage mock for unit tests
  FlutterSecureStorage.setMockInitialValues({});

  group('UserProfileData tests', () {
    test('fromAuthResponse parses FastAPI schema correctly', () {
      final responseMap = {
        'access_token': 'fake_access_token',
        'refresh_token': 'fake_refresh_token',
        'expires_in': 3600,
        'user': {
          'id': 'd290f1ee-6c54-4b01-90e6-d701748f0851',
          'email': 'arpa.roy@example.com',
          'full_name': 'Arpa Roy',
          'phone_number': null,
        },
        'family': {
          'id': 'fa123456-6c54-4b01-90e6-d701748f0852',
          'family_name': 'Roy Family',
          'currency': 'INR',
          'timezone': 'Asia/Kolkata',
        },
        'member': {
          'id': 'me123456-6c54-4b01-90e6-d701748f0853',
          'name': 'Arpa Roy',
          'relation_type': 'PRIMARY',
          'role': 'ADMIN',
          'avatar_url': null,
        },
      };

      final profile = UserProfileData.fromAuthResponse(responseMap);
      expect(profile.fullName, 'Arpa Roy');
      expect(profile.email, 'arpa.roy@example.com');
      expect(profile.initials, 'AR');
      expect(profile.roleBadge, 'ADMIN / OWNER');
      expect(profile.familyEntityName, 'Roy Family');
      expect(profile.localeAndBasis, 'INR (₹) · Asia/Kolkata');
      expect(profile.userId, 'd290f1ee-6c54-4b01-90e6-d701748f0851');
      expect(profile.familyId, 'fa123456-6c54-4b01-90e6-d701748f0852');
      expect(profile.memberId, 'me123456-6c54-4b01-90e6-d701748f0853');
    });
  });

  group('HttpAuthRepository tests', () {
    test('login stores tokens and returns UserProfileData', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/auth/login')) {
          final body = jsonDecode(request.body);
          if (body['email'] == 'test@example.com' &&
              body['password'] == 'password1234') {
            return http.Response(
              jsonEncode({
                'access_token': 'jwt_access_123',
                'refresh_token': 'jwt_refresh_456',
                'expires_in': 3600,
                'user': {
                  'id': 'user_uuid_1',
                  'email': 'test@example.com',
                  'full_name': 'Test User',
                },
                'family': {
                  'id': 'family_uuid_1',
                  'family_name': 'Test Family',
                  'currency': 'INR',
                  'timezone': 'Asia/Kolkata',
                },
                'member': {
                  'id': 'member_uuid_1',
                  'name': 'Test User',
                  'relation_type': 'PRIMARY',
                  'role': 'ADMIN',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response(
            jsonEncode({'detail': 'Invalid email or password'}),
            401,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpAuthRepository(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      );

      final profile = await repo.login(
        email: 'test@example.com',
        password: 'password1234',
      );

      expect(profile.fullName, 'Test User');
      expect(profile.email, 'test@example.com');
      expect(await tokenStorage.getAccessToken(), 'jwt_access_123');
      expect(await tokenStorage.getRefreshToken(), 'jwt_refresh_456');
      expect(await tokenStorage.getActiveFamilyId(), 'family_uuid_1');
    });

    test('login throws ApiException on invalid credentials', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Invalid email or password'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpAuthRepository(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      );

      expect(
        () => repo.login(email: 'wrong@example.com', password: 'badpassword'),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Invalid email or password',
        )),
      );
    });

    test('logout clears tokens and calls logout endpoint', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'valid_access_token',
        refreshToken: 'valid_refresh_token',
      );

      var logoutEndpointCalled = false;
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/auth/logout')) {
          logoutEndpointCalled = true;
          return http.Response(jsonEncode({'status': 'revoked'}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpAuthRepository(
        apiClient: apiClient,
        tokenStorage: tokenStorage,
      );

      await repo.logout();
      expect(logoutEndpointCalled, isTrue);
      expect(await tokenStorage.getAccessToken(), isNull);
      expect(await tokenStorage.getRefreshToken(), isNull);
    });

    test('ApiClient automatically refreshes token on 401 and retries original request', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'expired_access_token',
        refreshToken: 'valid_refresh_token',
      );

      var meCallCount = 0;
      var refreshCallCount = 0;

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/auth/me')) {
          meCallCount++;
          final authHeader = request.headers['Authorization'] ?? '';
          if (authHeader.contains('expired_access_token')) {
            return http.Response(jsonEncode({'detail': 'Token expired'}), 401);
          }
          if (authHeader.contains('new_access_token')) {
            return http.Response(
              jsonEncode({
                'user': {'id': 'u1', 'full_name': 'Arjun Mehta', 'email': 'arjun@example.com'},
                'member_id': 'm1',
                'role': 'ADMIN',
              }),
              200,
            );
          }
        } else if (request.url.path.endsWith('/api/v1/auth/refresh')) {
          refreshCallCount++;
          return http.Response(
            jsonEncode({
              'access_token': 'new_access_token',
              'refresh_token': 'new_refresh_token',
              'family': {'id': 'fam_1', 'family_name': 'Mehta Family'},
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, httpClient: mockClient);
      final response = await apiClient.get('/api/v1/auth/me', requiresAuth: true);

      expect(refreshCallCount, 1);
      expect(meCallCount, 2);
      expect(response['user']['full_name'], 'Arjun Mehta');
      expect(await tokenStorage.getAccessToken(), 'new_access_token');
      expect(await tokenStorage.getRefreshToken(), 'new_refresh_token');
    });

    test('checkCurrentSession preserves login state using cached profile on offline/network drop', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'some_access_token',
        refreshToken: 'some_refresh_token',
      );
      await tokenStorage.saveCachedUserProfile({
        'user': {'id': 'u1', 'full_name': 'Arjun Mehta', 'email': 'arjun@example.com'},
        'family': {'id': 'f1', 'family_name': 'Mehta Family', 'currency': 'INR', 'timezone': 'Asia/Kolkata'},
        'member': {'id': 'm1', 'name': 'Arjun Mehta', 'role': 'ADMIN'},
      });

      // Mock network failure / timeout
      final mockClient = MockClient((request) async {
        throw http.ClientException('No Internet');
      });

      final apiClient = ApiClient(tokenStorage: tokenStorage, httpClient: mockClient);
      final repo = HttpAuthRepository(apiClient: apiClient, tokenStorage: tokenStorage);

      final session = await repo.checkCurrentSession();
      expect(session, isNotNull);
      expect(session!.fullName, 'Arjun Mehta');
      expect(await tokenStorage.hasValidSession(), isTrue);
    });
  });
}

