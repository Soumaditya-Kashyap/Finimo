class TargetsDashboardData {
  final double budgetRemainingPct; // 74%
  final double budgetRemainingAmount; // ₹42,120
  final double safeCapAmount; // ₹58,000
  final int daysLeft; // 18
  final double pacingProgress; // 0.82
  final double runwayProgress; // 0.74
  final bool hasMasterBudget;
  final double allocatedCategoryAmount;
  final double unallocatedBuffer;

  const TargetsDashboardData({
    required this.budgetRemainingPct,
    required this.budgetRemainingAmount,
    required this.safeCapAmount,
    required this.daysLeft,
    required this.pacingProgress,
    required this.runwayProgress,
    this.hasMasterBudget = false,
    this.allocatedCategoryAmount = 0.0,
    this.unallocatedBuffer = 0.0,
  });

  factory TargetsDashboardData.compute({
    required List<dynamic> limits,
    required double regularMonthlySpent,
    double? masterBudgetCap,
  }) {
    double totalCap = masterBudgetCap ?? 0.0;
    double allocatedCategories = 0.0;
    bool foundMasterInLimits = masterBudgetCap != null && masterBudgetCap > 0;

    for (final item in limits) {
      final bool isMaster;
      final double cap;

      if (item is Map<String, dynamic>) {
        final catId = item['category_id']?.toString();
        isMaster = catId == null || catId.isEmpty;
        cap = double.tryParse(item['limit_amount']?.toString() ??
                item['limit_cap']?.toString() ??
                '0') ??
            0.0;
      } else {
        // MonthlyLimitItem
        isMaster = (item as dynamic).isMaster as bool? ?? false;
        cap = (item as dynamic).limitCap as double? ?? 0.0;
      }

      if (isMaster) {
        totalCap = cap;
        foundMasterInLimits = true;
      } else {
        allocatedCategories += cap;
      }
    }

    final hasMaster = foundMasterInLimits && totalCap > 0;
    final effectiveCap = hasMaster ? totalCap : 0.0;
    final unallocated = hasMaster
        ? (totalCap - allocatedCategories).clamp(0.0, double.infinity)
        : 0.0;

    final double effectiveSpent = regularMonthlySpent;
    final double remaining =
        effectiveCap > effectiveSpent ? (effectiveCap - effectiveSpent) : 0.0;
    final double remainingPct =
        effectiveCap > 0 ? (remaining / effectiveCap * 100) : 0.0;

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day).clamp(0, 31);
    final pacingProgress =
        effectiveCap > 0 ? (now.day / daysInMonth).clamp(0.0, 1.0) : 0.0;
    final runwayProgress =
        effectiveCap > 0 ? (effectiveSpent / effectiveCap).clamp(0.0, 1.0) : 0.0;

    return TargetsDashboardData(
      budgetRemainingPct: remainingPct,
      budgetRemainingAmount: remaining,
      safeCapAmount: effectiveCap,
      daysLeft: daysLeft,
      pacingProgress: pacingProgress,
      runwayProgress: runwayProgress,
      hasMasterBudget: hasMaster,
      allocatedCategoryAmount: allocatedCategories,
      unallocatedBuffer: unallocated,
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
      hasMasterBudget: json['has_master_budget'] as bool? ?? false,
      allocatedCategoryAmount:
          (json['allocated_category_amount'] as num?)?.toDouble() ?? 0.0,
      unallocatedBuffer:
          (json['unallocated_buffer'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'budget_remaining_pct': budgetRemainingPct,
        'budget_remaining_amount': budgetRemainingAmount,
        'safe_cap_amount': safeCapAmount,
        'days_left': daysLeft,
        'pacing_progress': pacingProgress,
        'runway_progress': runwayProgress,
        'has_master_budget': hasMasterBudget,
        'allocated_category_amount': allocatedCategoryAmount,
        'unallocated_buffer': unallocatedBuffer,
      };
}
