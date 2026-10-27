class UserProfileData {
  final String fullName;
  final String email;
  final String initials;
  final String roleBadge;
  final bool isVerified;
  final String finimoId;
  final String syncState;
  final String sessionNode;
  final String familyEntityName;
  final String localeAndBasis;
  final String accessScope;
  final String accessScopeBadge;
  final bool biometricSecurityEnabled;
  final String appVersion;
  final String appPhase;

  const UserProfileData({
    required this.fullName,
    required this.email,
    required this.initials,
    required this.roleBadge,
    required this.isVerified,
    required this.finimoId,
    required this.syncState,
    required this.sessionNode,
    required this.familyEntityName,
    required this.localeAndBasis,
    required this.accessScope,
    required this.accessScopeBadge,
    required this.biometricSecurityEnabled,
    required this.appVersion,
    required this.appPhase,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      fullName: json['fullName'] as String? ?? 'Arpa Roy',
      email: json['email'] as String? ?? 'arpa.roy@gmail.com',
      initials: json['initials'] as String? ?? 'AR',
      roleBadge: json['roleBadge'] as String? ?? 'ADMIN / OWNER',
      isVerified: json['isVerified'] as bool? ?? true,
      finimoId: json['finimoId'] as String? ?? '#8841',
      syncState: json['syncState'] as String? ?? 'Live Core',
      sessionNode: json['sessionNode'] as String? ?? 'Mobile · In-Auth',
      familyEntityName: json['familyEntityName'] as String? ?? 'Roy Family',
      localeAndBasis:
          json['localeAndBasis'] as String? ?? 'INR (₹) · Asia/Kolkata',
      accessScope: json['accessScope'] as String? ?? '1 Active Member',
      accessScopeBadge: json['accessScopeBadge'] as String? ?? 'Single Mode',
      biometricSecurityEnabled:
          json['biometricSecurityEnabled'] as bool? ?? true,
      appVersion: json['appVersion'] as String? ?? 'FINIMO v1.0.0',
      appPhase: json['appPhase'] as String? ?? '(Phase 1 MVP)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'initials': initials,
      'roleBadge': roleBadge,
      'isVerified': isVerified,
      'finimoId': finimoId,
      'syncState': syncState,
      'sessionNode': sessionNode,
      'familyEntityName': familyEntityName,
      'localeAndBasis': localeAndBasis,
      'accessScope': accessScope,
      'accessScopeBadge': accessScopeBadge,
      'biometricSecurityEnabled': biometricSecurityEnabled,
      'appVersion': appVersion,
      'appPhase': appPhase,
    };
  }
}
