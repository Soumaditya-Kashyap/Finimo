class TargetsDashboardData {
  final double budgetRemainingPct; // 74%
  final double budgetRemainingAmount; // ₹42,120
  final double safeCapAmount; // ₹58,000
  final int daysLeft; // 18
  final double pacingProgress; // 0.82
  final double runwayProgress; // 0.74

  const TargetsDashboardData({
    required this.budgetRemainingPct,
    required this.budgetRemainingAmount,
    required this.safeCapAmount,
    required this.daysLeft,
    required this.pacingProgress,
    required this.runwayProgress,
  });

  factory TargetsDashboardData.fromJson(Map<String, dynamic> json) {
    return TargetsDashboardData(
      budgetRemainingPct: (json['budget_remaining_pct'] as num).toDouble(),
      budgetRemainingAmount: (json['budget_remaining_amount'] as num).toDouble(),
      safeCapAmount: (json['safe_cap_amount'] as num).toDouble(),
      daysLeft: json['days_left'] as int? ?? 18,
      pacingProgress: (json['pacing_progress'] as num?)?.toDouble() ?? 0.82,
      runwayProgress: (json['runway_progress'] as num?)?.toDouble() ?? 0.74,
    );
  }

  Map<String, dynamic> toJson() => {
    'budget_remaining_pct': budgetRemainingPct,
    'budget_remaining_amount': budgetRemainingAmount,
    'safe_cap_amount': safeCapAmount,
    'days_left': daysLeft,
    'pacing_progress': pacingProgress,
    'runway_progress': runwayProgress,
  };
}
