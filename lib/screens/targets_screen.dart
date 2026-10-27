import 'package:flutter/material.dart';
import '../models/monthly_limit_item.dart';
import '../models/sinking_fund_goal.dart';
import '../models/targets_dashboard_data.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/animated_concentric_budget_gauge.dart';
import '../widgets/finimo_app_bar.dart';
import '../widgets/monthly_limit_card.dart';
import '../widgets/sinking_fund_goal_card.dart';
import 'conjoined_event_detail_screen.dart';
import 'user_profile_screen.dart';

class TargetsScreen extends StatefulWidget {
  final HomeRepository repository;
  final VoidCallback? onSeeLedgerTap;
  final bool isActive;

  const TargetsScreen({
    super.key,
    required this.repository,
    this.onSeeLedgerTap,
    this.isActive = true,
  });

  @override
  State<TargetsScreen> createState() => _TargetsScreenState();
}

class _TargetsScreenState extends State<TargetsScreen> {
  final String _selectedMonth = 'October 2026';
  late Future<_TargetsScreenData> _futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureData = Future.wait([
      widget.repository.getTargetsDashboardData(),
      widget.repository.getActiveMonthlyLimits(),
      widget.repository.getSinkingFundGoals(),
    ]).then((res) => _TargetsScreenData(
          gaugeData: res[0] as TargetsDashboardData,
          limits: res[1] as List<MonthlyLimitItem>,
          sinkingFunds: res[2] as List<SinkingFundGoal>,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: FinimoAppBar(
        onProfileTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => UserProfileScreen(repository: widget.repository),
            ),
          );
        },
      ),
      body: FutureBuilder<_TargetsScreenData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryFixed),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading targets: ${snapshot.error}',
                style: const TextStyle(color: AppColors.dangerCoral),
              ),
            );
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header with Month Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Targets & Budgets',
                          style: AppTypography.headlineMd(
                            color: AppColors.textPrimary,
                          ).copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Family financial runway',
                          style: AppTypography.bodySm(color: AppColors.textMuted),
                        ),
                      ],
                    ),

                    // Month Selector Pill
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface02,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: AppColors.ghostBorder, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedMonth,
                              style: AppTypography.labelMd(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Animated Dual Concentric Circle Gauge
                AnimatedConcentricBudgetGauge(
                  data: data.gaugeData,
                  isActive: widget.isActive,
                ),

                const SizedBox(height: 26),

                // 3. Active Monthly Limits Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Monthly Limits',
                      style: AppTypography.headlineSm(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${data.limits.length} CATEGORIES',
                      style: AppTypography.labelSm(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ).copyWith(fontSize: 10),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.limits.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return MonthlyLimitCard(item: data.limits[index]);
                  },
                ),

                const SizedBox(height: 26),

                // 4. Sinking Funds & Goals Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sinking Funds & Goals',
                          style: AppTypography.headlineSm(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${data.sinkingFunds.length}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: widget.onSeeLedgerTap,
                      child: Text(
                        'SEE LEDGER',
                        style: AppTypography.labelSm(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.sinkingFunds.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final goal = data.sinkingFunds[index];
                    return SinkingFundGoalCard(
                      goal: goal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ConjoinedEventDetailScreen(
                              repository: widget.repository,
                              eventId: goal.id,
                              eventTitle: goal.title,
                              backLabel: 'Targets',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 5. Create New Target Action Button
                InkWell(
                  onTap: () {
                    // Open create target modal
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryFixed.withValues(alpha: 0.28),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.canvasBase,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Create New Target',
                          style: AppTypography.headlineSm(
                            color: AppColors.canvasBase,
                            fontWeight: FontWeight.w700,
                          ).copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TargetsScreenData {
  final TargetsDashboardData gaugeData;
  final List<MonthlyLimitItem> limits;
  final List<SinkingFundGoal> sinkingFunds;

  _TargetsScreenData({
    required this.gaugeData,
    required this.limits,
    required this.sinkingFunds,
  });
}
