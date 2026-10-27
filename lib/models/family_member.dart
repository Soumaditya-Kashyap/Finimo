enum MemberRelation { admin, spouse, child, parent, other }

class FamilyMember {
  final String id;
  final String name;
  final String initial;
  final MemberRelation relationType;
  final String? avatarUrl;

  const FamilyMember({
    required this.id,
    required this.name,
    required this.initial,
    required this.relationType,
    this.avatarUrl,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String,
      name: json['name'] as String,
      initial: json['initial'] as String? ?? (json['name'] as String)[0].toUpperCase(),
      relationType: MemberRelation.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['relation_type'] as String? ?? 'OTHER').toUpperCase(),
        orElse: () => MemberRelation.other,
      ),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initial': initial,
    'relation_type': relationType.name.toUpperCase(),
    'avatar_url': avatarUrl,
  };
}
