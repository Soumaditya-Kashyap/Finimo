import 'package:flutter/material.dart';
import '../models/insurance_policy_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class InsuranceVaultHeroCard extends StatelessWidget {
  final InsuranceVaultOverview overview;

  const InsuranceVaultHeroCard({
    super.key,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    // Parse umbrella amount into main number and unit
    String mainNumber = '₹0';
    String? unit;
    final total = overview.totalSumAssuredUmbrella;
    if (total >= 10000000) {
      final cr = total / 10000000;
      mainNumber = '₹${cr.toStringAsFixed(cr.truncateToDouble() == cr ? 0 : 2)}';
      unit = 'Cr';
    } else if (total >= 100000) {
      final l = total / 100000;
      mainNumber = '₹${l.toStringAsFixed(l.truncateToDouble() == l ? 0 : 1)}';
      unit = 'L';
    } else {
      mainNumber = CurrencyFormatter.formatInr(total);
    }

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
                    'TOTAL FAMILY COVER',
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

          // Master Metric: Dynamic ₹X Cr / ₹Y L
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                mainNumber,
                style: AppTypography.displayLg(
                  color: AppColors.textPrimary,
                ).copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 8),
                Text(
                  unit,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    color: AppColors.tertiaryFixed,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Coverage Badge: 👥 X Family Members Covered
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
                  overview.coveredFamilyMembersCount > 0
                      ? '${overview.coveredFamilyMembersCount} Family Members Covered'
                      : 'No Members Currently Insured',
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

          // 3 Bottom Telemetry Columns: Annual Cost | Next Renewal | Active Policies
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
                        'Annual Premium',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        CurrencyFormatter.formatInr(overview.annualCostTotal),
                        style: AppTypography.headlineSm(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

                // 2. Next Renewal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Renewal',
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
                        ).copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

                // 3. Active Policies
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Policies',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${overview.policies.length} Active',
                        style: AppTypography.headlineSm(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Live Protection',
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
