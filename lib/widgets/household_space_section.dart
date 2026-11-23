import 'package:flutter/material.dart';
import '../models/user_profile_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class HouseholdSpaceSection extends StatelessWidget {
  final UserProfileData profile;
  final VoidCallback? onEditFamilyTap;
  final VoidCallback? onEditCurrencyTap;
  final VoidCallback? onAddMemberTap;
  final VoidCallback? onViewMembersTap;

  const HouseholdSpaceSection({
    super.key,
    required this.profile,
    this.onEditFamilyTap,
    this.onEditCurrencyTap,
    this.onAddMemberTap,
    this.onViewMembersTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FAMILY SETTINGS',
              style: AppTypography.caption(
                color: AppColors.textMuted,
              ).copyWith(
                fontSize: 11,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              'FINIMO CIRCLE',
              style: TextStyle(
                fontFamily: 'SpaceGrotesk',
                color: AppColors.primaryFixed,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Main Container wrapping the 3 cards
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface01,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 1. Family Name Row
              _buildEntityTile(
                icon: Icons.home_outlined,
                label: 'FAMILY NAME',
                value: profile.familyEntityName,
                onTap: onEditFamilyTap,
                trailingAction: GestureDetector(
                  onTap: onEditFamilyTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface03.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 2. Currency & Timezone Row
              _buildEntityTile(
                icon: Icons.public_outlined,
                iconColor: AppColors.tertiaryFixed,
                label: 'CURRENCY & TIMEZONE',
                value: profile.localeAndBasis,
                onTap: onEditCurrencyTap,
                trailingAction: GestureDetector(
                  onTap: onEditCurrencyTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface03.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 3. Access Scope Card with Direct View & Add Member Actions
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface02,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    InkWell(
                      onTap: onViewMembersTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface03,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.groups_outlined,
                              size: 20,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FAMILY ACCESS',
                                  style: AppTypography.caption(
                                    color: AppColors.textMuted,
                                  ).copyWith(
                                    fontSize: 10,
                                    letterSpacing: 1.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  profile.accessScope,
                                  style: AppTypography.headlineSm(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ).copyWith(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          // Role / Scope Tag
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  profile.accessScopeBadge,
                                  style: AppTypography.caption(
                                    color: AppColors.textMuted,
                                  ).copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Two Balanced Actions: [View Members] & [+ Add Member]
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: onViewMembersTap,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surface03,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_outline_rounded,
                                    size: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'View Members',
                                    style: AppTypography.bodySm(
                                      color: AppColors.textPrimary,
                                    ).copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: onAddMemberTap,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F2B2E),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.tertiaryFixedDim.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_add_alt_outlined,
                                    size: 15,
                                    color: AppColors.tertiaryFixed,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '+ Add Member',
                                    style: AppTypography.bodySm(
                                      color: AppColors.tertiaryFixed,
                                    ).copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntityTile({
    required IconData icon,
    Color iconColor = AppColors.textPrimary,
    required String label,
    required String value,
    VoidCallback? onTap,
    Widget? trailingAction,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface02,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface03,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(
                      fontSize: 10,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 16),
                  ),
                ],
              ),
            ),
            ?trailingAction,
          ],
        ),
      ),
    );
  }
}
