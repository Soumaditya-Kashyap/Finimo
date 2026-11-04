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
  final String? userId;
  final String? familyId;
  final String? memberId;
  final String currency;
  final String timezone;
  final int membersCount;

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
    this.userId,
    this.familyId,
    this.memberId,
    this.currency = 'INR',
    this.timezone = 'Asia/Kolkata',
    this.membersCount = 1,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('user')) {
      return UserProfileData.fromAuthResponse(json);
    }

    return UserProfileData(
      fullName: json['fullName'] as String? ?? 'Arpa Roy',
      email: json['email'] as String? ?? 'arpa.roy@gmail.com',
      initials: json['initials'] as String? ?? 'AR',
      roleBadge: json['roleBadge'] as String? ?? 'ADMIN / OWNER',
      isVerified: json['isVerified'] as bool? ?? true,
      finimoId: json['finimoId'] as String? ?? '#8841',
      syncState: json['syncState'] as String? ?? 'Active',
      sessionNode: json['sessionNode'] as String? ?? 'Mobile App',
      familyEntityName: json['familyEntityName'] as String? ?? 'Roy Family',
      localeAndBasis:
          json['localeAndBasis'] as String? ?? 'INR (₹) · Asia/Kolkata',
      accessScope: json['accessScope'] as String? ?? '1 Member',
      accessScopeBadge: json['accessScopeBadge'] as String? ?? 'Primary Admin',
      biometricSecurityEnabled:
          json['biometricSecurityEnabled'] as bool? ?? true,
      appVersion: json['appVersion'] as String? ?? 'FINIMO v1.0.0',
      appPhase: json['appPhase'] as String? ?? '(Phase 1 MVP)',
      userId: json['userId'] as String?,
      familyId: json['familyId'] as String?,
      memberId: json['memberId'] as String?,
      currency: json['currency'] as String? ?? 'INR',
      timezone: json['timezone'] as String? ?? 'Asia/Kolkata',
      membersCount: json['membersCount'] as int? ?? 1,
    );
  }

  factory UserProfileData.fromAuthResponse(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final family = json['family'] as Map<String, dynamic>? ?? {};
    final member = json['member'] as Map<String, dynamic>? ?? {};

    final fullName =
        (user['full_name'] as String?)?.trim() ??
        (member['name'] as String?)?.trim() ??
        'User';
    final email = (user['email'] as String?)?.trim() ?? '';

    // Calculate initials
    String initials = 'U';
    if (fullName.isNotEmpty) {
      final parts = fullName
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty)
          .toList();
      if (parts.length == 1) {
        initials = parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
      } else if (parts.length >= 2) {
        initials = '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
    }

    // Role badge
    final memberRole = (json['role'] ?? member['role'])?.toString().toUpperCase();
    final roleBadge = (memberRole == 'ADMIN' || memberRole == 'OWNER')
        ? 'ADMIN / OWNER'
        : (memberRole ?? 'ADMIN / OWNER');

    // Finimo ID
    final rawUserId = user['id']?.toString() ?? '';
    final finimoId = rawUserId.length >= 4
        ? '#${rawUserId.substring(0, 4).toUpperCase()}'
        : '#8841';

    // Family / space
    final familyName =
        (family['family_name'] as String?)?.trim() ?? 'Family Space';
    final currency = (family['currency'] as String?)?.trim() ?? 'INR';
    final timezone =
        (family['timezone'] as String?)?.trim() ?? 'Asia/Kolkata';

    // Currency symbol lookup
    String currencySymbol = '₹';
    if (currency == 'USD') {
      currencySymbol = '\$';
    } else if (currency == 'EUR') {
      currencySymbol = '€';
    } else if (currency == 'GBP') {
      currencySymbol = '£';
    }

    // Members count
    final count = (family['members_count'] as int?) ??
        (family['active_members_count'] as int?) ??
        1;
    final accessScope = count == 1 ? '1 Member' : '$count Members';
    final accessScopeBadge =
        (memberRole == 'OWNER' || memberRole == 'ADMIN') ? 'Primary Admin' : 'Family Member';

    return UserProfileData(
      fullName: fullName,
      email: email,
      initials: initials,
      roleBadge: roleBadge,
      isVerified: true,
      finimoId: finimoId,
      syncState: 'Active',
      sessionNode: 'Mobile App',
      familyEntityName: familyName,
      localeAndBasis: '$currency ($currencySymbol) · $timezone',
      accessScope: accessScope,
      accessScopeBadge: accessScopeBadge,
      biometricSecurityEnabled: true,
      appVersion: 'FINIMO v1.0.0',
      appPhase: '(Phase 1 MVP)',
      userId: user['id']?.toString(),
      familyId: (family['id'] ?? json['family_id'])?.toString(),
      memberId: (member['id'] ?? json['member_id'])?.toString(),
      currency: currency,
      timezone: timezone,
      membersCount: count,
    );
  }

  UserProfileData copyWith({
    String? fullName,
    String? email,
    String? initials,
    String? roleBadge,
    bool? isVerified,
    String? finimoId,
    String? syncState,
    String? sessionNode,
    String? familyEntityName,
    String? localeAndBasis,
    String? accessScope,
    String? accessScopeBadge,
    bool? biometricSecurityEnabled,
    String? appVersion,
    String? appPhase,
    String? userId,
    String? familyId,
    String? memberId,
    String? currency,
    String? timezone,
    int? membersCount,
  }) {
    return UserProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      initials: initials ?? this.initials,
      roleBadge: roleBadge ?? this.roleBadge,
      isVerified: isVerified ?? this.isVerified,
      finimoId: finimoId ?? this.finimoId,
      syncState: syncState ?? this.syncState,
      sessionNode: sessionNode ?? this.sessionNode,
      familyEntityName: familyEntityName ?? this.familyEntityName,
      localeAndBasis: localeAndBasis ?? this.localeAndBasis,
      accessScope: accessScope ?? this.accessScope,
      accessScopeBadge: accessScopeBadge ?? this.accessScopeBadge,
      biometricSecurityEnabled:
          biometricSecurityEnabled ?? this.biometricSecurityEnabled,
      appVersion: appVersion ?? this.appVersion,
      appPhase: appPhase ?? this.appPhase,
      userId: userId ?? this.userId,
      familyId: familyId ?? this.familyId,
      memberId: memberId ?? this.memberId,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      membersCount: membersCount ?? this.membersCount,
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
      'userId': userId,
      'familyId': familyId,
      'memberId': memberId,
      'currency': currency,
      'timezone': timezone,
      'membersCount': membersCount,
    };
  }
}
