import '../core/api_client.dart';
import '../core/api_config.dart';
import '../models/family_member.dart';
import 'family_repository.dart';

class HttpFamilyRepository implements FamilyRepository {
  final ApiClient apiClient;

  HttpFamilyRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  @override
  Future<Map<String, dynamic>> getFamily() async {
    final response = await apiClient.get(ApiConfig.family, requiresAuth: true);
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Invalid response from /family');
  }

  @override
  Future<Map<String, dynamic>> updateFamily({
    String? familyName,
    String? currency,
    String? timezone,
    dynamic openingCashBalance,
  }) async {
    final body = <String, dynamic>{};
    if (familyName != null && familyName.trim().isNotEmpty) {
      body['family_name'] = familyName.trim();
    }
    if (currency != null && currency.trim().isNotEmpty) {
      body['currency'] = currency.trim();
    }
    if (timezone != null && timezone.trim().isNotEmpty) {
      body['timezone'] = timezone.trim();
    }
    if (openingCashBalance != null) {
      body['opening_cash_balance'] = openingCashBalance;
    }

    final response = await apiClient.patch(
      ApiConfig.family,
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(statusCode: 500, message: 'Failed to update family');
  }

  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    final response =
        await apiClient.get(ApiConfig.familyMembers, requiresAuth: true);
    if (response is List) {
      return response
          .whereType<Map<String, dynamic>>()
          .map((json) => FamilyMember.fromJson(json))
          .toList();
    }
    return [];
  }

  @override
  Future<FamilyMember> createFamilyMember({
    required String name,
    required String relationType,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'relation_type': relationType.toUpperCase(),
    };
    if (avatarUrl != null && avatarUrl.trim().isNotEmpty) {
      body['avatar_url'] = avatarUrl.trim();
    }

    final response = await apiClient.post(
      ApiConfig.familyMembers,
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return FamilyMember.fromJson(response);
    }
    throw ApiException(
      statusCode: 500,
      message: 'Failed to create family member',
    );
  }

  @override
  Future<void> deleteFamilyMember(String memberId) async {
    await apiClient.delete(
      ApiConfig.familyMemberById(memberId),
      requiresAuth: true,
    );
  }

  @override
  Future<Map<String, dynamic>> createInvitation({
    required String role,
    String? invitedEmail,
    String? memberId,
    int expiresInHours = 72,
  }) async {
    final body = <String, dynamic>{
      'role': role.toUpperCase(),
      'expires_in_hours': expiresInHours,
    };
    if (invitedEmail != null && invitedEmail.trim().isNotEmpty) {
      body['invited_email'] = invitedEmail.trim();
    }
    if (memberId != null && memberId.trim().isNotEmpty) {
      body['member_id'] = memberId.trim();
    }

    final response = await apiClient.post(
      ApiConfig.familyInvitations,
      body: body,
      requiresAuth: true,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    throw ApiException(
      statusCode: 500,
      message: 'Failed to generate family invitation link',
    );
  }
}
