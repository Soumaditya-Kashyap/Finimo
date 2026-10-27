class ActivitySummary {
  final int totalCount;
  final double netAmount;
  final double outflowAmount;
  final double inflowAmount;

  const ActivitySummary({
    required this.totalCount,
    required this.netAmount,
    required this.outflowAmount,
    required this.inflowAmount,
  });

  factory ActivitySummary.fromJson(Map<String, dynamic> json) {
    return ActivitySummary(
      totalCount: json['total_count'] as int? ?? 42,
      netAmount: (json['net_amount'] as num).toDouble(),
      outflowAmount: (json['outflow_amount'] as num).toDouble(),
      inflowAmount: (json['inflow_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_count': totalCount,
    'net_amount': netAmount,
    'outflow_amount': outflowAmount,
    'inflow_amount': inflowAmount,
  };
}
