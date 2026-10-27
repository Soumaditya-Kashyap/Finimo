import 'package:flutter/material.dart';
import '../models/conjoined_event_detail.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class EventHeroVolumeCard extends StatelessWidget {
  final ConjoinedEventDetail detail;

  const EventHeroVolumeCard({
    super.key,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF140F1D), // Dark purple atmospheric container
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.secondary.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryContainer.withValues(alpha: 0.22),
            blurRadius: 36,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Atmospheric Violet Glow on top-left
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondaryContainer.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag Row: CONJOINED EVENT POOL & SHARED SINKING FUND
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(alpha: 0.9),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          detail.poolTag,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            color: AppColors.secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      detail.poolSubtype,
                      style: AppTypography.caption(
                        color: AppColors.textMuted,
                      ).copyWith(
                        fontSize: 10,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Label: TOTAL SUNK VOLUME
                Text(
                  'TOTAL SUNK VOLUME',
                  style: AppTypography.caption(
                    color: AppColors.textMuted,
                  ).copyWith(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),

                // Big Master Metric: ₹8,672.00 INR
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      CurrencyFormatter.format(detail.totalSunkVolume),
                      style: AppTypography.displayLg(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'INR',
                      style: const TextStyle(
                        fontFamily: 'SpaceGrotesk',
                        color: AppColors.secondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Spent of ₹10,000.00 Budget Cap (86.7%)
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySm(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 13),
                    children: [
                      const TextSpan(text: 'Spent of '),
                      TextSpan(
                        text: CurrencyFormatter.format(detail.budgetCap),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' Budget Cap '),
                      TextSpan(
                        text: '(${detail.spentPercentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Multi-color Sunk Progress Bar (Purple to Cyan to Electric Lime)
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF221A2C),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fillWidth =
                          constraints.maxWidth * (detail.spentPercentage / 100);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: fillWidth,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFBF5AF2), // Neon Purple
                                Color(0xFF00F5FF), // Cyber Cyan
                                Color(0xFFCCFF00), // Electric Lime
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryFixed.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 0.5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // 3 Bottom Telemetry Columns: REMAINING | MEMBERS | AVG BURN
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D0A13),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 1. REMAINING: ₹1,328 Buffer left
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REMAINING',
                              style: AppTypography.caption(
                                color: AppColors.textMuted,
                              ).copyWith(
                                fontSize: 9,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${detail.remainingBuffer.toInt()}',
                              style: AppTypography.headlineSm(
                                color: AppColors.tertiaryFixedDim,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Buffer left',
                              style: AppTypography.caption(
                                color: const Color(0xFF00A2AA),
                              ).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),

                      // 2. MEMBERS: 3 (C A H) Active sync
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MEMBERS',
                              style: AppTypography.caption(
                                color: AppColors.textMuted,
                              ).copyWith(
                                fontSize: 9,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${detail.activeMembersCount}',
                                  style: AppTypography.headlineSm(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ).copyWith(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                // Initials Stack (C in Purple, A in Cyan, H in Grey)
                                _buildMemberInitialCircle(
                                  'C',
                                  const Color(0xFFBF5AF2),
                                ),
                                const SizedBox(width: 3),
                                _buildMemberInitialCircle(
                                  'A',
                                  const Color(0xFF00F5FF),
                                ),
                                const SizedBox(width: 3),
                                _buildMemberInitialCircle(
                                  'H',
                                  Colors.white70,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Active sync',
                              style: AppTypography.caption(
                                color: AppColors.textMuted,
                              ).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),

                      // 3. AVG BURN: ₹1,445 / day run-rate
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AVG BURN',
                              style: AppTypography.caption(
                                color: AppColors.textMuted,
                              ).copyWith(
                                fontSize: 9,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${detail.avgDailyBurn.toInt()}',
                              style: AppTypography.headlineSm(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ).copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '/ day run-rate',
                              style: AppTypography.caption(
                                color: AppColors.primaryFixed,
                              ).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInitialCircle(String initial, Color color) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.8),
          width: 0.8,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
