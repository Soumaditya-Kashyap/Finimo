import 'package:flutter/material.dart';
import '../models/deep_dive_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class DeepDiveCategoryBurnCard extends StatelessWidget {
  final InsightCategoryBurn category;

  const DeepDiveCategoryBurnCard({
    super.key,
    required this.category,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Icon + Title & Percentage
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName,
                    style: AppTypography.bodyLg(
                      color: AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.percentage.round()}% of portfolio burn',
                    style: AppTypography.bodySm(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),

          // Right: Amount + Delta / Status Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.formatInr(category.amount),
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                category.deltaVsLastMonth,
                style: AppTypography.labelSm(
                  color: category.deltaVsLastMonth.startsWith('+')
                      ? const Color(0xFFA6CF00)
                      : (category.deltaVsLastMonth.startsWith('-')
                          ? const Color(0xFFA6CF00)
                          : (category.deltaVsLastMonth.contains('Seasonal')
                              ? AppColors.tertiaryFixed
                              : AppColors.textMuted)),
                  fontWeight: FontWeight.w600,
                ).copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
