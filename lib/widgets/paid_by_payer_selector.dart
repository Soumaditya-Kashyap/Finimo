import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PaidByPayerSelector extends StatelessWidget {
  final List<FamilyMember> members;
  final String selectedMemberId;
  final ValueChanged<String> onSelected;

  const PaidByPayerSelector({
    super.key,
    required this.members,
    required this.selectedMemberId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Lockup
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Paid By',
              style: AppTypography.labelMd(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Family Account',
              style: AppTypography.labelSm(
                color: AppColors.primaryFixed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 2 Columns of Payer Cards (Arpa, Chandrani)
        Row(
          children: [
            Expanded(
              child: _buildPayerCard(
                memberId: 'm1_arpa',
                name: 'Arpa',
                role: 'Primary',
                initial: 'A',
                isSelected: selectedMemberId == 'm1_arpa',
                avatarBg: AppColors.secondaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPayerCard(
                memberId: 'm2_chandrani',
                name: 'Chandrani',
                role: 'Spouse',
                initial: 'C',
                isSelected: selectedMemberId == 'm2_chandrani',
                avatarBg: AppColors.surface03,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPayerCard({
    required String memberId,
    required String name,
    required String role,
    required String initial,
    required bool isSelected,
    required Color avatarBg,
  }) {
    return InkWell(
      onTap: () => onSelected(memberId),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface02 : AppColors.surface01,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryFixed.withValues(alpha: 0.3)
                : AppColors.ghostBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryFixed.withValues(alpha: 0.12),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Avatar with colored border if selected
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: avatarBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryFixed : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Name and role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm(
                      color: isSelected ? const Color(0xFFA6CF00) : AppColors.textMuted,
                    ).copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Radio check indicator
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primaryFixed : AppColors.textMuted.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
