import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FamilyOrbitSelector extends StatelessWidget {
  final List<FamilyMember> members;
  final String selectedLabel;
  final String? selectedMemberId;
  final VoidCallback? onTap;

  const FamilyOrbitSelector({
    super.key,
    required this.members,
    this.selectedLabel = 'Family (All)',
    this.selectedMemberId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFamilyScope = selectedMemberId == null ||
        selectedLabel.toLowerCase().contains('family');

    FamilyMember? selectedMember;
    if (!isFamilyScope) {
      for (final m in members) {
        if (m.id == selectedMemberId || m.name == selectedLabel) {
          selectedMember = m;
          break;
        }
      }
    }

    final vaultTitle = isFamilyScope
        ? 'Family Vault'
        : (selectedMember != null
            ? '${selectedMember.name}\'s Vault'
            : '$selectedLabel\'s Vault');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Title Lockup
        Expanded(
          child: Column(
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
                vaultTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

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
                _buildAvatarGroup(isFamilyScope, selectedMember),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    selectedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildAvatarGroup(bool isFamilyScope, FamilyMember? selectedMember) {
    if (!isFamilyScope) {
      // Single Selected Member Avatar
      final initial = selectedMember?.initial ??
          (selectedLabel.isNotEmpty ? selectedLabel[0].toUpperCase() : 'U');
      return _buildAvatarBadge(
        initial: initial,
        bgColor: AppColors.secondaryContainer,
        textColor: AppColors.secondary,
      );
    }

    // Family Scope: Render actual available members
    if (members.isEmpty) {
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.surface03,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface02, width: 1.5),
        ),
        child: const Center(
          child: Icon(
            Icons.group_rounded,
            color: AppColors.primaryFixed,
            size: 13,
          ),
        ),
      );
    }

    final displayMembers = members.take(3).toList();
    final badgeColors = [
      (AppColors.secondaryContainer, AppColors.secondary),
      (AppColors.onTertiaryContainer, AppColors.tertiaryFixed),
      (AppColors.surface03, AppColors.primaryFixed),
    ];

    final stackWidth = displayMembers.length == 1
        ? 22.0
        : 22.0 + (displayMembers.length - 1) * 13.0;

    return SizedBox(
      width: stackWidth,
      height: 22,
      child: Stack(
        children: [
          for (int i = 0; i < displayMembers.length; i++)
            Positioned(
              left: i * 13.0,
              child: _buildAvatarBadge(
                initial: displayMembers[i].initial.isNotEmpty
                    ? displayMembers[i].initial
                    : (displayMembers[i].name.isNotEmpty
                        ? displayMembers[i].name[0].toUpperCase()
                        : 'M'),
                bgColor: badgeColors[i % badgeColors.length].$1,
                textColor: badgeColors[i % badgeColors.length].$2,
              ),
            ),
        ],
      ),
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
