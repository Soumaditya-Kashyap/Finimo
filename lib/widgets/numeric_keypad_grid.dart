import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class NumericKeypadGrid extends StatelessWidget {
  final ValueChanged<String> onKeyPress;
  final VoidCallback onBackspace;

  const NumericKeypadGrid({
    super.key,
    required this.onKeyPress,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 8),
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 8),
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 8),
        _buildBottomRow(),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKeyButton(
              child: Text(
                key,
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  fontSize: 20,
                ),
              ),
              onTap: () => onKeyPress(key),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Dot (.)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKeyButton(
              child: Text(
                '.',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  fontSize: 22,
                ),
              ),
              onTap: () => onKeyPress('.'),
            ),
          ),
        ),
        // Zero (0)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKeyButton(
              child: Text(
                '0',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  fontSize: 20,
                ),
              ),
              onTap: () => onKeyPress('0'),
            ),
          ),
        ),
        // Backspace
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildKeyButton(
              child: const Icon(
                Icons.backspace_outlined,
                color: AppColors.textPrimary,
                size: 20,
              ),
              onTap: onBackspace,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surface01,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.ghostBorder, width: 0.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}
