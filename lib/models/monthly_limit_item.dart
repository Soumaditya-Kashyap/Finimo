import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'transaction_category.dart';

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
  final String? categoryId;
  final String? timeFrame;
  final int? notifyThresholdPct;

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
    this.categoryId,
    this.timeFrame,
    this.notifyThresholdPct,
  });

  factory MonthlyLimitItem.fromApiResponse(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '';
    final title = json['target_name']?.toString() ??
        json['title']?.toString() ??
        'Target Limit';

    final limitCap = double.tryParse(
            json['limit_amount']?.toString() ?? json['limit_cap']?.toString() ?? '0') ??
        0.0;
    final currentSpent = double.tryParse(json['current_period_spent']?.toString() ??
            json['current_spent']?.toString() ??
            '0') ??
        0.0;

    final percentageUsed = (json['percentage_consumed'] as num?)?.toDouble() ??
        (json['percentage_used'] as num?)?.toDouble() ??
        (limitCap > 0 ? (currentSpent / limitCap * 100) : 0.0);

    final notifyPct = (json['notify_threshold_pct'] as num?)?.toInt() ?? 80;
    final isWarning = percentageUsed >= notifyPct;

    final buffer = limitCap - currentSpent;
    final String statusText;
    if (buffer > 0) {
      statusText = '₹${CurrencyFormatter.formatInr(buffer)} buffer';
    } else if (buffer == 0) {
      statusText = 'Limit reached';
    } else {
      statusText = '₹${CurrencyFormatter.formatInr(buffer.abs())} exceeded';
    }

    final String footerStatus;
    if (percentageUsed >= 95) {
      footerStatus = 'Limit exceeded alert';
    } else if (percentageUsed >= 80) {
      footerStatus = 'Watch spend pace';
    } else if (percentageUsed >= 50) {
      footerStatus = 'Pacing moderate';
    } else {
      footerStatus = 'Stable outflow velocity';
    }

    final category = json['category'] as Map<String, dynamic>? ?? {};
    final categoryId = json['category_id']?.toString();
    final iconKey = category['icon_key']?.toString();
    final colorHex = category['color_hex']?.toString();

    final icon = iconKey != null && iconKey.isNotEmpty
        ? TransactionCategory.getIconFromKey(iconKey)
        : Icons.roofing_outlined;

    final accentColor = isWarning
        ? AppColors.dangerCoral
        : (colorHex != null && colorHex.isNotEmpty
            ? TransactionCategory.getColorFromHex(colorHex)
            : AppColors.primaryFixed);

    return MonthlyLimitItem(
      id: id,
      title: title,
      limitCap: limitCap,
      currentSpent: currentSpent,
      percentageUsed: percentageUsed,
      statusText: statusText,
      footerStatus: footerStatus,
      accentColor: accentColor,
      icon: icon,
      isWarning: isWarning,
      categoryId: categoryId,
      timeFrame: json['time_frame']?.toString(),
      notifyThresholdPct: notifyPct,
    );
  }

  factory MonthlyLimitItem.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('target_name') || json.containsKey('percentage_consumed')) {
      return MonthlyLimitItem.fromApiResponse(json);
    }
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
      categoryId: json['category_id'] as String?,
      timeFrame: json['time_frame'] as String?,
      notifyThresholdPct: json['notify_threshold_pct'] as int?,
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
        'category_id': categoryId,
        'time_frame': timeFrame,
        'notify_threshold_pct': notifyThresholdPct,
      };
}
