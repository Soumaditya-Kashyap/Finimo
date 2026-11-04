import 'package:flutter/material.dart';
import '../models/conjoined_event_summary.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class ActiveEventSnapshotCard extends StatelessWidget {
  final ConjoinedEventSummary? event;
  final VoidCallback? onBreakdownTap;

  const ActiveEventSnapshotCard({
    super.key,
    required this.event,
    this.onBreakdownTap,
  });

  @override
  Widget build(BuildContext context) {
    if (event == null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.purpleSubtle,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.ghostBorder, width: 1),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.celebration_outlined,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Sinking Pool',
                    style: AppTypography.labelMd(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Shared pool for festivals & events will appear here',
                    style: AppTypography.caption(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final currentEvent = event!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.purpleSubtle,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ghostBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.12),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Atmospheric Purple Aura (top-left)
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Badge + Event Name + Percentage
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            'EVENT BUDGET',
                            style: AppTypography.labelSm(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ).copyWith(
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('•',
                            style: TextStyle(color: AppColors.textMuted)),
                        const SizedBox(width: 8),
                        Text(
                          currentEvent.title,
                          style: AppTypography.labelMd(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${currentEvent.percentageUsed.toStringAsFixed(1)}%',
                      style: AppTypography.labelSm(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ).copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Numbers: Spent of budget & Left
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CurrencyFormatter.formatInr(currentEvent.totalSpent),
                          style: AppTypography.headlineSm(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ).copyWith(
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'spent of ${CurrencyFormatter.formatInr(currentEvent.budgetCap)} budget',
                          style: AppTypography.bodySm(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${CurrencyFormatter.formatInr(currentEvent.remainingBudget)} left',
                      style: AppTypography.labelSm(
                        color: AppColors.dangerCoral,
                        fontWeight: FontWeight.w600,
                      ).copyWith(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Neon Multi-Stop Progress Bar
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.surface02.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor:
                        (currentEvent.percentageUsed / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9999),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.secondary,
                            Color(0xFFE9B3FF),
                            AppColors.primaryFixed,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryFixed.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Footer: Contributing members & Breakdown CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.group_outlined,
                          color: AppColors.textMuted,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${currentEvent.contributingMembersCount} members contributing',
                          style: AppTypography.labelSm(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ).copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: onBreakdownTap,
                      child: Row(
                        children: [
                          Text(
                            'Breakdown',
                            style: AppTypography.labelMd(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.secondary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
