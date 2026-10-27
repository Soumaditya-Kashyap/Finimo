import 'package:flutter/material.dart';
import '../models/activity_summary.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class ActivityTelemetryStrip extends StatelessWidget {
  final ActivitySummary summary;

  const ActivityTelemetryStrip({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final total = summary.outflowAmount + summary.inflowAmount;
    final outflowRatio = total > 0 ? (summary.outflowAmount / total) : 0.24;
    final inflowRatio = total > 0 ? (summary.inflowAmount / total) : 0.76;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ghostBorder, width: 1),
      ),
      child: Column(
        children: [
          // Top Row: Total Activity & Net
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TOTAL ACTIVITY • ${summary.totalCount} TRANSACTIONS',
                    style: AppTypography.labelSm(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ).copyWith(
                      fontSize: 10,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Text(
                'NET: +${CurrencyFormatter.formatInr(summary.netAmount)}',
                style: AppTypography.labelMd(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Middle Numbers Row: Outflow vs Inflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Outflow',
                    style: AppTypography.bodySm(color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.formatInr(summary.outflowAmount),
                    style: AppTypography.headlineSm(
                      color: AppColors.dangerCoral,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 18),
                  ),
                ],
              ),
              Container(
                height: 16,
                width: 1,
                color: AppColors.surface03,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    'Inflow',
                    style: AppTypography.bodySm(color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+${CurrencyFormatter.formatInr(summary.inflowAmount)}',
                    style: AppTypography.headlineSm(
                      color: AppColors.primaryFixed,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Micro Dual-Color Velocity Bar
          Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surface02,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: (outflowRatio * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.dangerCoral,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                Expanded(
                  flex: (inflowRatio * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
