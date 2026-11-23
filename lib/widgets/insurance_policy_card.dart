import 'package:flutter/material.dart';
import '../models/insurance_policy_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class InsurancePolicyCard extends StatelessWidget {
  final InsurancePolicyModel policy;
  final VoidCallback? onDeleteTap;

  const InsurancePolicyCard({
    super.key,
    required this.policy,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    Color typeBg;
    String typeLabel;
    IconData typeIcon;

    switch (policy.policyType) {
      case PolicyType.termLife:
        typeColor = AppColors.tertiaryFixed;
        typeBg = const Color(0xFF0F262B);
        typeLabel = 'TERM LIFE';
        typeIcon = Icons.verified_user_outlined;
        break;
      case PolicyType.health:
        typeColor = AppColors.primaryFixed;
        typeBg = const Color(0xFF26260B);
        typeLabel = 'HEALTH';
        typeIcon = Icons.health_and_safety_outlined;
        break;
      case PolicyType.auto:
        typeColor = AppColors.dangerCoral;
        typeBg = const Color(0xFF281313);
        typeLabel = 'VEHICLE';
        typeIcon = Icons.directions_car_outlined;
        break;
      case PolicyType.other:
        typeColor = AppColors.secondary;
        typeBg = const Color(0xFF23152E);
        typeLabel = 'ASSET';
        typeIcon = Icons.shield_outlined;
        break;
    }

    final isExpiringSoon =
        policy.daysUntilRenewal <= 30 && policy.daysUntilRenewal >= 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tag + Insured Member Name + Delete Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: typeBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: typeColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 12, color: typeColor),
                        const SizedBox(width: 4),
                        Text(
                          typeLabel,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: typeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.surface02,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      policy.insuredMemberName,
                      style: AppTypography.caption(
                        color: AppColors.textPrimary,
                      ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (onDeleteTap != null)
                IconButton(
                  onPressed: onDeleteTap,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
            ],
          ),

          // Expiry Alert if within 30 days
          if (isExpiringSoon) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF200F12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.dangerCoral.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.alarm_on_outlined,
                    size: 14,
                    color: AppColors.dangerCoral,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Renewal Action Required · Expiry in ${policy.daysUntilRenewal} days',
                    style: AppTypography.caption(
                      color: AppColors.dangerCoral,
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Policy Title & Sum Assured
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      policy.policyName,
                      style: AppTypography.headlineSm(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 15),
                    ),
                    if (policy.policyNumber != null &&
                        policy.policyNumber!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        '#${policy.policyNumber}',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sum Assured',
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    InsurancePolicyModel.formatSumAssured(policy.sumAssured),
                    style: AppTypography.headlineSm(
                      color: typeColor,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Footer strip: Renewal Date · Premium
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface02,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Renewal: ${policy.renewalDueDate.day} ${_getMonthShort(policy.renewalDueDate.month)} ${policy.renewalDueDate.year}',
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                ),
                Text(
                  '${CurrencyFormatter.formatInr(policy.premiumAmount)}/${policy.premiumFrequency.toLowerCase()}',
                  style: AppTypography.caption(
                    color: AppColors.textPrimary,
                  ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthShort(int month) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) return m[month - 1];
    return '';
  }
}
