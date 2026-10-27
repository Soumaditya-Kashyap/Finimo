import 'package:flutter/material.dart';
import '../models/home_dashboard_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';

class LiquidityHeroCard extends StatelessWidget {
  final HomeDashboardData data;

  const LiquidityHeroCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final (mainAmount, decimalPart) = CurrencyFormatter.splitInrWithDecimals(
      data.consolidatedLiquidity,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.ghostBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 36,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cyber Cyan Radial Ambience (top-right)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.tertiaryFixedDim.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Electric Lime subtle glow (bottom-left)
          Positioned(
            bottom: -50,
            left: -40,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryFixed.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag & Live Ping
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryFixed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.tertiaryFixed.withValues(alpha: 0.8),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'CONSOLIDATED LIQUID CASH',
                          style: AppTypography.labelSm(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ).copyWith(
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface02,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'LIVE ${data.livePingSeconds}',
                        style: AppTypography.labelSm(
                          color: AppColors.tertiaryFixed,
                          fontWeight: FontWeight.w700,
                        ).copyWith(
                          fontSize: 9.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Big Numerical Balance Display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      mainAmount,
                      style: AppTypography.displayLg(
                        color: AppColors.textPrimary,
                      ).copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    Text(
                      decimalPart,
                      style: AppTypography.headlineSm(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w400,
                      ).copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Across ${data.jointAccountsCount} joint accounts and liquid reserves',
                  style: AppTypography.bodySm(
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 18),

                // Telemetry Sub-Pills (3 Columns: Inflow, Spent, Safe Burn)
                Row(
                  children: [
                    // Inflow Sub-pill
                    Expanded(
                      child: _buildTelemetryPill(
                        icon: Icons.arrow_downward_rounded,
                        iconColor: AppColors.primaryFixed,
                        label: 'INFLOW',
                        value: '+${CurrencyFormatter.formatInr(data.monthlyInflow)}',
                        valueColor: AppColors.primaryFixed,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Spent Sub-pill
                    Expanded(
                      child: _buildTelemetryPill(
                        icon: Icons.arrow_upward_rounded,
                        iconColor: AppColors.dangerCoral,
                        label: 'SPENT',
                        value: CurrencyFormatter.formatInr(data.monthlySpent),
                        valueColor: AppColors.dangerCoral,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Safe Burn Sub-pill
                    Expanded(
                      child: _buildTelemetryPill(
                        icon: Icons.bolt_rounded,
                        iconColor: AppColors.tertiaryFixed,
                        label: 'SAFE BURN',
                        value: '${CurrencyFormatter.formatInr(data.dailySafeBurn)}/day',
                        valueColor: AppColors.tertiaryFixed,
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

  Widget _buildTelemetryPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface02.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSm(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ).copyWith(
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headlineSm(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ).copyWith(
              fontSize: 13.5,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
