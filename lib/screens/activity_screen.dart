import 'package:flutter/material.dart';
import '../models/activity_summary.dart';
import '../models/ledger_transaction.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/activity_telemetry_strip.dart';
import '../widgets/activity_transaction_card.dart';
import '../widgets/finimo_app_bar.dart';
import 'conjoined_event_detail_screen.dart';
import 'user_profile_screen.dart';

class ActivityScreen extends StatefulWidget {
  final HomeRepository repository;

  const ActivityScreen({
    super.key,
    required this.repository,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _selectedFilter = 'All';
  final String _selectedMonth = 'October 2026';

  late Future<_ActivityScreenData> _futureData;

  static const List<String> _filters = [
    'All',
    'Expenses',
    'Income',
    'Events / Sinking',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureData = Future.wait([
      widget.repository.getActivitySummary(),
      widget.repository.getLedgerTransactions(),
    ]).then((res) => _ActivityScreenData(
          summary: res[0] as ActivitySummary,
          transactions: res[1] as List<LedgerTransaction>,
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
      body: FutureBuilder<_ActivityScreenData>(
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
                'Error loading activity: ${snapshot.error}',
                style: const TextStyle(color: AppColors.dangerCoral),
              ),
            );
          }

          final data = snapshot.data!;
          final filteredTransactions = _filterTransactions(data.transactions);

          // Group by dateSection: 'Today' vs 'Yesterday'
          final todayList = filteredTransactions
              .where((t) => t.dateSection == 'Today')
              .toList();
          final yesterdayList = filteredTransactions
              .where((t) => t.dateSection == 'Yesterday')
              .toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Audit & Velocity Header + Period Selector Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUDIT & VELOCITY',
                          style: AppTypography.labelSm(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ).copyWith(
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Activity',
                          style: AppTypography.headlineMd(
                            color: AppColors.textPrimary,
                          ).copyWith(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
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

                const SizedBox(height: 16),

                // 2. Filter Chips Carousel (All, Expenses, Income, Events / Sinking)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedFilter = filter),
                          borderRadius: BorderRadius.circular(9999),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryFixed
                                  : AppColors.surface01,
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryFixed.withValues(alpha: 0.25),
                                        blurRadius: 12,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (filter == 'Events / Sinking') ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.canvasBase
                                          : AppColors.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  filter,
                                  style: AppTypography.labelMd(
                                    color: isSelected
                                        ? AppColors.canvasBase
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

                const SizedBox(height: 16),

                // 3. Telemetry Strip (Total Activity, Outflow, Inflow, Dual Gradient Bar)
                ActivityTelemetryStrip(summary: data.summary),

                const SizedBox(height: 24),

                // 4. Section: TODAY
                if (todayList.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Today',
                        style: AppTypography.headlineSm(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${todayList.length} TRANSACTIONS',
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
                    itemCount: todayList.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = todayList[index];
                      return ActivityTransactionCard(
                        transaction: item,
                        onTap: () {
                          if (item.badgeText?.contains('Pujo') == true ||
                              item.categoryName.contains('Festivals')) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ConjoinedEventDetailScreen(
                                  repository: widget.repository,
                                  backLabel: 'Activity',
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // 5. Section: YESTERDAY
                if (yesterdayList.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yesterday',
                        style: AppTypography.headlineSm(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${yesterdayList.length} TRANSACTIONS',
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
                    itemCount: yesterdayList.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = yesterdayList[index];
                      return ActivityTransactionCard(
                        transaction: item,
                        onTap: () {
                          if (item.badgeText?.contains('Pujo') == true ||
                              item.categoryName.contains('Festivals')) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ConjoinedEventDetailScreen(
                                  repository: widget.repository,
                                  backLabel: 'Activity',
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  List<LedgerTransaction> _filterTransactions(List<LedgerTransaction> list) {
    if (_selectedFilter == 'Expenses') {
      return list.where((t) => t.isExpense).toList();
    } else if (_selectedFilter == 'Income') {
      return list.where((t) => !t.isExpense).toList();
    } else if (_selectedFilter == 'Events / Sinking') {
      return list.where((t) => t.badgeText?.contains('Pujo') == true).toList();
    }
    return list;
  }
}

class _ActivityScreenData {
  final ActivitySummary summary;
  final List<LedgerTransaction> transactions;

  _ActivityScreenData({
    required this.summary,
    required this.transactions,
  });
}
