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
      consolidatedLiquidity: (json['consolidated_liquidity'] as num).toDouble(),
      jointAccountsCount: json['joint_accounts_count'] as int? ?? 4,
      monthlyInflow: (json['monthly_inflow'] as num).toDouble(),
      monthlySpent: (json['monthly_spent'] as num).toDouble(),
      dailySafeBurn: (json['daily_safe_burn'] as num).toDouble(),
      livePingSeconds: json['live_ping_seconds'] as String? ?? '04S',
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
