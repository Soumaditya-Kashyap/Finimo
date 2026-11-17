import 'package:flutter/material.dart';
import '../models/conjoined_event_summary.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class ConjoinedEventTagCard extends StatelessWidget {
  final List<ConjoinedEventSummary> events;
  final ConjoinedEventSummary? selectedEvent;
  final bool isTagged;
  final ValueChanged<bool>? onToggle;
  final ValueChanged<ConjoinedEventSummary>? onEventSelected;
  final bool isMandatory;

  const ConjoinedEventTagCard({
    super.key,
    required this.events,
    required this.selectedEvent,
    this.isTagged = false,
    this.onToggle,
    this.onEventSelected,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty && isMandatory) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface01,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.dangerCoral.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.dangerCoral, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No Active Sinking Pools',
                    style: AppTypography.labelMd(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Create an event in the Targets tab first before logging event expenses.',
                    style: AppTypography.bodySm(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final activeEvent = selectedEvent ?? events.firstOrNull;
    final showDetails = isMandatory || isTagged;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purpleSubtle.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMandatory
              ? AppColors.secondary.withValues(alpha: 0.6)
              : AppColors.ghostBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryContainer.withValues(alpha: 0.12),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isMandatory ? null : () => onToggle?.call(!isTagged),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: showDetails
                              ? AppColors.secondaryContainer
                              : AppColors.surface02,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: showDetails
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppColors.secondary,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          isMandatory
                              ? 'Event Pool (Required)'
                              : 'Tag to Shared Event',
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelMd(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  isMandatory ? 'ISOLATED POOL' : 'Event Pool',
                  style: AppTypography.labelSm(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 10),
                ),
              ),
            ],
          ),

          if (showDetails && activeEvent != null) ...[
            const SizedBox(height: 14),

            // Event Selector if multiple events exist
            if (events.length > 1) ...[
              Text(
                'SELECT EVENT POOL',
                style: AppTypography.labelSm(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ).copyWith(fontSize: 10),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: events.map((ev) {
                    final isSelected = ev.id == activeEvent.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => onEventSelected?.call(ev),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.secondary.withValues(alpha: 0.25)
                                : AppColors.surface02,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.ghostBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.celebration_rounded,
                                size: 14,
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.textMuted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                ev.title,
                                style: AppTypography.labelSm(
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Active Event Detail Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface01.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.ghostBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.celebration_rounded,
                              color: AppColors.secondary,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                activeEvent.title,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.labelMd(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${CurrencyFormatter.formatInr(activeEvent.totalSpent)} / ${CurrencyFormatter.formatInr(activeEvent.budgetCap)}',
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
                      widthFactor:
                          (activeEvent.percentageUsed / 100).clamp(0.0, 1.0),
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
                        '${activeEvent.percentageUsed.toStringAsFixed(1)}% spent',
                        style: AppTypography.bodySm(color: AppColors.textMuted),
                      ),
                      Text(
                        '${CurrencyFormatter.formatInr(activeEvent.remainingBudget)} remaining',
                        style: AppTypography.bodySm(color: AppColors.secondary)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Isolation Guarantee Note
            Row(
              children: [
                const Icon(Icons.shield_outlined,
                    size: 13, color: AppColors.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'This expense is isolated to ${activeEvent.title} and will NOT deduct from your monthly living budget.',
                    style: AppTypography.bodySm(color: AppColors.textMuted)
                        .copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
