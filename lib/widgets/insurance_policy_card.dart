import 'package:flutter/material.dart';
import '../models/insurance_policy_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class InsurancePolicyCard extends StatelessWidget {
  final InsurancePolicyModel policy;
  final VoidCallback? onRenewTap;
  final VoidCallback? onPdfTap;
  final VoidCallback? onTpaCardTap;

  const InsurancePolicyCard({
    super.key,
    required this.policy,
    this.onRenewTap,
    this.onPdfTap,
    this.onTpaCardTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (policy.policyType) {
      case PolicyType.termLife:
        return _buildTermLifeCard();
      case PolicyType.health:
        return _buildHealthFloaterCard();
      case PolicyType.auto:
      default:
        return _buildMotorAssetCard();
    }
  }

  // Card 1: HDFC Click 2 Protect 3D Plus (TERM LIFE)
  Widget _buildTermLifeCard() {
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
          // Tag & Insured Header + Verified Shield
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F262B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.tertiaryFixedDim.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'TERM LIFE',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        color: AppColors.tertiaryFixed,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    policy.insuredMemberName,
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Icon(
                Icons.verified_outlined,
                size: 16,
                color: AppColors.tertiaryFixed,
              ),
            ],
          ),

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
                    const SizedBox(height: 4),
                    Text(
                      'Nominee: ${policy.nomineeName ?? 'Chandrani (Spouse)'}',
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(fontSize: 11),
                    ),
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
                  RichText(
                    text: TextSpan(
                      style: AppTypography.headlineSm(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 17),
                      children: const [
                        TextSpan(text: '₹1.00 '),
                        TextSpan(
                          text: 'Cr',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: AppColors.tertiaryFixed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Footer strip: Next: 18 Nov 2026 · ₹18,500/yr + PDF button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: AppColors.tertiaryFixedDim,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    policy.subDetailText ?? 'Next: 18 Nov 2026 · ₹18,500/yr',
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 11),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onPdfTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.download_rounded,
                        size: 13,
                        color: AppColors.tertiaryFixedDim,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'PDF',
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          color: AppColors.tertiaryFixedDim,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: Care Supreme Comprehensive (HEALTH FLOATER)
  Widget _buildHealthFloaterCard() {
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
          // Tag: HEALTH FLOATER + 3 Covered + Shield icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26260B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.primaryFixed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'FAMILY HEALTH',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        color: AppColors.primaryFixed,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    policy.insuredMemberName,
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Icon(
                Icons.shield_outlined,
                size: 16,
                color: AppColors.primaryFixed,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Policy Title & Sum Insured: ₹25 +Unltd L
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
                    const SizedBox(height: 4),
                    Text(
                      policy.nomineeName ?? 'Arpa, Chandrani & Aryahi',
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sum Insured',
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.headlineSm(
                        color: AppColors.primaryFixed,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 17),
                      children: const [
                        TextSpan(text: '₹25'),
                        TextSpan(
                          text: ' +Unltd\n',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: AppColors.primaryFixed,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: 'L',
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: AppColors.primaryFixed,
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Sub Features: 14,000+ Cashless Hospitals · Zero Room Cap
          Row(
            children: [
              const Icon(
                Icons.add_box_outlined,
                size: 13,
                color: AppColors.primaryFixed,
              ),
              const SizedBox(width: 6),
              Text(
                policy.subDetailText ??
                    '14,000+ Cashless Hospitals · Zero Room Cap',
                style: AppTypography.caption(
                  color: AppColors.textMuted,
                ).copyWith(fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // CTA Strip: Instant Cashless TPA Card [QR Icon]
          GestureDetector(
            onTap: onTpaCardTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF131713),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryFixed.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 16,
                        color: AppColors.primaryFixed,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Cashless Health Card',
                        style: AppTypography.bodySm(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.qr_code_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 3: Tata AIG Comprehensive Cover (MOTOR ASSET)
  Widget _buildMotorAssetCard() {
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
          // Header: MOTOR ASSET + Creta · AS-01-EF-4291 + Car Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF281313),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.dangerCoral.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'VEHICLE COVER',
                      style: TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        color: AppColors.dangerCoral,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    policy.insuredMemberName,
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const Icon(
                Icons.directions_car_outlined,
                size: 16,
                color: AppColors.dangerCoral,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Red Warning Banner: Action Required · Expiry in 12 days
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
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
                  'Action Required · Expiry in ${policy.expiryDaysLeft ?? 12} days',
                  style: AppTypography.caption(
                    color: AppColors.dangerCoral,
                  ).copyWith(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Title & Renewal Premium: ₹11,420
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
                    const SizedBox(height: 4),
                    Text(
                      policy.nomineeName ??
                          'Zero Depreciation + B2B Engine Guard',
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Renewal Premium',
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 10),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${CurrencyFormatter.format(policy.premiumAmount).replaceAll('₹', '').replaceAll('.00', '')}',
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 17),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Premium Savings Status Row: Saved for Premium: ₹12,000 | Fully Funded
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved for Premium: ₹${CurrencyFormatter.format(policy.sinkingFundBalance ?? 12000).replaceAll('₹', '').replaceAll('.00', '')}',
                style: AppTypography.caption(
                  color: AppColors.textMuted,
                ).copyWith(fontSize: 11),
              ),
              Text(
                'Fully Funded',
                style: AppTypography.caption(
                  color: AppColors.primaryFixed,
                ).copyWith(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Renew Now · ₹11,420 ⚡ CTA Button
          GestureDetector(
            onTap: onRenewTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryFixed.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Renew Now · ₹${CurrencyFormatter.format(policy.premiumAmount).replaceAll('₹', '').replaceAll('.00', '')}',
                    style: AppTypography.headlineSm(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ).copyWith(fontSize: 14),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.bolt_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
