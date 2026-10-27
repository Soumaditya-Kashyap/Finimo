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
    return ConjoinedEventSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      budgetCap: (json['budget_cap'] as num).toDouble(),
      totalSpent: (json['total_spent'] as num).toDouble(),
      remainingBudget: (json['remaining_budget'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
      contributingMembersCount: json['contributing_members_count'] as int? ?? 3,
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
