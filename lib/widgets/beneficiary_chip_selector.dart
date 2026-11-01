import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class BeneficiaryChipSelector extends StatelessWidget {
  final String selectedBeneficiary;
  final ValueChanged<String> onSelected;

  const BeneficiaryChipSelector({
    super.key,
    required this.selectedBeneficiary,
    required this.onSelected,
  });

  static const List<String> beneficiaries = [
    'Entire Family',
    'Arpa',
    'Chandrani',
    'Aryahi',
  ];

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
              'Spent For (Whom?)',
              style: AppTypography.labelMd(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Full Share',
              style: AppTypography.labelSm(
                color: AppColors.tertiaryFixed,
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
            children: beneficiaries.map((b) {
              final isSelected = selectedBeneficiary == b;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onSelected(b),
                  borderRadius: BorderRadius.circular(9999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surface02 : AppColors.surface01,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: isSelected ? AppColors.tertiaryFixed : AppColors.ghostBorder,
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.tertiaryFixed.withValues(alpha: 0.18),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (b == 'Entire Family')
                          Icon(
                            Icons.group_rounded,
                            size: 16,
                            color: isSelected ? AppColors.tertiaryFixed : AppColors.textMuted,
                          )
                        else
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.tertiaryFixed : AppColors.surface03,
                            ),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          b,
                          style: AppTypography.labelMd(
                            color: isSelected ? AppColors.tertiaryFixed : AppColors.textMuted,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
