import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:finimo/core/api_client.dart';
import 'package:finimo/core/token_storage.dart';
import 'package:finimo/models/family_member.dart';
import 'package:finimo/services/http_auth_repository.dart';
import 'package:finimo/services/http_family_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  group('Profile and Family Integration Tests', () {
    test('getCurrentProfile fetches real user and family details', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/auth/me')) {
          return http.Response(
            jsonEncode({
              'user': {
                'id': 'f80993fd-c715-4b82-a8fa-6bfe3e9e79fe',
                'email': 'arjun.mehta@example.com',
                'full_name': 'Arjun Mehta',
                'phone_number': null,
              },
              'family_id': '1e086770-85eb-475f-ad3a-0e1a67ac1641',
              'member_id': '1c005183-b2c5-4471-80b0-217944056e76',
              'role': 'OWNER',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path.endsWith('/api/v1/family')) {
          return http.Response(
            jsonEncode({
              'id': '1e086770-85eb-475f-ad3a-0e1a67ac1641',
              'family_name': 'Mehta Family',
              'currency': 'INR',
              'timezone': 'Asia/Kolkata',
              'members_count': 4,
              'active_members_count': 4,
            }),
            200,
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

      final profile = await repo.getCurrentProfile();

      expect(profile.fullName, 'Arjun Mehta');
      expect(profile.email, 'arjun.mehta@example.com');
      expect(profile.initials, 'AM');
      expect(profile.familyEntityName, 'Mehta Family');
      expect(profile.accessScope, '4 Members');
      expect(profile.accessScopeBadge, 'Primary Admin');
      expect(profile.roleBadge, 'ADMIN / OWNER');
      expect(profile.syncState, 'Active');
      expect(profile.sessionNode, 'Mobile App');
      expect(profile.finimoId, '#F809');
    });

    test('updateFamily updates family name and currency/timezone', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/family') &&
            request.method == 'PATCH') {
          final body = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'id': '1e086770-85eb-475f-ad3a-0e1a67ac1641',
              'family_name': body['family_name'] ?? 'Mehta Family',
              'currency': body['currency'] ?? 'INR',
              'timezone': body['timezone'] ?? 'Asia/Kolkata',
              'members_count': 4,
              'active_members_count': 4,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpFamilyRepository(apiClient: apiClient);

      final updated = await repo.updateFamily(
        familyName: 'The New Mehta Clan',
        currency: 'USD',
        timezone: 'UTC',
      );

      expect(updated['family_name'], 'The New Mehta Clan');
      expect(updated['currency'], 'USD');
      expect(updated['timezone'], 'UTC');
    });

    test('createFamilyMember posts new dependent to family/members', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/family/members') &&
            request.method == 'POST') {
          final body = jsonDecode(request.body);
          return http.Response(
            jsonEncode({
              'id': 'new_member_123',
              'family_id': '1e086770-85eb-475f-ad3a-0e1a67ac1641',
              'name': body['name'],
              'relation_type': body['relation_type'],
              'is_active': true,
              'status': 'DEPENDENT',
              'created_at': DateTime.now().toIso8601String(),
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(
        tokenStorage: tokenStorage,
        httpClient: mockClient,
      );
      final repo = HttpFamilyRepository(apiClient: apiClient);

      final member = await repo.createFamilyMember(
        name: 'Priya Mehta',
        relationType: 'SPOUSE',
      );

      expect(member.name, 'Priya Mehta');
      expect(member.relationType, MemberRelation.spouse);
      expect(member.status, 'DEPENDENT');
    });

    test('changePassword calls auth/change-password and clears storage', () async {
      FlutterSecureStorage.setMockInitialValues({});
      final tokenStorage = TokenStorage();
      await tokenStorage.saveTokens(
        accessToken: 'mock_jwt_token',
        refreshToken: 'mock_refresh_token',
      );

      var changePasswordCalled = false;
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/api/v1/auth/change-password') &&
            request.method == 'POST') {
          changePasswordCalled = true;
          return http.Response(jsonEncode({'status': 'success'}), 200);
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

      await repo.changePassword(
        currentPassword: 'OldPassword123',
        newPassword: 'NewSecurePassword123!',
      );

      expect(changePasswordCalled, isTrue);
      expect(await tokenStorage.getAccessToken(), isNull);
    });
  });
}
