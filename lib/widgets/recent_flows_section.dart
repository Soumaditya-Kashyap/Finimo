import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class RecentFlowsSection extends StatelessWidget {
  final List<TransactionItem> items;
  final VoidCallback? onSeeLedgerTap;

  const RecentFlowsSection({
    super.key,
    required this.items,
    this.onSeeLedgerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: AppTypography.headlineSm(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: onSeeLedgerTap,
                child: Text(
                  'View All',
                  style: AppTypography.labelMd(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface01,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: AppColors.textMuted,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'No recent flows yet',
                  style: AppTypography.bodySm(color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          // List of Transactions with No-Line rule (vertical spacing gap + surface shift)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildTransactionCard(item);
            },
          ),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionItem item) {
    final (tagTextColor, tagBgColor) = switch (item.attributionTagColor) {
      'purple' => (AppColors.secondary, AppColors.surface02),
      'cyan' => (AppColors.tertiaryFixed, AppColors.surface02),
      _ => (AppColors.primaryFixed, AppColors.surface02),
    };

    final iconData = switch (item.iconKey) {
      'smartphone' => Icons.phone_android_rounded,
      'shopping_bag' => Icons.shopping_bag_outlined,
      'stethoscope' => Icons.medical_services_outlined,
      _ => Icons.receipt_long_outlined,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Icon + Title Lockup
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface02,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.bodyMd(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: AppTypography.bodySm(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Right: Outflow/Inflow Amount + Member Attribution Tag
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${item.type == TransactionType.income ? '+' : '-'}${CurrencyFormatter.format(item.amount)}',
                style: AppTypography.headlineSm(
                  color: item.type == TransactionType.income
                      ? AppColors.primaryFixed
                      : AppColors.dangerCoral,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  item.attributionName,
                  style: AppTypography.labelSm(
                    color: tagTextColor,
                    fontWeight: FontWeight.w700,
                  ).copyWith(
                    fontSize: 9.5,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
