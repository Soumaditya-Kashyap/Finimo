import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TransactionTypeSegmentedSwitch extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const TransactionTypeSegmentedSwitch({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = selectedType == TransactionType.expense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          // Expense Button
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(TransactionType.expense),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.primaryFixed : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isExpense
                      ? [
                          BoxShadow(
                            color: AppColors.primaryFixed.withValues(alpha: 0.25),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: isExpense ? AppColors.canvasBase : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expense',
                      style: AppTypography.labelMd(
                        color: isExpense ? AppColors.canvasBase : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Income Button
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(TransactionType.income),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !isExpense ? AppColors.tertiaryFixed : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: !isExpense
                      ? [
                          BoxShadow(
                            color: AppColors.tertiaryFixed.withValues(alpha: 0.25),
                            blurRadius: 16,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.south_west_rounded,
                      size: 16,
                      color: !isExpense ? AppColors.canvasBase : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Income',
                      style: AppTypography.labelMd(
                        color: !isExpense ? AppColors.canvasBase : AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
