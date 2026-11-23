import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AmountKeypadDisplay extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<double> onPresetAdd;
  final VoidCallback onClear;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AmountKeypadDisplay({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onPresetAdd,
    required this.onClear,
    this.onChanged,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ghostBorder, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'TRANSACTION VALUE',
            style: AppTypography.labelSm(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ).copyWith(
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Big Numerical Display with native Android numeric keyboard
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '₹',
                  style: AppTypography.displayLg(
                    color: AppColors.textPrimary,
                  ).copyWith(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(minWidth: 80, maxWidth: 260),
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: autofocus,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: false,
                      ),
                      textInputAction: TextInputAction.done,
                      textAlign: TextAlign.left,
                      style: AppTypography.displayLg(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.0,
                      ),
                      cursorColor: AppColors.primaryFixed,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: AppTypography.displayLg(
                          color: AppColors.textMuted.withValues(alpha: 0.35),
                        ).copyWith(
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}')),
                      ],
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick preset buttons (+₹100, +₹500, +₹2,000, clear)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPresetPill('+₹100', () => onPresetAdd(100)),
              const SizedBox(width: 8),
              _buildPresetPill('+₹500', () => onPresetAdd(500)),
              const SizedBox(width: 8),
              _buildPresetPill('+₹2,000', () => onPresetAdd(2000)),
              const SizedBox(width: 8),
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface02,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Icon(
                    Icons.backspace_outlined,
                    size: 15,
                    color: AppColors.dangerCoral,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetPill(String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface02,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          text,
          style: AppTypography.labelSm(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
