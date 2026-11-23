import '../models/family_member.dart';
export 'http_family_repository.dart';

abstract class FamilyRepository {
  Future<Map<String, dynamic>> getFamily();
  Future<Map<String, dynamic>> updateFamily({
    String? familyName,
    String? currency,
    String? timezone,
    dynamic openingCashBalance,
  });
  Future<List<FamilyMember>> getFamilyMembers();
  Future<FamilyMember> createFamilyMember({
    required String name,
    required String relationType,
    String? avatarUrl,
  });
  Future<void> deleteFamilyMember(String memberId);
  Future<Map<String, dynamic>> createInvitation({
    required String role,
    String? invitedEmail,
    String? memberId,
    int expiresInHours = 72,
  });
}

class MockFamilyRepository implements FamilyRepository {
  @override
  Future<Map<String, dynamic>> getFamily() async {
    return {
      'id': '1e086770-85eb-475f-ad3a-0e1a67ac1641',
      'family_name': 'Mehta Family',
      'currency': 'INR',
      'timezone': 'Asia/Kolkata',
      'members_count': 4,
      'active_members_count': 4,
    };
  }

  @override
  Future<Map<String, dynamic>> updateFamily({
    String? familyName,
    String? currency,
    String? timezone,
    dynamic openingCashBalance,
  }) async {
    return {
      'id': '1e086770-85eb-475f-ad3a-0e1a67ac1641',
      'family_name': familyName ?? 'Mehta Family',
      'currency': currency ?? 'INR',
      'timezone': timezone ?? 'Asia/Kolkata',
      'members_count': 4,
      'active_members_count': 4,
    };
  }

  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    return const [
      FamilyMember(
        id: '1c005183-b2c5-4471-80b0-217944056e76',
        name: 'Arjun Mehta',
        initial: 'A',
        relationType: MemberRelation.self,
        role: 'OWNER',
        status: 'ACTIVE',
      ),
      FamilyMember(
        id: '65cd74e7-9da2-4c0b-a2d9-258dc615ac42',
        name: 'Priya Mehta',
        initial: 'P',
        relationType: MemberRelation.spouse,
        role: null,
        status: 'DEPENDENT',
      ),
      FamilyMember(
        id: 'e82a1a3d-eb86-463f-a4a8-2749ac8f327a',
        name: 'Aarav Mehta',
        initial: 'A',
        relationType: MemberRelation.child,
        role: null,
        status: 'DEPENDENT',
      ),
      FamilyMember(
        id: 'af638be8-ec5d-4ca9-bb41-a082bf0241fd',
        name: 'Ramesh Mehta',
        initial: 'R',
        relationType: MemberRelation.parent,
        role: null,
        status: 'DEPENDENT',
      ),
    ];
  }

  @override
  Future<FamilyMember> createFamilyMember({
    required String name,
    required String relationType,
    String? avatarUrl,
  }) async {
    return FamilyMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      initial: name.isNotEmpty ? name[0].toUpperCase() : 'M',
      relationType: MemberRelation.values.firstWhere(
        (e) => e.name.toUpperCase() == relationType.toUpperCase(),
        orElse: () => MemberRelation.other,
      ),
      status: 'DEPENDENT',
    );
  }

  @override
  Future<void> deleteFamilyMember(String memberId) async {}

  @override
  Future<Map<String, dynamic>> createInvitation({
    required String role,
    String? invitedEmail,
    String? memberId,
    int expiresInHours = 72,
  }) async {
    return {
      'id': 'inv_${DateTime.now().millisecondsSinceEpoch}',
      'role': role,
      'status': 'PENDING',
      'invite_url': 'https://finimo.app/join/mock_token',
      'expires_at': DateTime.now().add(Duration(hours: expiresInHours)).toIso8601String(),
    };
  }
}

