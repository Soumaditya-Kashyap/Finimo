import 'package:flutter/material.dart';
import '../models/deep_dive_models.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/animated_donut_chart_hero.dart';
import '../widgets/deep_dive_category_burn_card.dart';
import '../widgets/deep_dive_member_burn_card.dart';
import '../widgets/finimo_app_bar.dart';
import 'user_profile_screen.dart';

class DeepDiveScreen extends StatefulWidget {
  final HomeRepository repository;
  final bool isActive;

  const DeepDiveScreen({
    super.key,
    required this.repository,
    this.isActive = true,
  });

  @override
  State<DeepDiveScreen> createState() => _DeepDiveScreenState();
}

class _DeepDiveScreenState extends State<DeepDiveScreen> {
  final String _selectedMonth = 'October 2026';
  String _selectedView = 'category'; // 'category' | 'family'
  late Future<DeepDiveSummaryData> _futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DeepDiveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData();
    }
  }

  void _loadData() {
    _futureData = widget.repository.getDeepDiveSummaryData();
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
      body: FutureBuilder<DeepDiveSummaryData>(
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
                'Error loading deep dive: ${snapshot.error}',
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
                // 1. Top Header Row: Title & Month Picker Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONTHLY ANALYTICS',
                          style: AppTypography.labelSm(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                          ).copyWith(letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'INSIGHTS',
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

                const SizedBox(height: 12),

                // Active Family Pool Pill
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(9999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surface02,
                          borderRadius: BorderRadius.circular(9999),
                          border: Border.all(color: AppColors.ghostBorder, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Stacked Mini Avatars (A, C, AY)
                            SizedBox(
                              width: 36,
                              height: 18,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    child: _buildMiniAvatar('A', AppColors.primaryFixed),
                                  ),
                                  Positioned(
                                    left: 10,
                                    child: _buildMiniAvatar('C', AppColors.secondary),
                                  ),
                                  Positioned(
                                    left: 20,
                                    child: _buildMiniAvatar('AY', AppColors.tertiaryFixed),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'All Family Pool',
                              style: AppTypography.labelSm(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textMuted,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Segmented View Switcher: [Category View] vs [Family Member View]
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surface01,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      // Category View
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedView = 'category'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedView == 'category'
                                  ? AppColors.primaryFixed
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: _selectedView == 'category'
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryFixed.withValues(alpha: 0.25),
                                        blurRadius: 16,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.donut_large_rounded,
                                  size: 16,
                                  color: _selectedView == 'category'
                                      ? AppColors.canvasBase
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Category View',
                                  style: AppTypography.labelMd(
                                    color: _selectedView == 'category'
                                        ? AppColors.canvasBase
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Family Member View
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedView = 'family'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedView == 'family'
                                  ? AppColors.primaryFixed
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(9999),
                              boxShadow: _selectedView == 'family'
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryFixed.withValues(alpha: 0.25),
                                        blurRadius: 16,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_rounded,
                                  size: 16,
                                  color: _selectedView == 'family'
                                      ? AppColors.canvasBase
                                      : AppColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Family Member View',
                                  style: AppTypography.labelMd(
                                    color: _selectedView == 'family'
                                        ? AppColors.canvasBase
                                        : AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 3. Hero Visual (Category Donut Chart OR Family Attribution Bar)
                if (_selectedView == 'category') ...[
                  AnimatedDonutChartHero(
                    data: data,
                    isActive: widget.isActive,
                  ),

                  const SizedBox(height: 24),

                  // 4. Expense Breakdown List
                  Text(
                    'EXPENSE BREAKDOWN',
                    style: AppTypography.labelSm(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.0),
                  ),

                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.categories.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return DeepDiveCategoryBurnCard(category: data.categories[index]);
                    },
                  ),
                ] else ...[
                  // Family Member View Header Card
                  _buildFamilySpendAttributionCard(data.members),

                  const SizedBox(height: 24),

                  Text(
                    'MEMBER-WISE SPENDING',
                    style: AppTypography.labelSm(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.0),
                  ),

                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.members.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return DeepDiveMemberBurnCard(member: data.members[index]);
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

  Widget _buildFamilySpendAttributionCard(List<InsightMemberBurn> members) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface01,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.ghostBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FAMILY SPEND SHARE',
            style: AppTypography.labelSm(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.0),
          ),
          const SizedBox(height: 4),
          Text(
            'Spend by Family Member',
            style: AppTypography.headlineSm(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Horizontal Multi-Segment Stacked Bar
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.surface02,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Row(
              children: members.map((m) {
                return Expanded(
                  flex: m.percentageOfTotal.round(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: m.accentColor,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: members.map((m) {
              return Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: m.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${m.name} (${m.percentageOfTotal.round()}%)',
                    style: AppTypography.labelSm(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAvatar(String text, Color bg) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.canvasBase, width: 1.5),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.canvasBase,
            fontSize: 8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
