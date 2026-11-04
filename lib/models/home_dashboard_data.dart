class HomeDashboardData {
  final double consolidatedLiquidity;
  final int jointAccountsCount;
  final double monthlyInflow;
  final double monthlySpent;
  final double dailySafeBurn;
  final String livePingSeconds;

  const HomeDashboardData({
    required this.consolidatedLiquidity,
    required this.jointAccountsCount,
    required this.monthlyInflow,
    required this.monthlySpent,
    required this.dailySafeBurn,
    required this.livePingSeconds,
  });

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    return HomeDashboardData(
      consolidatedLiquidity:
          (json['consolidated_liquidity'] as num?)?.toDouble() ??
              double.tryParse(json['consolidated_liquidity']?.toString() ?? '0') ??
              0.0,
      jointAccountsCount: json['joint_accounts_count'] as int? ?? 1,
      monthlyInflow: (json['monthly_inflow'] as num?)?.toDouble() ??
          double.tryParse(json['monthly_inflow']?.toString() ?? '0') ??
          0.0,
      monthlySpent: (json['monthly_spent'] as num?)?.toDouble() ??
          double.tryParse(json['monthly_spent']?.toString() ?? '0') ??
          0.0,
      dailySafeBurn: (json['daily_safe_burn'] as num?)?.toDouble() ??
          double.tryParse(json['daily_safe_burn']?.toString() ?? '0') ??
          0.0,
      livePingSeconds: json['live_ping_seconds'] as String? ?? '04S',
    );
  }

  factory HomeDashboardData.fromInsightsResponse(
    Map<String, dynamic> json, {
    int jointAccountsCount = 1,
  }) {
    final liquidityStr = json['consolidated_liquidity']?.toString() ?? '0';
    final incomeStr = json['total_monthly_income']?.toString() ?? '0';
    final expenseStr = json['total_monthly_expense']?.toString() ?? '0';
    final safeBurnStr = json['daily_safe_to_spend']?.toString();

    final liquidity = double.tryParse(liquidityStr) ?? 0.0;
    final income = double.tryParse(incomeStr) ?? 0.0;
    final spent = double.tryParse(expenseStr) ?? 0.0;
    final safeBurn =
        safeBurnStr != null ? (double.tryParse(safeBurnStr) ?? 0.0) : 0.0;

    return HomeDashboardData(
      consolidatedLiquidity: liquidity,
      jointAccountsCount: jointAccountsCount,
      monthlyInflow: income,
      monthlySpent: spent,
      dailySafeBurn: safeBurn,
      livePingSeconds: '04S',
    );
  }

  Map<String, dynamic> toJson() => {
    'consolidated_liquidity': consolidatedLiquidity,
    'joint_accounts_count': jointAccountsCount,
    'monthly_inflow': monthlyInflow,
    'monthly_spent': monthlySpent,
    'daily_safe_burn': dailySafeBurn,
    'live_ping_seconds': livePingSeconds,
  };
}
