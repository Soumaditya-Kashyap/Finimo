import 'package:flutter/material.dart';
import '../models/conjoined_event_summary.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class ConjoinedEventTagCard extends StatelessWidget {
  final ConjoinedEventSummary event;
  final bool isTagged;
  final ValueChanged<bool> onToggle;

  const ConjoinedEventTagCard({
    super.key,
    required this.event,
    required this.isTagged,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purpleSubtle.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ghostBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryContainer.withValues(alpha: 0.12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          // Checkbox + Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => onToggle(!isTagged),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isTagged ? AppColors.secondaryContainer : AppColors.surface02,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: isTagged
                          ? const Icon(
                              Icons.check,
                              color: AppColors.secondary,
                              size: 15,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Tag to Shared Event',
                      style: AppTypography.labelMd(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Event Pool',
                  style: AppTypography.labelSm(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ).copyWith(
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          if (isTagged) ...[
            const SizedBox(height: 12),

            // Inner Details Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface01.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.celebration_rounded,
                            color: AppColors.secondary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.title,
                            style: AppTypography.labelMd(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${CurrencyFormatter.formatInr(event.totalSpent)} / ${CurrencyFormatter.formatInr(event.budgetCap)}',
                        style: AppTypography.labelSm(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress Bar
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.surface02,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (event.percentageUsed / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.secondaryContainer,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${event.percentageUsed.toStringAsFixed(1)}% spent',
                        style: AppTypography.bodySm(
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.formatInr(event.remainingBudget)} remaining',
                        style: AppTypography.bodySm(
                          color: AppColors.secondary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
