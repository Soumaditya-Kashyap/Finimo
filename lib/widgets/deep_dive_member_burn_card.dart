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
    final progress = (member.totalPaid / member.targetCap).clamp(0.0, 1.0);

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
          // Row 1: Member Initial Avatar + Name/Role + Amount/Percentage
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
                        member.role,
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
                    '${member.percentageOfTotal.round()}% total spend',
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

          // Row 2: Progress Track
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surface02,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
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

          const SizedBox(height: 10),

          // Row 3: Target Cap & Buffer / Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Targeted Cap: ${CurrencyFormatter.formatInr(member.targetCap)}',
                style: AppTypography.bodySm(color: AppColors.textMuted),
              ),
              Text(
                member.bufferLeft > 1000
                    ? '${CurrencyFormatter.formatInr(member.bufferLeft)} buffer left'
                    : 'Near monthly ceiling',
                style: AppTypography.bodySm(
                  color: member.bufferLeft > 1000
                      ? member.accentColor
                      : AppColors.dangerCoral,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
