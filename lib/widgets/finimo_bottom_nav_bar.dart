import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

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
    final bottomSafePadding = MediaQuery.viewPaddingOf(context).bottom > 0
        ? MediaQuery.viewPaddingOf(context).bottom
        : MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface01, // 100% solid, opaque
        border: Border(
          top: BorderSide(
            color: Color(0x1AFFFFFF), // Clean 0.5px subtle hairline top border
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        top: 10,
        bottom: bottomSafePadding > 0 ? bottomSafePadding : 10,
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
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.primaryFixed : AppColors.textMuted;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isSelected) {
            HapticFeedback.lightImpact();
            onTabSelected(index);
          }
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
