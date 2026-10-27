import '../models/user_profile_data.dart';

abstract class AuthRepository {
  Future<UserProfileData?> checkCurrentSession();
  Future<UserProfileData> login({
    required String email,
    required String password,
  });
  Future<UserProfileData> registerAndCreateSpace({
    required String fullName,
    required String email,
    required String password,
    required String householdSpaceName,
  });
  Future<void> logout();
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserProfileData?> checkCurrentSession() async {
    // Return null so user arrives on Auth screen on launch
    return null;
  }

  @override
  Future<UserProfileData> login({
    required String email,
    required String password,
  }) async {
    // TODO: Replace with real POST /api/v1/auth/login
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserProfileData(
      fullName: 'Arpa Roy',
      email: 'arpa.roy@gmail.com',
      initials: 'AR',
      roleBadge: 'ADMIN / OWNER',
      isVerified: true,
      finimoId: '#8841',
      syncState: 'Live Core',
      sessionNode: 'Mobile · In-Auth',
      familyEntityName: 'Roy Family',
      localeAndBasis: 'INR (₹) · Asia/Kolkata',
      accessScope: '1 Active Member',
      accessScopeBadge: 'Single Mode',
      biometricSecurityEnabled: true,
      appVersion: 'FINIMO v1.0.0',
      appPhase: '(Phase 1 MVP)',
    );
  }

  @override
  Future<UserProfileData> registerAndCreateSpace({
    required String fullName,
    required String email,
    required String password,
    required String householdSpaceName,
  }) async {
    // TODO: Replace with real POST /api/v1/auth/register
    await Future.delayed(const Duration(milliseconds: 300));
    return UserProfileData(
      fullName: fullName.isEmpty ? 'Arpa Roy' : fullName,
      email: email.isEmpty ? 'arpa.roy@gmail.com' : email,
      initials: fullName.isNotEmpty
          ? fullName.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
          : 'AR',
      roleBadge: 'ADMIN / OWNER',
      isVerified: true,
      finimoId: '#8841',
      syncState: 'Live Core',
      sessionNode: 'Mobile · In-Auth',
      familyEntityName:
          householdSpaceName.isEmpty ? 'Roy Family' : householdSpaceName,
      localeAndBasis: 'INR (₹) · Asia/Kolkata',
      accessScope: '1 Active Member',
      accessScopeBadge: 'Single Mode',
      biometricSecurityEnabled: true,
      appVersion: 'FINIMO v1.0.0',
      appPhase: '(Phase 1 MVP)',
    );
  }

  @override
  Future<void> logout() async {
    // TODO: Clear local session tokens
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
