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

  factory TargetsDashboardData.compute({
    required List<dynamic> limits,
    required double monthlySpent,
    double? overallBudgetCap,
  }) {
    double totalCap = overallBudgetCap ?? 0.0;
    double categorySpent = 0.0;

    for (final item in limits) {
      if (item is Map<String, dynamic>) {
        final cap = double.tryParse(item['limit_amount']?.toString() ??
                item['limit_cap']?.toString() ??
                '0') ??
            0.0;
        final sp = double.tryParse(item['current_period_spent']?.toString() ??
                item['current_spent']?.toString() ??
                '0') ??
            0.0;
        if (overallBudgetCap == null || overallBudgetCap == 0) {
          totalCap += cap;
        }
        categorySpent += sp;
      } else {
        // If it's MonthlyLimitItem
        try {
          final cap = (item as dynamic).limitCap as double? ?? 0.0;
          final sp = (item as dynamic).currentSpent as double? ?? 0.0;
          if (overallBudgetCap == null || overallBudgetCap == 0) {
            totalCap += cap;
          }
          categorySpent += sp;
        } catch (_) {}
      }
    }

    final double effectiveSpent = monthlySpent > 0 ? monthlySpent : categorySpent;
    final double remaining = totalCap > effectiveSpent ? (totalCap - effectiveSpent) : 0.0;
    final double remainingPct = totalCap > 0 ? (remaining / totalCap * 100) : 0.0;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day).clamp(0, 31);
    final pacingProgress = totalCap > 0 ? (now.day / daysInMonth).clamp(0.0, 1.0) : 0.0;
    final runwayProgress = totalCap > 0 ? (effectiveSpent / totalCap).clamp(0.0, 1.0) : 0.0;

    return TargetsDashboardData(
      budgetRemainingPct: remainingPct,
      budgetRemainingAmount: remaining,
      safeCapAmount: totalCap,
      daysLeft: daysLeft,
      pacingProgress: pacingProgress,
      runwayProgress: runwayProgress,
    );
  }

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
