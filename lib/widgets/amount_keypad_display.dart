import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AmountKeypadDisplay extends StatefulWidget {
  final String rawAmount;
  final ValueChanged<double> onPresetAdd;
  final VoidCallback onClear;

  const AmountKeypadDisplay({
    super.key,
    required this.rawAmount,
    required this.onPresetAdd,
    required this.onClear,
  });

  @override
  State<AmountKeypadDisplay> createState() => _AmountKeypadDisplayState();
}

class _AmountKeypadDisplayState extends State<AmountKeypadDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  String get _formattedDisplay {
    if (widget.rawAmount.isEmpty || widget.rawAmount == '0') {
      return '0.00';
    }
    return widget.rawAmount;
  }

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

          // Big Numerical Display with blinking neon cursor
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(width: 4),
              Text(
                _formattedDisplay,
                style: AppTypography.displayLg(
                  color: AppColors.textPrimary,
                ).copyWith(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: _cursorController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _cursorController.value,
                    child: Container(
                      width: 3.5,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryFixed.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick preset buttons (+₹100, +₹500, +₹2,000, clear)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPresetPill('+₹100', () => widget.onPresetAdd(100)),
              const SizedBox(width: 8),
              _buildPresetPill('+₹500', () => widget.onPresetAdd(500)),
              const SizedBox(width: 8),
              _buildPresetPill('+₹2,000', () => widget.onPresetAdd(2000)),
              const SizedBox(width: 8),
              InkWell(
                onTap: widget.onClear,
                borderRadius: BorderRadius.circular(9999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
