import 'package:flutter/material.dart';

class MonthlyLimitItem {
  final String id;
  final String title;
  final double limitCap;
  final double currentSpent;
  final double percentageUsed;
  final String statusText; // '₹5,800 buffer', '₹1,150 left', 'On track'
  final String footerStatus; // 'Stable outflow velocity', 'Watch spend pace', '₹3,500 cushion'
  final Color accentColor;
  final IconData icon;
  final bool isWarning;

  const MonthlyLimitItem({
    required this.id,
    required this.title,
    required this.limitCap,
    required this.currentSpent,
    required this.percentageUsed,
    required this.statusText,
    required this.footerStatus,
    required this.accentColor,
    required this.icon,
    this.isWarning = false,
  });

  factory MonthlyLimitItem.fromJson(Map<String, dynamic> json) {
    return MonthlyLimitItem(
      id: json['id'] as String,
      title: json['title'] as String,
      limitCap: (json['limit_cap'] as num).toDouble(),
      currentSpent: (json['current_spent'] as num).toDouble(),
      percentageUsed: (json['percentage_used'] as num).toDouble(),
      statusText: json['status_text'] as String,
      footerStatus: json['footer_status'] as String,
      accentColor: const Color(0xFFC3F400),
      icon: Icons.roofing_outlined,
      isWarning: json['is_warning'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'limit_cap': limitCap,
    'current_spent': currentSpent,
    'percentage_used': percentageUsed,
    'status_text': statusText,
    'footer_status': footerStatus,
    'is_warning': isWarning,
  };
}
