import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class BeneficiaryChipSelector extends StatelessWidget {
  final List<FamilyMember> members;
  final String? selectedBeneficiaryMemberId; // null represents 'Entire Family'
  final ValueChanged<String?> onSelected;
  final String title;
  final String subtitle;
  final Color activeColor;

  const BeneficiaryChipSelector({
    super.key,
    this.members = const [],
    required this.selectedBeneficiaryMemberId,
    required this.onSelected,
    this.title = 'Spent For (Whom?)',
    this.subtitle = 'Full Share',
    this.activeColor = AppColors.tertiaryFixed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Lockup
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.labelMd(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              subtitle,
              style: AppTypography.labelSm(
                color: activeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Horizontal scrollable chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // 1. Entire Family Chip (null member ID)
              _buildChip(
                label: 'Entire Family',
                isEntireFamily: true,
                isSelected: selectedBeneficiaryMemberId == null,
                onTap: () => onSelected(null),
              ),

              // 2. Dynamic Family Members
              for (final member in members) ...[
                const SizedBox(width: 8),
                _buildChip(
                  label: member.name,
                  isEntireFamily: false,
                  isSelected: selectedBeneficiaryMemberId == member.id,
                  onTap: () => onSelected(member.id),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isEntireFamily,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface02 : AppColors.surface01,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.ghostBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.18),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEntireFamily)
              Icon(
                Icons.group_rounded,
                size: 16,
                color: isSelected ? activeColor : AppColors.textMuted,
              )
            else
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? activeColor : AppColors.surface03,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMd(
                color: isSelected ? activeColor : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
