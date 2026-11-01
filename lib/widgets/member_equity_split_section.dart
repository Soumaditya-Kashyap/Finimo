import 'package:flutter/material.dart';
import '../models/conjoined_event_detail.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class MemberEquitySplitSection extends StatelessWidget {
  final List<EventMemberEquity> splits;
  final VoidCallback? onInfoTap;

  const MemberEquitySplitSection({
    super.key,
    required this.splits,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Row: Who Paid How Much ℹ️ ... LIVE SPLIT
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Who Paid How Much',
                  style: AppTypography.headlineSm(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ).copyWith(fontSize: 16),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onInfoTap,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.info_outline_rounded,
                      size: 11,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'LIVE SPLIT',
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                color: AppColors.primaryFixed,
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Multi-segment Horizontal Bar showing the ratio of each member
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 4,
            child: Row(
              children: splits.map((split) {
                return Expanded(
                  flex: (split.ratioPercentage * 10).toInt(),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    color: Color(split.accentColorValue),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 3 Member Cards Row (Chandrani, Arpa, Family)
        Row(
          children: splits.map((member) {
            final color = Color(member.accentColorValue);
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  right: member == splits.last ? 0 : 8,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface01,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Initial circle + Name
                    Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color.withValues(alpha: 0.8),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              member.initial,
                              style: TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                color: color,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            member.name,
                            style: AppTypography.bodySm(
                              color: AppColors.textPrimary,
                            ).copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Amount in bold Space Grotesk colored by member's accent
                    Text(
                      '₹${CurrencyFormatter.format(member.amount).replaceAll('₹', '').replaceAll('.00', '')}',
                      style: AppTypography.headlineSm(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 16),
                    ),

                    const SizedBox(height: 4),

                    // Ratio & %
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ratio',
                          style: AppTypography.caption(
                            color: AppColors.textMuted,
                          ).copyWith(fontSize: 10),
                        ),
                        Text(
                          '${member.ratioPercentage.toStringAsFixed(1)}%',
                          style: AppTypography.caption(
                            color: color,
                          ).copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
