import 'package:flutter/material.dart';
import '../models/insurance_policy_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class InsurancePolicyCard extends StatelessWidget {
  final InsurancePolicyModel policy;
  final VoidCallback? onDeleteTap;
  final VoidCallback? onRecordPaymentTap;

  const InsurancePolicyCard({
    super.key,
    required this.policy,
    this.onDeleteTap,
    this.onRecordPaymentTap,
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

    final isOverdue = policy.isOverdue;
    final isExpiringSoon = policy.isExpiringSoon;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isOverdue
              ? AppColors.dangerCoral.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.05),
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

          // Overdue / Expiry Alert Banner
          if (isOverdue) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2E0F14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.dangerCoral.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 15,
                    color: AppColors.dangerCoral,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'POLICY EXPIRED · Overdue by ${policy.daysUntilRenewal.abs()} days',
                      style: AppTypography.caption(
                        color: AppColors.dangerCoral,
                      ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (isExpiringSoon) ...[
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
                  Expanded(
                    child: Text(
                      'Renewal Action Required · Expiry in ${policy.daysUntilRenewal} days',
                      style: AppTypography.caption(
                        color: AppColors.dangerCoral,
                      ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
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

          // Optional Tenure & Installment Tracker (if tenure > 1 year)
          if (policy.tenureYears != null && policy.tenureYears! > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tenure: Year ${policy.currentYear} of ${policy.tenureYears}',
                  style: AppTypography.caption(
                    color: AppColors.textMuted,
                  ).copyWith(fontSize: 10),
                ),
                if (policy.totalPaidAmount != null &&
                    policy.totalPaidAmount! > 0)
                  Text(
                    'Paid: ${CurrencyFormatter.formatInr(policy.totalPaidAmount!)}',
                    style: AppTypography.caption(
                      color: AppColors.tertiaryFixed,
                    ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ((policy.installmentsPaid ?? 0) / policy.tenureYears!)
                    .clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: AppColors.surface02,
                valueColor: AlwaysStoppedAnimation<Color>(typeColor),
              ),
            ),
          ],

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
                        color: isOverdue ? AppColors.dangerCoral : AppColors.textMuted,
                      ).copyWith(
                        fontSize: 11,
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                      ),
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

          // Action Button: Record Payment
          if (onRecordPaymentTap != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: onRecordPaymentTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOverdue
                      ? AppColors.dangerCoral
                      : isExpiringSoon
                          ? AppColors.primaryFixed
                          : AppColors.surface02,
                  foregroundColor: isOverdue
                      ? Colors.white
                      : isExpiringSoon
                          ? AppColors.canvasBase
                          : AppColors.textPrimary,
                  elevation: 0,
                  side: BorderSide(
                    color: isOverdue
                        ? AppColors.dangerCoral
                        : isExpiringSoon
                            ? AppColors.primaryFixed
                            : AppColors.ghostBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                icon: Icon(
                  Icons.bolt_rounded,
                  size: 16,
                  color: isOverdue
                      ? Colors.white
                      : isExpiringSoon
                          ? AppColors.canvasBase
                          : AppColors.primaryFixed,
                ),
                label: Text(
                  isOverdue
                      ? 'Pay Overdue Premium'
                      : isExpiringSoon
                          ? 'Renew & Record Payment'
                          : 'Record Premium Payment',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: isOverdue
                        ? Colors.white
                        : isExpiringSoon
                            ? AppColors.canvasBase
                            : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
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
