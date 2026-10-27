import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String? rightLabel;
  final String hintText;
  final TextEditingController? controller;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? helperText;
  final IconData? helperIcon;
  final VoidCallback? onRightLabelTap;

  const AuthTextField({
    super.key,
    required this.label,
    this.rightLabel,
    required this.hintText,
    this.controller,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.helperText,
    this.helperIcon,
    this.onRightLabelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Row with optional right label (e.g. Forgot Password? / PRIMARY LEDGER)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.caption(
                color: AppColors.textMuted,
              ).copyWith(
                fontSize: 11,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (rightLabel != null)
              GestureDetector(
                onTap: onRightLabelTap,
                child: Text(
                  rightLabel!,
                  style: AppTypography.caption(
                    color: AppColors.textMuted,
                  ).copyWith(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Text Field Input Squircle Container
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141419),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            children: [
              Icon(
                prefixIcon,
                size: 20,
                color: AppColors.textMuted.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontFamily: 'Manrope',
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              ?suffixIcon,
            ],
          ),
        ),

        // Optional helper text with info icon (e.g., Minimum 10 characters required)
        if (helperText != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              if (helperIcon != null) ...[
                Icon(
                  helperIcon,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                helperText!,
                style: AppTypography.caption(
                  color: AppColors.textMuted,
                ).copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
