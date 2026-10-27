import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FamilyOrbitSelector extends StatelessWidget {
  final List<FamilyMember> members;
  final String selectedLabel;
  final VoidCallback? onTap;

  const FamilyOrbitSelector({
    super.key,
    required this.members,
    this.selectedLabel = 'Family (All)',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Title Lockup
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'OPERATING ORBIT',
              style: AppTypography.labelSm(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ).copyWith(
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Family Vault',
              style: AppTypography.headlineSm(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ).copyWith(
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),

        // Right Pill Selector
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface02,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.ghostBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stacked member initials avatars
                SizedBox(
                  width: 48,
                  height: 24,
                  child: Stack(
                    children: [
                      // Avatar 1: A (Purple)
                      Positioned(
                        left: 0,
                        child: _buildAvatarBadge(
                          initial: 'A',
                          bgColor: AppColors.secondaryContainer,
                          textColor: AppColors.secondary,
                        ),
                      ),
                      // Avatar 2: C (Deep surface)
                      Positioned(
                        left: 14,
                        child: _buildAvatarBadge(
                          initial: 'C',
                          bgColor: AppColors.surface03,
                          textColor: AppColors.secondary,
                        ),
                      ),
                      // Avatar 3: R (Teal / Cyan)
                      Positioned(
                        left: 28,
                        child: _buildAvatarBadge(
                          initial: 'R',
                          bgColor: AppColors.onTertiaryContainer,
                          textColor: AppColors.tertiaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedLabel,
                  style: AppTypography.labelMd(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarBadge({
    required String initial,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface02, width: 1.5),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
