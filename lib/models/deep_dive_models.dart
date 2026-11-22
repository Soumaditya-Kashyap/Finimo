import 'package:flutter/material.dart';
import '../models/transaction_category.dart';
import '../theme/app_colors.dart';

double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

Color _getCategoryColor(String name, int index) {
  final lower = name.toLowerCase();
  if (lower.contains('dining') || lower.contains('food')) {
    return const Color(0xFFF59E0B);
  }
  if (lower.contains('garment') || lower.contains('cloth')) {
    return const Color(0xFF8B5CF6);
  }
  if (lower.contains('grocer')) {
    return const Color(0xFF10B981);
  }
  if (lower.contains('household') || lower.contains('home')) {
    return const Color(0xFF3B82F6);
  }
  if (lower.contains('medical') || lower.contains('health')) {
    return const Color(0xFFFF453A);
  }
  if (lower.contains('utilit') || lower.contains('electricity')) {
    return const Color(0xFFFFD60A);
  }
  if (lower.contains('transport') || lower.contains('fuel')) {
    return const Color(0xFF30D158);
  }
  if (lower.contains('entertain')) {
    return const Color(0xFF64D2FF);
  }
  if (lower.contains('educat')) {
    return const Color(0xFFBF5AF2);
  }
  if (lower.contains('festival')) {
    return const Color(0xFFFF375F);
  }
  if (lower.contains('insurance')) {
    return const Color(0xFF63F7FF);
  }

  const fallbackColors = [
    AppColors.primaryFixed,
    AppColors.secondary,
    AppColors.tertiaryFixed,
    Color(0xFFFFAA00),
    Color(0xFF00E5FF),
    Color(0xFFBF5AF2),
  ];
  return fallbackColors[index % fallbackColors.length];
}

class InsightCategoryBurn {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage; // e.g. 36.4
  final Color color;
  final IconData icon;

  const InsightCategoryBurn({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  factory InsightCategoryBurn.fromApiResponse(
    Map<String, dynamic> json, {
    int colorIndex = 0,
  }) {
    final catId = json['category_id']?.toString() ?? '';
    final name = json['category_name']?.toString() ?? 'General';
    final amount = _parseDouble(json['amount']);
    final percentage = _parseDouble(json['percentage']);

    final icon = TransactionCategory.getIconFromKey(name);
    final color = _getCategoryColor(name, colorIndex);

    return InsightCategoryBurn(
      categoryId: catId,
      categoryName: name,
      amount: amount,
      percentage: percentage,
      color: color,
      icon: icon,
    );
  }

  factory InsightCategoryBurn.fromJson(Map<String, dynamic> json) =>
      InsightCategoryBurn.fromApiResponse(json);

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'category_name': categoryName,
        'amount': amount,
        'percentage': percentage,
      };
}

class InsightMemberBurn {
  final String memberId;
  final String name;
  final String initial;
  final double totalPaid;
  final double totalBenefited;
  final double percentageOfTotal; // e.g. 45.0
  final Color accentColor;

  const InsightMemberBurn({
    required this.memberId,
    required this.name,
    required this.initial,
    required this.totalPaid,
    required this.totalBenefited,
    required this.percentageOfTotal,
    required this.accentColor,
  });

  factory InsightMemberBurn.fromApiResponse(
    Map<String, dynamic> json, {
    double totalFamilySpend = 0.0,
    int colorIndex = 0,
  }) {
    final memberId = json['member_id']?.toString() ?? '';
    final name = json['name']?.toString() ?? 'Member';
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'M';
    final paid = _parseDouble(json['total_paid']);
    final benefited = _parseDouble(json['total_benefited']);

    double percentage = 0.0;
    if (totalFamilySpend > 0 && paid > 0) {
      percentage = (paid / totalFamilySpend) * 100.0;
    }

    const memberColors = [
      AppColors.primaryFixed,
      AppColors.secondary,
      AppColors.tertiaryFixed,
      Color(0xFFFFAA00),
      Color(0xFF00E5FF),
      Color(0xFFBF5AF2),
    ];
    final color = memberColors[colorIndex % memberColors.length];

    return InsightMemberBurn(
      memberId: memberId,
      name: name,
      initial: initial,
      totalPaid: paid,
      totalBenefited: benefited,
      percentageOfTotal: percentage,
      accentColor: color,
    );
  }

  factory InsightMemberBurn.fromJson(Map<String, dynamic> json) =>
      InsightMemberBurn.fromApiResponse(json);

  Map<String, dynamic> toJson() => {
        'member_id': memberId,
        'name': name,
        'total_paid': totalPaid,
        'total_benefited': totalBenefited,
        'percentage_of_total': percentageOfTotal,
      };
}

class EventSummaryItem {
  final String eventId;
  final String title;
  final double totalSpent;
  final double budgetCap;

  const EventSummaryItem({
    required this.eventId,
    required this.title,
    required this.totalSpent,
    required this.budgetCap,
  });

  factory EventSummaryItem.fromJson(Map<String, dynamic> json) {
    return EventSummaryItem(
      eventId: json['event_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Event',
      totalSpent: _parseDouble(json['total_spent']),
      budgetCap: _parseDouble(json['budget_cap']),
    );
  }

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'title': title,
        'total_spent': totalSpent,
        'budget_cap': budgetCap,
      };
}

class DeepDiveSummaryData {
  final int month;
  final int year;
  final String timezone;
  final double totalOutflow;
  final double totalIncome;
  final double consolidatedLiquidity;
  final double? dailySafeToSpend;
  final int? budgetHealthScorePct;
  final List<InsightCategoryBurn> categories;
  final List<InsightMemberBurn> members;
  final List<EventSummaryItem> eventSummaries;

  const DeepDiveSummaryData({
    required this.month,
    required this.year,
    required this.timezone,
    required this.totalOutflow,
    required this.totalIncome,
    required this.consolidatedLiquidity,
    this.dailySafeToSpend,
    this.budgetHealthScorePct,
    required this.categories,
    required this.members,
    this.eventSummaries = const [],
  });

  factory DeepDiveSummaryData.fromApiResponse(Map<String, dynamic> json) {
    final period = json['period'] is Map<String, dynamic>
        ? json['period'] as Map<String, dynamic>
        : <String, dynamic>{};
    final month = period['month'] as int? ?? DateTime.now().month;
    final year = period['year'] as int? ?? DateTime.now().year;
    final timezone = period['timezone'] as String? ?? 'UTC';

    final totalOutflow = _parseDouble(json['total_monthly_expense']);
    final totalIncome = _parseDouble(json['total_monthly_income']);
    final consolidatedLiquidity = _parseDouble(json['consolidated_liquidity']);
    final dailySafe = json['daily_safe_to_spend'] != null
        ? _parseDouble(json['daily_safe_to_spend'])
        : null;
    final healthScore = _parseInt(json['budget_health_score_pct']);

    final rawCategories = json['category_breakdown'] as List<dynamic>? ?? [];
    final categories = <InsightCategoryBurn>[];
    for (int i = 0; i < rawCategories.length; i++) {
      if (rawCategories[i] is Map<String, dynamic>) {
        categories.add(
          InsightCategoryBurn.fromApiResponse(
            rawCategories[i] as Map<String, dynamic>,
            colorIndex: i,
          ),
        );
      }
    }

    final rawMembers = json['member_breakdown'] as List<dynamic>? ?? [];
    final members = <InsightMemberBurn>[];
    for (int i = 0; i < rawMembers.length; i++) {
      if (rawMembers[i] is Map<String, dynamic>) {
        members.add(
          InsightMemberBurn.fromApiResponse(
            rawMembers[i] as Map<String, dynamic>,
            totalFamilySpend: totalOutflow,
            colorIndex: i,
          ),
        );
      }
    }

    final rawEvents = json['event_summaries'] as List<dynamic>? ?? [];
    final eventSummaries = <EventSummaryItem>[];
    for (final e in rawEvents) {
      if (e is Map<String, dynamic>) {
        eventSummaries.add(EventSummaryItem.fromJson(e));
      }
    }

    return DeepDiveSummaryData(
      month: month,
      year: year,
      timezone: timezone,
      totalOutflow: totalOutflow,
      totalIncome: totalIncome,
      consolidatedLiquidity: consolidatedLiquidity,
      dailySafeToSpend: dailySafe,
      budgetHealthScorePct: healthScore,
      categories: categories,
      members: members,
      eventSummaries: eventSummaries,
    );
  }

  factory DeepDiveSummaryData.fromJson(Map<String, dynamic> json) =>
      DeepDiveSummaryData.fromApiResponse(json);

  Map<String, dynamic> toJson() => {
        'period': {
          'month': month,
          'year': year,
          'timezone': timezone,
        },
        'total_monthly_expense': totalOutflow,
        'total_monthly_income': totalIncome,
        'consolidated_liquidity': consolidatedLiquidity,
        'daily_safe_to_spend': dailySafeToSpend,
        'budget_health_score_pct': budgetHealthScorePct,
        'category_breakdown': categories.map((e) => e.toJson()).toList(),
        'member_breakdown': members.map((e) => e.toJson()).toList(),
        'event_summaries': eventSummaries.map((e) => e.toJson()).toList(),
      };
}
