import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FinimoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const FinimoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.canvasBase.withValues(alpha: 0.8),
            border: const Border(
              top: BorderSide(
                color: Color(0x1AFFFFFF), // rgba(255, 255, 255, 0.1)
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: (MediaQuery.viewPaddingOf(context).bottom > 0
                    ? MediaQuery.viewPaddingOf(context).bottom
                    : MediaQuery.paddingOf(context).bottom) +
                4,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'HOME',
                icon: Icons.grid_view_rounded,
              ),
              _buildNavItem(
                index: 1,
                label: 'ACTIVITY',
                icon: Icons.swap_horiz_rounded,
              ),
              _buildNavItem(
                index: 2,
                label: 'TARGETS',
                icon: Icons.track_changes_rounded,
              ),
              _buildNavItem(
                index: 3,
                label: 'INSIGHTS',
                icon: Icons.insights_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryFixed : AppColors.textMuted;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: isSelected
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryFixed.withValues(alpha: 0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    )
                  : null,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSm(
                color: color,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ).copyWith(
                fontSize: 9.5,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
