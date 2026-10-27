import 'package:flutter/material.dart';
import '../models/sinking_fund_goal.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class SinkingFundGoalCard extends StatelessWidget {
  final SinkingFundGoal goal;
  final VoidCallback? onTap;

  const SinkingFundGoalCard({
    super.key,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ghostBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Banner Area with Atmospheric Gradient & Badge
          Container(
            width: double.infinity,
            height: 96,
            decoration: BoxDecoration(
              color: goal.isSecondaryPurple ? const Color(0xFF23162F) : const Color(0xFF132029),
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: goal.isSecondaryPurple
                    ? [
                        const Color(0xFF38154D),
                        const Color(0xFF1A1322),
                      ]
                    : [
                        const Color(0xFF0F2C38),
                        const Color(0xFF101920),
                      ],
              ),
            ),
            child: Stack(
              children: [
                // Top-right soft radial aura
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          goal.isSecondaryPurple
                              ? AppColors.secondaryContainer.withValues(alpha: 0.3)
                              : AppColors.tertiaryFixed.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Center Icon/Illustration placeholder
                Center(
                  child: Icon(
                    goal.isSecondaryPurple
                        ? Icons.celebration_rounded
                        : Icons.flight_takeoff_rounded,
                    color: goal.isSecondaryPurple
                        ? AppColors.secondary.withValues(alpha: 0.25)
                        : AppColors.tertiaryFixed.withValues(alpha: 0.25),
                    size: 48,
                  ),
                ),

                // Bottom Content Row inside Banner
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface02.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              goal.isSecondaryPurple
                                  ? Icons.celebration_rounded
                                  : Icons.flight_takeoff_rounded,
                              size: 15,
                              color: goal.isSecondaryPurple
                                  ? AppColors.secondary
                                  : AppColors.tertiaryFixed,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              goal.title.toUpperCase(),
                              style: AppTypography.labelSm(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ).copyWith(
                                fontSize: 10,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface02.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '${goal.percentage.toStringAsFixed(goal.percentage % 1 == 0 ? 0 : 1)}%',
                          style: AppTypography.labelSm(
                            color: goal.isSecondaryPurple
                                ? AppColors.secondary
                                : AppColors.tertiaryFixed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Numbers & Member Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    CurrencyFormatter.formatInr(goal.currentAmount),
                    style: AppTypography.headlineSm(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ).copyWith(fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    goal.isSecondaryPurple
                        ? 'of ${CurrencyFormatter.formatInr(goal.targetGoal)} target'
                        : 'saved of ${CurrencyFormatter.formatInr(goal.targetGoal)} goal',
                    style: AppTypography.bodySm(color: AppColors.textMuted),
                  ),
                ],
              ),

              // Stacked Avatar circles
              Row(
                children: goal.memberInitials.map((initial) {
                  final isLime = initial == 'A';
                  final isCyan = initial == 'F';
                  final bg = isLime
                      ? AppColors.primaryFixed
                      : (isCyan ? AppColors.tertiaryFixed : AppColors.surface02);
                  final textCol = isLime || isCyan ? AppColors.canvasBase : AppColors.textPrimary;

                  return Container(
                    margin: const EdgeInsets.only(left: 3),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.canvasBase, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: textCol,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Gradient Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.surface02,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (goal.percentage / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9999),
                  gradient: LinearGradient(
                    colors: goal.isSecondaryPurple
                        ? [
                            AppColors.secondary,
                            AppColors.primaryFixed,
                          ]
                        : [
                            AppColors.tertiaryFixed,
                            AppColors.primaryFixed,
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (goal.isSecondaryPurple
                              ? AppColors.secondary
                              : AppColors.tertiaryFixed)
                          .withValues(alpha: 0.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Footer info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                goal.neededText,
                style: AppTypography.bodySm(color: AppColors.textMuted),
              ),
              Text(
                goal.paceStatus,
                style: AppTypography.bodySm(
                  color: goal.isSecondaryPurple
                      ? AppColors.primaryFixed
                      : AppColors.tertiaryFixed,
                ).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
