import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/deep_dive_models.dart';
import '../models/family_member.dart';
import '../services/family_repository.dart';
import '../services/home_repository.dart';
import '../services/insight_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/animated_donut_chart_hero.dart';
import '../widgets/deep_dive_category_burn_card.dart';
import '../widgets/deep_dive_member_burn_card.dart';
import '../widgets/finimo_app_bar.dart';
import 'user_profile_screen.dart';

class DeepDiveScreen extends StatefulWidget {
  final HomeRepository repository;
  final InsightRepository? insightRepository;
  final FamilyRepository? familyRepository;
  final bool isActive;

  const DeepDiveScreen({
    super.key,
    required this.repository,
    this.insightRepository,
    this.familyRepository,
    this.isActive = true,
  });

  @override
  State<DeepDiveScreen> createState() => _DeepDiveScreenState();
}

class _DeepDiveScreenState extends State<DeepDiveScreen> {
  late final InsightRepository _insightRepo;
  late final FamilyRepository _familyRepo;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  String? _selectedMemberId;
  String _selectedMemberName = 'All Family Pool';
  List<FamilyMember> _familyMembers = [];

  String _selectedView = 'category'; // 'category' | 'family'
  DeepDiveSummaryData? _lastLoadedData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _insightRepo = widget.insightRepository ?? HttpInsightRepository();
    _familyRepo = widget.familyRepository ?? HttpFamilyRepository();
    _loadFamilyMembers();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DeepDiveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData(silent: true);
    }
  }

  Future<void> _loadFamilyMembers() async {
    try {
      final members = await _familyRepo.getFamilyMembers();
      if (mounted) {
        setState(() {
          _familyMembers = members;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent && _lastLoadedData == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final data = await _insightRepo.getInsightsSummary(
        month: _selectedMonth,
        year: _selectedYear,
        memberId: _selectedMemberId,
      );

      if (mounted) {
        setState(() {
          _lastLoadedData = data;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        if (_lastLoadedData != null) {
          setState(() {
            _isLoading = false;
          });
          if (!silent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Connection issue. Showing cached insights.',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: AppColors.surface02,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString();
          });
        }
      }
    }
  }

  void _showMonthPickerSheet() {
    final now = DateTime.now();
    final monthsList = <Map<String, dynamic>>[];

    // Generate current month and previous 11 months
    for (int i = 0; i < 12; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      monthsList.add({
        'month': d.month,
        'year': d.year,
        'label': '${_getMonthName(d.month)} ${d.year}',
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'SELECT ANALYTICS PERIOD',
                    style: AppTypography.labelSm(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: monthsList.length,
                    itemBuilder: (context, index) {
                      final item = monthsList[index];
                      final isSelected = item['month'] == _selectedMonth &&
                          item['year'] == _selectedYear;

                      return ListTile(
                        leading: Icon(
                          Icons.calendar_month_outlined,
                          color: isSelected
                              ? AppColors.primaryFixed
                              : AppColors.textMuted,
                        ),
                        title: Text(
                          item['label'] as String,
                          style: AppTypography.bodyLg(
                            color: isSelected
                                ? AppColors.primaryFixed
                                : AppColors.textPrimary,
                          ).copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryFixed,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedMonth = item['month'] as int;
                            _selectedYear = item['year'] as int;
                          });
                          _loadData();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMemberPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.canvasBase,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'FILTER BY MEMBER POOL',
                    style: AppTypography.labelSm(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.0),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: AppColors.surface02,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.group_rounded,
                      color: AppColors.primaryFixed,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    'All Family Pool',
                    style: AppTypography.bodyLg(
                      color: _selectedMemberId == null
                          ? AppColors.primaryFixed
                          : AppColors.textPrimary,
                    ).copyWith(
                      fontWeight: _selectedMemberId == null
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  trailing: _selectedMemberId == null
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryFixed,
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedMemberId = null;
                      _selectedMemberName = 'All Family Pool';
                    });
                    _loadData();
                  },
                ),
                ..._familyMembers.map((member) {
                  final isSelected = _selectedMemberId == member.id;
                  return ListTile(
                    leading: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.surface02,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryFixed
                              : AppColors.ghostBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          member.initial,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryFixed
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      member.name,
                      style: AppTypography.bodyLg(
                        color: isSelected
                            ? AppColors.primaryFixed
                            : AppColors.textPrimary,
                      ).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryFixed,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedMemberId = member.id;
                        _selectedMemberName = member.name;
                      });
                      _loadData();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: FinimoAppBar(
        onProfileTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) =>
                  UserProfileScreen(repository: widget.repository),
            ),
          );
        },
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _lastLoadedData == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryFixed),
      );
    }

    if (_errorMessage != null && _lastLoadedData == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.dangerCoral,
                size: 44,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading insights',
                style: AppTypography.headlineSm(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: AppTypography.bodySm(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loadData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  foregroundColor: AppColors.canvasBase,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = _lastLoadedData!;

    return RefreshIndicator(
      onRefresh: () => _loadData(silent: true),
      color: AppColors.primaryFixed,
      backgroundColor: AppColors.surface01,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Top Header Row: Title & Dynamic Month Picker Pill
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

                // Dynamic Month Selector Pill
                InkWell(
                  onTap: _showMonthPickerSheet,
                  borderRadius: BorderRadius.circular(9999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface02,
                      borderRadius: BorderRadius.circular(9999),
                      border:
                          Border.all(color: AppColors.ghostBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_getMonthName(_selectedMonth)} $_selectedYear',
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

            // Active Family Pool / Member Pill
            Row(
              children: [
                InkWell(
                  onTap: _showMemberPickerSheet,
                  borderRadius: BorderRadius.circular(9999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface02,
                      borderRadius: BorderRadius.circular(9999),
                      border:
                          Border.all(color: AppColors.ghostBorder, width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedMemberId == null) ...[
                          if (_familyMembers.isNotEmpty)
                            SizedBox(
                              width: math.min(
                                44,
                                18.0 + (_familyMembers.length - 1) * 10.0,
                              ),
                              height: 18,
                              child: Stack(
                                children: [
                                  for (int i = 0;
                                      i < math.min(3, _familyMembers.length);
                                      i++)
                                    Positioned(
                                      left: i * 10.0,
                                      child: _buildMiniAvatar(
                                        _familyMembers[i].initial,
                                        i == 0
                                            ? AppColors.primaryFixed
                                            : (i == 1
                                                ? AppColors.secondary
                                                : AppColors.tertiaryFixed),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          else
                            const Icon(
                              Icons.group_rounded,
                              size: 16,
                              color: AppColors.primaryFixed,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedMemberName,
                            style: AppTypography.labelSm(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ] else ...[
                          _buildMiniAvatar(
                            _selectedMemberName.trim().isNotEmpty
                                ? _selectedMemberName.trim()[0].toUpperCase()
                                : 'M',
                            AppColors.primaryFixed,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedMemberName,
                            style: AppTypography.labelSm(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
                                    color: AppColors.primaryFixed
                                        .withValues(alpha: 0.25),
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
                                    color: AppColors.primaryFixed
                                        .withValues(alpha: 0.25),
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

            // 3. Hero Visual & Content
            if (_selectedView == 'category') ...[
              AnimatedDonutChartHero(
                data: data,
                isActive: widget.isActive,
              ),

              const SizedBox(height: 24),

              // 4. Expense Breakdown List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EXPENSE BREAKDOWN',
                    style: AppTypography.labelSm(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.0),
                  ),
                  if (data.categories.isNotEmpty)
                    Text(
                      '${data.categories.length} CATEGORIES',
                      style: AppTypography.labelSm(
                        color: AppColors.primaryFixed,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 10, letterSpacing: 0.8),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (data.categories.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 36,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface01,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.ghostBorder, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.pie_chart_outline_rounded,
                        color: AppColors.textMuted,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Category Expenses',
                        style: AppTypography.bodyLg(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No expenses recorded for ${_getMonthName(_selectedMonth)} $_selectedYear.',
                        style: AppTypography.bodySm(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.categories.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    return DeepDiveCategoryBurnCard(
                      category: data.categories[index],
                    );
                  },
                ),
            ] else ...[
              // Family Member View Header Card
              _buildFamilySpendAttributionCard(data.members),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MEMBER-WISE SPENDING',
                    style: AppTypography.labelSm(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.0),
                  ),
                  if (data.members.isNotEmpty)
                    Text(
                      '${data.members.length} MEMBERS',
                      style: AppTypography.labelSm(
                        color: AppColors.primaryFixed,
                        fontWeight: FontWeight.w700,
                      ).copyWith(fontSize: 10, letterSpacing: 0.8),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              if (data.members.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 36,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface01,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.ghostBorder, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.people_outline_rounded,
                        color: AppColors.textMuted,
                        size: 36,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No Member Spending',
                        style: AppTypography.bodyLg(
                          color: AppColors.textPrimary,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No member expenses recorded for ${_getMonthName(_selectedMonth)} $_selectedYear.',
                        style: AppTypography.bodySm(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
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
      ),
    );
  }

  Widget _buildFamilySpendAttributionCard(List<InsightMemberBurn> members) {
    final activeContributors =
        members.where((m) => m.percentageOfTotal > 0).toList();

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
            child: activeContributors.isNotEmpty
                ? Row(
                    children: activeContributors.map((m) {
                      final flex = math.max(1, m.percentageOfTotal.round());
                      return Expanded(
                        flex: flex,
                        child: Container(
                          decoration: BoxDecoration(
                            color: m.accentColor,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 12),

          // Legend
          if (members.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: members.map((m) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
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
            )
          else
            Text(
              'No member activity recorded',
              style: AppTypography.bodySm(color: AppColors.textMuted),
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
