import 'package:flutter/material.dart';
import '../models/ledger_transaction.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class ActivityTransactionCard extends StatelessWidget {
  final LedgerTransaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ActivityTransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _showTransactionDetails(context),
      onLongPress: onDelete,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface01,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.ghostBorder, width: 0.5),
        ),
        child: Column(
          children: [
            // Top Row: Icon + Title/Category + Amount/Time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface02,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction.icon,
                    color: transaction.isExpense
                        ? AppColors.textPrimary
                        : AppColors.primaryFixed,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Title + Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyLg(
                          color: AppColors.textPrimary,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.categoryName,
                        style: AppTypography.bodySm(
                          color: transaction.isExpense
                              ? AppColors.textMuted
                              : AppColors.primaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount + Timestamp
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.isExpense ? '-' : '+'}${CurrencyFormatter.formatInr(transaction.amount)}.00',
                      style: AppTypography.headlineSm(
                        color: transaction.isExpense
                            ? AppColors.dangerCoral
                            : AppColors.primaryFixed,
                        fontWeight: FontWeight.w700,
                      ).copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.timeString,
                      style: AppTypography.labelSm(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Bottom Context Attribution Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surface02.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Payer Avatar + Attribution Text
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: transaction.payerInitial == 'C'
                                ? AppColors.secondaryContainer
                                    .withValues(alpha: 0.5)
                                : AppColors.primaryFixed
                                    .withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              transaction.payerInitial,
                              style: TextStyle(
                                color: transaction.payerInitial == 'C'
                                    ? AppColors.secondary
                                    : AppColors.primaryFixed,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: AppTypography.labelSm(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ).copyWith(fontSize: 11),
                              children: [
                                TextSpan(
                                  text: transaction.isExpense
                                      ? 'Paid by '
                                      : 'Received by ',
                                ),
                                TextSpan(
                                  text: transaction.payerName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' ➔ '),
                                TextSpan(
                                  text: transaction.isExpense ? 'For ' : '',
                                ),
                                TextSpan(
                                  text: transaction.beneficiaryName,
                                  style: TextStyle(
                                    color: transaction.isExpense
                                        ? AppColors.textPrimary
                                        : AppColors.primaryFixed,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right Badges: Event / Status Badge + Stacked Member Avatars
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (transaction.badgeText != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.surface03,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (transaction.badgeColor != null) ...[
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: transaction.badgeColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                transaction.badgeText!,
                                style: AppTypography.labelSm(
                                  color: transaction.badgeColor ??
                                      AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ).copyWith(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (transaction.isMultiBeneficiary)
                          const SizedBox(width: 6),
                      ],
                      if (transaction.isMultiBeneficiary)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildMiniAvatar('A', AppColors.primaryFixed,
                                AppColors.canvasBase),
                            Transform.translate(
                              offset: const Offset(-4, 0),
                              child: _buildMiniAvatar('P',
                                  AppColors.secondary, AppColors.canvasBase),
                            ),
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: _buildMiniAvatar('AY',
                                  AppColors.tertiaryFixed, AppColors.canvasBase),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniAvatar(String text, Color bg, Color textColor) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.canvasBase, width: 1.5),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 7.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasBase,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surface03,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Top Header: Icon + Title + Category
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface02,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        transaction.icon,
                        color: transaction.isExpense
                            ? AppColors.textPrimary
                            : AppColors.primaryFixed,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            style: AppTypography.headlineSm(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction.categoryName,
                            style: AppTypography.bodySm(
                              color: transaction.isExpense
                                  ? AppColors.textMuted
                                  : AppColors.primaryFixed,
                            ).copyWith(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Big Amount Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface01,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.ghostBorder, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.isExpense ? 'TOTAL OUTFLOW' : 'TOTAL INFLOW',
                        style: AppTypography.labelSm(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ).copyWith(letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.isExpense ? '-' : '+'}${CurrencyFormatter.formatInr(transaction.amount)}.00',
                        style: AppTypography.displayLg(
                          color: transaction.isExpense
                              ? AppColors.dangerCoral
                              : AppColors.primaryFixed,
                        ).copyWith(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Details Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface01,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.ghostBorder, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        label: 'Date & Time',
                        value:
                            '${transaction.dateSection} • ${transaction.timeString}',
                      ),
                      const Divider(color: AppColors.ghostBorder, height: 20),
                      _buildDetailRow(
                        label: transaction.isExpense ? 'Paid By' : 'Income By',
                        value: transaction.payerName,
                      ),
                      const Divider(color: AppColors.ghostBorder, height: 20),
                      _buildDetailRow(
                        label: transaction.isExpense
                            ? 'Beneficiary'
                            : 'Beneficiary (Share)',
                        value: transaction.beneficiaryName,
                      ),
                      if (transaction.paymentMode != null &&
                          transaction.paymentMode!.isNotEmpty) ...[
                        const Divider(color: AppColors.ghostBorder, height: 20),
                        _buildDetailRow(
                          label: 'Payment Mode',
                          value: transaction.paymentMode!.toUpperCase(),
                        ),
                      ],
                      if (transaction.notes != null &&
                          transaction.notes!.trim().isNotEmpty) ...[
                        const Divider(color: AppColors.ghostBorder, height: 20),
                        _buildDetailRow(
                          label: 'Notes / Memo',
                          value: transaction.notes!.trim(),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Delete Action Button
                if (onDelete != null)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onDelete!();
                      },
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: AppColors.dangerCoral),
                      label: const Text(
                        'Delete Transaction',
                        style: TextStyle(
                          color: AppColors.dangerCoral,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.dangerCoral.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySm(color: AppColors.textMuted),
        ),
        Text(
          value,
          style: AppTypography.bodySm(
            color: AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
