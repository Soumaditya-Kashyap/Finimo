import 'package:flutter/material.dart';
import '../models/deep_dive_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class DeepDiveMemberBurnCard extends StatelessWidget {
  final InsightMemberBurn member;

  const DeepDiveMemberBurnCard({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (member.percentageOfTotal / 100.0).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ghostBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Member Initial Avatar + Name + Spend & Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: member.accentColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        member.initial,
                        style: TextStyle(
                          color: member.accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: AppTypography.bodyLg(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Family Contributor',
                        style: AppTypography.bodySm(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),

              // Spend & Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatInr(member.totalPaid),
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${member.percentageOfTotal.round()}% of total spend',
                    style: AppTypography.labelSm(
                      color: member.accentColor,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 2: Progress Track (% Share)
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surface02,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress > 0 ? progress : 0.02,
              child: Container(
                decoration: BoxDecoration(
                  color: member.accentColor,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: member.accentColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Row 3: Paid vs Benefited Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.arrow_upward_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Paid: ${CurrencyFormatter.formatInr(member.totalPaid)}',
                    style: AppTypography.bodySm(
                      color: AppColors.textPrimary,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.arrow_downward_rounded,
                    size: 14,
                    color: AppColors.primaryFixed,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Benefited: ${CurrencyFormatter.formatInr(member.totalBenefited)}',
                    style: AppTypography.bodySm(
                      color: AppColors.primaryFixed,
                    ).copyWith(fontWeight: FontWeight.w600, fontSize: 12),
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
