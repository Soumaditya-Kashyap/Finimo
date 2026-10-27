import 'package:flutter/material.dart';

class InsightCategoryBurn {
  final String categoryName;
  final double amount;
  final double percentage; // e.g. 34.0
  final String deltaVsLastMonth; // e.g. '+4.2% vs Sep'
  final Color color;
  final IconData icon;

  const InsightCategoryBurn({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.deltaVsLastMonth,
    required this.color,
    required this.icon,
  });

  factory InsightCategoryBurn.fromJson(Map<String, dynamic> json) {
    return InsightCategoryBurn(
      categoryName: json['category_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      deltaVsLastMonth: json['delta_vs_last_month'] as String? ?? 'On schedule',
      color: const Color(0xFFC3F400),
      icon: Icons.category_outlined,
    );
  }

  Map<String, dynamic> toJson() => {
    'category_name': categoryName,
    'amount': amount,
    'percentage': percentage,
    'delta_vs_last_month': deltaVsLastMonth,
  };
}

class InsightMemberBurn {
  final String memberId;
  final String name;
  final String role; // 'Admin • Primary Earner', 'Co-Budgeter', 'Dependent Minor'
  final String initial;
  final double totalPaid;
  final double totalBenefited;
  final double percentageOfTotal; // e.g. 45.0
  final double targetCap;
  final double bufferLeft;
  final Color accentColor;

  const InsightMemberBurn({
    required this.memberId,
    required this.name,
    required this.role,
    required this.initial,
    required this.totalPaid,
    required this.totalBenefited,
    required this.percentageOfTotal,
    required this.targetCap,
    required this.bufferLeft,
    required this.accentColor,
  });

  factory InsightMemberBurn.fromJson(Map<String, dynamic> json) {
    return InsightMemberBurn(
      memberId: json['member_id'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'Member',
      initial: json['initial'] as String? ?? (json['name'] as String)[0].toUpperCase(),
      totalPaid: (json['total_paid'] as num).toDouble(),
      totalBenefited: (json['total_benefited'] as num).toDouble(),
      percentageOfTotal: (json['percentage_of_total'] as num?)?.toDouble() ?? 33.3,
      targetCap: (json['target_cap'] as num?)?.toDouble() ?? 25000.0,
      bufferLeft: (json['buffer_left'] as num?)?.toDouble() ?? 5000.0,
      accentColor: const Color(0xFFC3F400),
    );
  }

  Map<String, dynamic> toJson() => {
    'member_id': memberId,
    'name': name,
    'role': role,
    'initial': initial,
    'total_paid': totalPaid,
    'total_benefited': totalBenefited,
    'percentage_of_total': percentageOfTotal,
    'target_cap': targetCap,
    'buffer_left': bufferLeft,
  };
}

class DeepDiveSummaryData {
  final double totalOutflow;
  final String statusLabel; // 'Radar Optimal'
  final double dailyPace; // ₹1,879/day
  final int daysMonitored; // 31
  final List<InsightCategoryBurn> categories;
  final List<InsightMemberBurn> members;

  const DeepDiveSummaryData({
    required this.totalOutflow,
    required this.statusLabel,
    required this.dailyPace,
    required this.daysMonitored,
    required this.categories,
    required this.members,
  });

  factory DeepDiveSummaryData.fromJson(Map<String, dynamic> json) {
    return DeepDiveSummaryData(
      totalOutflow: (json['total_monthly_expense'] as num?)?.toDouble() ?? 58281.0,
      statusLabel: 'Radar Optimal',
      dailyPace: 1879.0,
      daysMonitored: 31,
      categories: (json['category_breakdown'] as List<dynamic>?)
              ?.map((e) => InsightCategoryBurn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      members: (json['member_breakdown'] as List<dynamic>?)
              ?.map((e) => InsightMemberBurn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'total_monthly_expense': totalOutflow,
    'category_breakdown': categories.map((e) => e.toJson()).toList(),
    'member_breakdown': members.map((e) => e.toJson()).toList(),
  };
}
