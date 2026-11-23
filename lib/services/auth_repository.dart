import '../core/app_version.dart';
import '../models/user_profile_data.dart';
export 'http_auth_repository.dart';

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
  Future<UserProfileData> getCurrentProfile();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<UserProfileData?> checkCurrentSession() async {
    return null;
  }

  @override
  Future<UserProfileData> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserProfileData(
      fullName: 'Arpa Roy',
      email: 'arpa.roy@gmail.com',
      initials: 'AR',
      roleBadge: 'ADMIN / OWNER',
      isVerified: true,
      finimoId: '#8841',
      syncState: 'Active',
      sessionNode: 'Mobile App',
      familyEntityName: 'Roy Family',
      localeAndBasis: 'INR (₹) · Asia/Kolkata',
      accessScope: '1 Member',
      accessScopeBadge: 'Primary Admin',
      biometricSecurityEnabled: true,
      appVersion: AppVersion.displayVersion,
      appPhase: '(${AppVersion.appPhase})',
    );
  }

  @override
  Future<UserProfileData> registerAndCreateSpace({
    required String fullName,
    required String email,
    required String password,
    required String householdSpaceName,
  }) async {
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
      syncState: 'Active',
      sessionNode: 'Mobile App',
      familyEntityName:
          householdSpaceName.isEmpty ? 'Roy Family' : householdSpaceName,
      localeAndBasis: 'INR (₹) · Asia/Kolkata',
      accessScope: '1 Member',
      accessScopeBadge: 'Primary Admin',
      biometricSecurityEnabled: true,
      appVersion: AppVersion.displayVersion,
      appPhase: '(${AppVersion.appPhase})',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }

  @override
  Future<UserProfileData> getCurrentProfile() async {
    return const UserProfileData(
      fullName: 'Arpa Roy',
      email: 'arpa.roy@gmail.com',
      initials: 'AR',
      roleBadge: 'ADMIN / OWNER',
      isVerified: true,
      finimoId: '#8841',
      syncState: 'Active',
      sessionNode: 'Mobile App',
      familyEntityName: 'Roy Family',
      localeAndBasis: 'INR (₹) · Asia/Kolkata',
      accessScope: '1 Member',
      accessScopeBadge: 'Primary Admin',
      biometricSecurityEnabled: true,
      appVersion: AppVersion.displayVersion,
      appPhase: '(${AppVersion.appPhase})',
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
