import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class QuickActionGrid extends StatelessWidget {
  final VoidCallback? onExpenseTap;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onEventBillTap;
  final VoidCallback? onPolicyTap;

  const QuickActionGrid({
    super.key,
    this.onExpenseTap,
    this.onIncomeTap,
    this.onEventBillTap,
    this.onPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1: Expense (Primary Kinetic Lime) + Income (Surface 02)
        Row(
          children: [
            // Expense Button
            Expanded(
              child: _buildExpenseButton(
                onTap: onExpenseTap,
              ),
            ),
            const SizedBox(width: 10),
            // Income Button
            Expanded(
              child: _buildSecondaryButton(
                title: 'Income',
                subtitle: 'Salary & Inflow',
                subtitleColor: AppColors.textMuted,
                icon: Icons.south_west_rounded,
                iconColor: AppColors.primaryFixed,
                iconBgColor: AppColors.surface03,
                onTap: onIncomeTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Row 2: Event Expense (Festival & Trips) + Policy (Term & Health)
        Row(
          children: [
            // Event Expense Button
            Expanded(
              child: _buildSecondaryButton(
                title: 'Event Expense',
                subtitle: 'Festival & Trips',
                subtitleColor: AppColors.secondary,
                icon: Icons.celebration_rounded,
                iconColor: AppColors.secondary,
                iconBgColor: AppColors.purpleSubtle,
                onTap: onEventBillTap,
              ),
            ),
            const SizedBox(width: 10),
            // Policy Button
            Expanded(
              child: _buildSecondaryButton(
                title: 'Policy',
                subtitle: 'Term & Health',
                subtitleColor: AppColors.tertiaryFixed,
                icon: Icons.shield_outlined,
                iconColor: AppColors.tertiaryFixed,
                iconBgColor: AppColors.surface03,
                onTap: onPolicyTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Primary Kinetic Action Button: Electric Lime
  Widget _buildExpenseButton({required VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryFixed.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Expense',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineSm(
                      color: AppColors.canvasBase,
                      fontWeight: FontWeight.w700,
                    ).copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Daily Spend',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSm(
                      color: AppColors.canvasBase.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.canvasBase,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.primaryFixed,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface02,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.ghostBorder, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSm(
                      color: subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 19,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
