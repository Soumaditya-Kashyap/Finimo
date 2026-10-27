import 'package:flutter/material.dart';
import '../models/insurance_policy_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class InsuranceVaultHeroCard extends StatelessWidget {
  final InsuranceVaultOverview overview;

  const InsuranceVaultHeroCard({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F151A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.tertiaryFixedDim.withValues(alpha: 0.22),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiaryFixed.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Glowing Cyan Dot + TOTAL PROTECTION UMBRELLA + Shield Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryFixed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tertiaryFixed.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TOTAL PROTECTION UMBRELLA',
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(
                      fontSize: 10,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.shield_outlined,
                color: AppColors.tertiaryFixedDim,
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Master Metric: ₹1.25 Cr
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹1.25',
                style: AppTypography.displayLg(
                  color: AppColors.textPrimary,
                ).copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Cr',
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: AppColors.tertiaryFixed,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Coverage Badge: 👥 3 Family Members Covered · 100% Health
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 14,
                  color: AppColors.primaryFixed,
                ),
                const SizedBox(width: 6),
                Text(
                  '${overview.coveredFamilyMembersCount} Family Members Covered · 100% Health',
                  style: AppTypography.caption(
                    color: AppColors.textMuted,
                  ).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3 Bottom Telemetry Columns: Annual Cost | Next Cycle | Active Claims
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Annual Cost
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annual Cost',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '₹34.5k',
                        style: AppTypography.headlineSm(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${overview.monthlyCostEquivalent.toInt()}/mo',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),

                // 2. Next Cycle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Cycle',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        overview.nextCycleText,
                        style: AppTypography.headlineSm(
                          color: AppColors.tertiaryFixed,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        overview.nextCycleStatus,
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),

                // 3. Active Claims
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Active Claims',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${overview.activeClaimsCount} Active',
                        style: AppTypography.headlineSm(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TPA Ready',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 10),
                      ),
                    ],
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
