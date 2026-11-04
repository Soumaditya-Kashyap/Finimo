class ConjoinedEventSummary {
  final String id;
  final String title;
  final double budgetCap;
  final double totalSpent;
  final double remainingBudget;
  final double percentageUsed;
  final int contributingMembersCount;

  const ConjoinedEventSummary({
    required this.id,
    required this.title,
    required this.budgetCap,
    required this.totalSpent,
    required this.remainingBudget,
    required this.percentageUsed,
    required this.contributingMembersCount,
  });

  factory ConjoinedEventSummary.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('item_count') || json.containsKey('percentage_used')) {
      return ConjoinedEventSummary.fromApiResponse(json);
    }

    return ConjoinedEventSummary(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Event',
      budgetCap: (json['budget_cap'] as num?)?.toDouble() ??
          double.tryParse(json['budget_cap']?.toString() ?? '0') ??
          0.0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ??
          double.tryParse(json['total_spent']?.toString() ?? '0') ??
          0.0,
      remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ??
          double.tryParse(json['remaining_budget']?.toString() ?? '0') ??
          0.0,
      percentageUsed: (json['percentage_used'] as num?)?.toDouble() ??
          double.tryParse(json['percentage_used']?.toString() ?? '0') ??
          0.0,
      contributingMembersCount:
          json['contributing_members_count'] as int? ?? 1,
    );
  }

  factory ConjoinedEventSummary.fromApiResponse(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['title']?.toString() ?? 'Active Event';

    final budgetCap =
        double.tryParse(json['budget_cap']?.toString() ?? '0') ?? 0.0;
    final totalSpent =
        double.tryParse(json['total_spent']?.toString() ?? '0') ?? 0.0;
    final remainingBudget =
        double.tryParse(json['remaining_budget']?.toString() ?? '0') ?? 0.0;
    final percentageUsed = (json['percentage_used'] as num?)?.toDouble() ??
        (budgetCap > 0 ? (totalSpent / budgetCap * 100) : 0.0);
    final count = json['item_count'] as int? ??
        json['contributing_members_count'] as int? ??
        1;

    return ConjoinedEventSummary(
      id: id,
      title: title,
      budgetCap: budgetCap,
      totalSpent: totalSpent,
      remainingBudget: remainingBudget,
      percentageUsed: percentageUsed,
      contributingMembersCount: count,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'budget_cap': budgetCap,
    'total_spent': totalSpent,
    'remaining_budget': remainingBudget,
    'percentage_used': percentageUsed,
    'contributing_members_count': contributingMembersCount,
  };
}
