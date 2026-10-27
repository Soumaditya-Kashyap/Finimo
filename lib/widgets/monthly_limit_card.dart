import 'package:flutter/material.dart';
import '../models/monthly_limit_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class MonthlyLimitCard extends StatelessWidget {
  final MonthlyLimitItem item;

  const MonthlyLimitCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ghostBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Row 1: Icon + Title & Spend + Buffer Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: AppColors.surface02,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: item.accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.bodyLg(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${CurrencyFormatter.formatInr(item.limitCap)} Cap • ${CurrencyFormatter.formatInr(item.currentSpent)} spent',
                        style: AppTypography.bodySm(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),

              // Status buffer chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface02,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  item.statusText,
                  style: AppTypography.labelMd(
                    color: item.accentColor,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 2: Linear Neon Progress Track
          Container(
            width: double.infinity,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.surface02,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (item.percentageUsed / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: item.accentColor,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: item.accentColor.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Row 3: Percentage Used & Status Description
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.percentageUsed.round()}% used',
                style: AppTypography.bodySm(
                  color: item.isWarning ? AppColors.dangerCoral : AppColors.textMuted,
                ),
              ),
              Row(
                children: [
                  if (item.isWarning) ...[
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.dangerCoral,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    item.footerStatus,
                    style: AppTypography.bodySm(
                      color: item.isWarning ? AppColors.dangerCoral : AppColors.textMuted,
                    ).copyWith(
                      fontWeight: item.isWarning ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
