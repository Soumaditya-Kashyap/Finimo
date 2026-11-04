enum MemberRelation { self, admin, spouse, child, parent, sibling, other }

class FamilyMember {
  final String id;
  final String name;
  final String initial;
  final MemberRelation relationType;
  final String? avatarUrl;
  final String? role;
  final String? status;
  final bool isActive;
  final String? userId;
  final String? familyId;
  final String? createdAt;
  final String? joinedAt;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.initial,
    required this.relationType,
    this.avatarUrl,
    this.role,
    this.status,
    this.isActive = true,
    this.userId,
    this.familyId,
    this.createdAt,
    this.joinedAt,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final rawName = (json['name'] as String?)?.trim() ?? 'Member';
    final rawInitial = (json['initial'] as String?) ??
        (rawName.isNotEmpty ? rawName[0].toUpperCase() : 'M');

    final rawRelation = (json['relation_type'] as String?)?.toUpperCase() ?? 'OTHER';
    MemberRelation relation;
    switch (rawRelation) {
      case 'SELF':
        relation = MemberRelation.self;
        break;
      case 'ADMIN':
        relation = MemberRelation.admin;
        break;
      case 'SPOUSE':
        relation = MemberRelation.spouse;
        break;
      case 'CHILD':
        relation = MemberRelation.child;
        break;
      case 'PARENT':
        relation = MemberRelation.parent;
        break;
      case 'SIBLING':
        relation = MemberRelation.sibling;
        break;
      default:
        relation = MemberRelation.other;
    }

    return FamilyMember(
      id: json['id']?.toString() ?? '',
      name: rawName,
      initial: rawInitial,
      relationType: relation,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      userId: json['user_id'] as String?,
      familyId: json['family_id'] as String?,
      createdAt: json['created_at'] as String?,
      joinedAt: json['joined_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initial': initial,
    'relation_type': relationType.name.toUpperCase(),
    'avatar_url': avatarUrl,
    'role': role,
    'status': status,
    'is_active': isActive,
    'user_id': userId,
    'family_id': familyId,
    'created_at': createdAt,
    'joined_at': joinedAt,
  };
}
