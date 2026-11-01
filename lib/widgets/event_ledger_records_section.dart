import 'package:flutter/material.dart';
import '../models/conjoined_event_detail.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class EventLedgerRecordsSection extends StatelessWidget {
  final List<EventLedgerRecord> records;
  final VoidCallback? onSortTap;

  const EventLedgerRecordsSection({
    super.key,
    required this.records,
    this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Event Expenses [5 Items] ... Sort Date ▾
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Event Expenses',
                  style: AppTypography.headlineSm(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${records.length} items',
                    style: AppTypography.caption(
                      color: AppColors.textMuted,
                    ).copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onSortTap,
              child: Row(
                children: [
                  Text(
                    'Sort Date',
                    style: AppTypography.caption(
                      color: AppColors.secondary,
                    ).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // List of Ledger Records
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final record = records[index];
            return _buildRecordCard(record);
          },
        ),
      ],
    );
  }

  static IconData _resolveCategoryIcon(int code) {
    switch (code) {
      case 0xe1af:
        return Icons.checkroom;
      case 0xe5ef:
        return Icons.temple_hindu;
      case 0xe56c:
        return Icons.restaurant;
      case 0xe3ab:
        return Icons.local_offer;
      case 0xe8e6:
        return Icons.local_florist;
      default:
        return Icons.receipt_long;
    }
  }

  Widget _buildRecordCard(EventLedgerRecord record) {
    final payerColor = Color(record.paidByColorValue);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Category Icon Container
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: record.isCreditInflow
                  ? const Color(0xFF16240D)
                  : AppColors.surface02,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: record.isCreditInflow
                    ? AppColors.primaryFixed.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.04),
              ),
            ),
            child: Icon(
              _resolveCategoryIcon(record.categoryIconCode),
              color: record.isCreditInflow
                  ? AppColors.primaryFixed
                  : (record.paidByColorValue == 0xFFBF5AF2
                      ? AppColors.secondary
                      : (record.paidByColorValue == 0xFFCCFF00
                          ? AppColors.primaryFixed
                          : AppColors.tertiaryFixedDim)),
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          // Title & Subtitle / Tags
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: AppTypography.bodyMd(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ).copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (!record.isCreditInflow) ...[
                      Text(
                        record.dateString,
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '•',
                        style: AppTypography.caption(
                          color: AppColors.textMuted,
                        ).copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        record.categoryTag,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ] else ...[
                      Text(
                        record.categoryTag,
                        style: const TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          color: AppColors.primaryFixed,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Amount & Paid By Avatar/Name
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.isCreditInflow
                    ? '+₹${record.amount.toInt()}.00'
                    : CurrencyFormatter.format(record.amount),
                style: AppTypography.headlineSm(
                  color: record.isCreditInflow
                      ? AppColors.primaryFixed
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Payer initial pill or icon
                  if (record.isCreditInflow) ...[
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 11,
                      color: AppColors.primaryFixed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.paidByOrRecipient,
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(fontSize: 10),
                    ),
                  ] else ...[
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: payerColor.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: payerColor.withValues(alpha: 0.8),
                          width: 0.8,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          record.paidByInitial,
                          style: TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: payerColor,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.paidByOrRecipient,
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(fontSize: 10),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
