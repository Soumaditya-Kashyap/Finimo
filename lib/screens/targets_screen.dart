import 'package:flutter/material.dart';
import '../models/monthly_limit_item.dart';
import '../models/sinking_fund_goal.dart';
import '../models/targets_dashboard_data.dart';
import '../services/category_repository.dart';
import '../services/dashboard_repository.dart';
import '../services/event_repository.dart';
import '../services/home_repository.dart';
import '../services/target_repository.dart';
import '../services/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/currency_formatter.dart';
import '../widgets/animated_concentric_budget_gauge.dart';
import '../widgets/create_event_sheet.dart';
import '../widgets/create_target_sheet.dart';
import '../widgets/finimo_app_bar.dart';
import '../widgets/monthly_limit_card.dart';
import '../widgets/sinking_fund_goal_card.dart';
import 'conjoined_event_detail_screen.dart';
import 'user_profile_screen.dart';

class TargetsScreen extends StatefulWidget {
  final HomeRepository repository;
  final TargetRepository? targetRepository;
  final EventRepository? eventRepository;
  final CategoryRepository? categoryRepository;
  final DashboardRepository? dashboardRepository;
  final TransactionRepository? transactionRepository;
  final VoidCallback? onSeeLedgerTap;
  final bool isActive;

  const TargetsScreen({
    super.key,
    required this.repository,
    this.targetRepository,
    this.eventRepository,
    this.categoryRepository,
    this.dashboardRepository,
    this.transactionRepository,
    this.onSeeLedgerTap,
    this.isActive = true,
  });

  @override
  State<TargetsScreen> createState() => _TargetsScreenState();
}

class _TargetsScreenState extends State<TargetsScreen> {
  late final TargetRepository _targetRepo;
  late final EventRepository _eventRepo;
  late final CategoryRepository _categoryRepo;
  late final DashboardRepository _dashboardRepo;
  late final TransactionRepository _transactionRepo;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  bool _isLoading = true;
  String? _errorMessage;

  List<MonthlyLimitItem> _limits = [];
  List<SinkingFundGoal> _sinkingFunds = [];
  TargetsDashboardData _gaugeData = const TargetsDashboardData(
    budgetRemainingPct: 0,
    budgetRemainingAmount: 0,
    safeCapAmount: 0,
    daysLeft: 18,
    pacingProgress: 0.0,
    runwayProgress: 0.0,
    hasMasterBudget: false,
  );

  @override
  void initState() {
    super.initState();
    _targetRepo = widget.targetRepository ?? HttpTargetRepository();
    _eventRepo = widget.eventRepository ?? HttpEventRepository();
    _categoryRepo = widget.categoryRepository ?? HttpCategoryRepository();
    _dashboardRepo = widget.dashboardRepository ?? HttpDashboardRepository();
    _transactionRepo =
        widget.transactionRepository ?? HttpTransactionRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _targetRepo.getTargets(isActive: true),
        _eventRepo.getEvents(status: 'ACTIVE'),
        _dashboardRepo.getDashboardMetrics(
          month: _selectedMonth,
          year: _selectedYear,
        ),
        _transactionRepo
            .getTransactionsCursor(
              month: _selectedMonth,
              year: _selectedYear,
              limit: 100,
            )
            .catchError((_) => <String, dynamic>{'items': []}),
      ]);

      final rawTargets = results[0] as List<Map<String, dynamic>>;
      final rawEvents = results[1] as List<Map<String, dynamic>>;
      final txData = results[3] as Map<String, dynamic>;
      final rawTxList = (txData['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .toList() ??
          [];

      // 1. Separate regular non-event expenses from event expenses!
      // A transaction is a regular monthly living expense if:
      // (a) type == 'EXPENSE'
      // (b) event_id == null or empty
      double regularMonthlySpent = 0.0;
      final Map<String, double> categoryRegularSpentMap = {};

      for (final tx in rawTxList) {
        final typeStr = tx['type']?.toString().toUpperCase() ?? 'EXPENSE';
        final isExpense = typeStr != 'INCOME';
        final eventId = tx['event_id']?.toString();
        final isEventTx =
            eventId != null && eventId.isNotEmpty && eventId != 'null';

        if (isExpense && !isEventTx) {
          final amt = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
          regularMonthlySpent += amt;

          final cat = tx['category'] as Map<String, dynamic>?;
          final catId =
              cat?['id']?.toString() ?? tx['category_id']?.toString();
          if (catId != null && catId.isNotEmpty) {
            categoryRegularSpentMap[catId] =
                (categoryRegularSpentMap[catId] ?? 0.0) + amt;
          }
        }
      }

      // 2. Map targets with isolated regular spend (event spend never inflates monthly limits)
      final limits = rawTargets.map((json) {
        final item = MonthlyLimitItem.fromApiResponse(json);
        if (item.isMaster) {
          final pct = item.limitCap > 0
              ? (regularMonthlySpent / item.limitCap * 100)
              : 0.0;
          final buf = item.limitCap - regularMonthlySpent;
          return item.copyWith(
            currentSpent: regularMonthlySpent,
            percentageUsed: pct,
            statusText: buf > 0
                ? '₹${CurrencyFormatter.formatInr(buf)} buffer'
                : (buf == 0
                    ? 'Limit reached'
                    : '₹${CurrencyFormatter.formatInr(buf.abs())} exceeded'),
          );
        } else if (item.categoryId != null) {
          final sp = categoryRegularSpentMap[item.categoryId!] ?? 0.0;
          final pct = item.limitCap > 0 ? (sp / item.limitCap * 100) : 0.0;
          final buf = item.limitCap - sp;
          return item.copyWith(
            currentSpent: sp,
            percentageUsed: pct,
            statusText: buf > 0
                ? '₹${CurrencyFormatter.formatInr(buf)} buffer'
                : (buf == 0
                    ? 'Limit reached'
                    : '₹${CurrencyFormatter.formatInr(buf.abs())} exceeded'),
          );
        }
        return item;
      }).toList();

      final sinkingFunds = rawEvents
          .map((json) => SinkingFundGoal.fromApiResponse(json))
          .toList();

      final gaugeData = TargetsDashboardData.compute(
        limits: limits,
        regularMonthlySpent: regularMonthlySpent,
      );

      if (mounted) {
        setState(() {
          _limits = limits;
          _sinkingFunds = sinkingFunds;
          _gaugeData = gaugeData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showMonthPicker(BuildContext context) {
    const monthNames = [
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

    final now = DateTime.now();
    final options = <Map<String, dynamic>>[];

    for (int i = 0; i < 12; i++) {
      final d = DateTime(now.year, now.month - i, 1);
      options.add({
        'label': '${monthNames[d.month - 1]} ${d.year}',
        'month': d.month,
        'year': d.year,
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface01,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surface03,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Target Period',
                  style: AppTypography.headlineSm(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: options.length,
                    itemBuilder: (c, idx) {
                      final opt = options[idx];
                      final isSelected = opt['month'] == _selectedMonth &&
                          opt['year'] == _selectedYear;

                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? AppColors.primaryFixed
                              : AppColors.textMuted,
                        ),
                        title: Text(
                          opt['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryFixed
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(ctx).pop();
                          setState(() {
                            _selectedMonth = opt['month'] as int;
                            _selectedYear = opt['year'] as int;
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

  String get _monthSelectorLabel {
    const monthNames = [
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
    return '${monthNames[_selectedMonth - 1]} $_selectedYear';
  }

  void _showLimitDetail(MonthlyLimitItem limit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface01,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surface03,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: limit.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(limit.icon, color: limit.accentColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            limit.title,
                            style: AppTypography.headlineSm(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            limit.isMaster
                                ? 'Master Overall Family Cap'
                                : 'Category: ${limit.title} • ${limit.timeFrame ?? "MONTHLY"}',
                            style: AppTypography.bodySm(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Numbers Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface02,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.ghostBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CURRENT SPENT',
                              style: AppTypography.labelSm(
                                  color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                              '₹${CurrencyFormatter.formatInr(limit.currentSpent)}',
                              style: TextStyle(
                                  color: limit.isWarning
                                      ? AppColors.dangerCoral
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('MONTHLY CAP',
                              style: AppTypography.labelSm(
                                  color: AppColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                              '₹${CurrencyFormatter.formatInr(limit.limitCap)}',
                              style: const TextStyle(
                                  color: AppColors.primaryFixed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (limit.percentageUsed / 100).clamp(0.0, 1.0),
                    backgroundColor: AppColors.surface03,
                    color: limit.accentColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(limit.statusText,
                        style: AppTypography.bodySm(color: limit.accentColor)),
                    Text(
                        '${limit.percentageUsed.toStringAsFixed(1)}% consumed',
                        style: AppTypography.bodySm(color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 24),

                // Delete Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      _confirmDeleteTarget(limit);
                    },
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.dangerCoral),
                    label: Text(
                        limit.isMaster
                            ? 'Delete Master Monthly Budget'
                            : 'Delete Spending Limit',
                        style: const TextStyle(
                            color: AppColors.dangerCoral,
                            fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: AppColors.dangerCoral.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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

  Future<void> _confirmDeleteTarget(MonthlyLimitItem limit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface02,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
            limit.isMaster ? 'Delete Master Budget?' : 'Delete Target?',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          limit.isMaster
              ? 'Are you sure you want to delete the Master Monthly Budget? Sub-category limits will also lose their master ceiling.'
              : 'Are you sure you want to delete the spending limit for "${limit.title}"?',
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dangerCoral),
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _targetRepo.deleteTarget(limit.id);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(limit.isMaster
                  ? 'Master Monthly Budget removed'
                  : 'Target "${limit.title}" removed'),
              backgroundColor: AppColors.surface03,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting target: $e'),
              backgroundColor: AppColors.dangerCoral,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterTarget = _limits.where((l) => l.isMaster).firstOrNull;
    final categoryLimits = _limits.where((l) => !l.isMaster).toList();

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
      body: RefreshIndicator(
        color: AppColors.primaryFixed,
        backgroundColor: AppColors.surface02,
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
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
                        'Monthly budget & limits',
                        style: AppTypography.bodySm(color: AppColors.textMuted),
                      ),
                    ],
                  ),

                  // Month Selector Pill
                  InkWell(
                    onTap: () => _showMonthPicker(context),
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
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
                            _monthSelectorLabel,
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

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(
                        color: AppColors.primaryFixed),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.dangerCoral, size: 36),
                        const SizedBox(height: 10),
                        Text('Error loading targets:\n$_errorMessage',
                            textAlign: TextAlign.center,
                            style:
                                const TextStyle(color: AppColors.dangerCoral)),
                        const SizedBox(height: 14),
                        ElevatedButton(
                            onPressed: _loadData, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              else ...[
                // 2. Animated Dual Concentric Circle Gauge (Master Monthly Budget)
                AnimatedConcentricBudgetGauge(
                  data: _gaugeData,
                  isActive: widget.isActive,
                ),

                const SizedBox(height: 24),

                // 2B. Master Monthly Budget Banner (or Callout if absent)
                if (masterTarget == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surface01,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primaryFixed.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_outlined,
                                color: AppColors.primaryFixed,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Set Master Monthly Budget',
                                    style: AppTypography.headlineSm(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ).copyWith(fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Mandatory first step to activate budget pacing and category allocations.',
                                    style: AppTypography.bodySm(
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              CreateTargetSheet.show(
                                context,
                                targetRepository: _targetRepo,
                                categoryRepository: _categoryRepo,
                                onTargetCreated: _loadData,
                                hasMasterBudget: false,
                              );
                            },
                            icon: const Icon(Icons.add,
                                size: 18, color: AppColors.canvasBase),
                            label: const Text(
                              'Set Master Monthly Budget',
                              style: TextStyle(
                                  color: AppColors.canvasBase,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryFixed,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _showLimitDetail(masterTarget),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface01,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryFixed.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryFixed
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.shield_outlined,
                                    color: AppColors.primaryFixed, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    masterTarget.title,
                                    style: AppTypography.labelMd(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Allocated: ₹${CurrencyFormatter.formatInr(_gaugeData.allocatedCategoryAmount)} • Cushion: ₹${CurrencyFormatter.formatInr(_gaugeData.unallocatedBuffer)}',
                                    style: AppTypography.bodySm(
                                            color: AppColors.textMuted)
                                        .copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.surface02,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${CurrencyFormatter.formatInr(masterTarget.limitCap)}',
                                  style: AppTypography.labelSm(
                                    color: AppColors.primaryFixed,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.tune_rounded,
                                    size: 13, color: AppColors.primaryFixed),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 3. Active Category Sub-Limits Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Category Allocations',
                          style: AppTypography.headlineSm(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${categoryLimits.length}',
                          style: AppTypography.labelSm(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                    if (masterTarget != null && categoryLimits.isNotEmpty)
                      InkWell(
                        onTap: () {
                          CreateTargetSheet.show(
                            context,
                            targetRepository: _targetRepo,
                            categoryRepository: _categoryRepo,
                            onTargetCreated: _loadData,
                            hasMasterBudget: true,
                            masterBudgetId: masterTarget.id,
                            masterBudgetAmount: masterTarget.limitCap,
                            allocatedCategoriesAmount:
                                _gaugeData.allocatedCategoryAmount,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.primaryFixed
                                    .withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 14, color: AppColors.primaryFixed),
                              SizedBox(width: 4),
                              Text(
                                'Add Category',
                                style: TextStyle(
                                  color: AppColors.primaryFixed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (masterTarget == null)
                      Text(
                        'LOCKED',
                        style: AppTypography.labelSm(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ).copyWith(fontSize: 10),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                if (categoryLimits.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface01,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.ghostBorder),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          masterTarget == null
                              ? Icons.lock_outline_rounded
                              : Icons.pie_chart_outline_rounded,
                          color: AppColors.textMuted,
                          size: 30,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          masterTarget == null
                              ? 'Category limits locked'
                              : 'No category limits allocated yet',
                          style: AppTypography.headlineSm(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ).copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          masterTarget == null
                              ? 'Set your Master Monthly Budget above to unlock category sub-limits.'
                              : 'Allocate sub-limits for Groceries, Dining, etc. from your ₹${CurrencyFormatter.formatInr(_gaugeData.unallocatedBuffer)} cushion.',
                          textAlign: TextAlign.center,
                          style:
                              AppTypography.bodySm(color: AppColors.textMuted),
                        ),
                        if (masterTarget != null) ...[
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () {
                              CreateTargetSheet.show(
                                context,
                                targetRepository: _targetRepo,
                                categoryRepository: _categoryRepo,
                                onTargetCreated: _loadData,
                                hasMasterBudget: true,
                                masterBudgetId: masterTarget.id,
                                masterBudgetAmount: masterTarget.limitCap,
                                allocatedCategoriesAmount:
                                    _gaugeData.allocatedCategoryAmount,
                              );
                            },
                            icon: const Icon(Icons.add,
                                size: 16, color: AppColors.primaryFixed),
                            label: const Text(
                              'Allocate Category Limit',
                              style: TextStyle(
                                color: AppColors.primaryFixed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: AppColors.primaryFixed),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryLimits.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = categoryLimits[index];
                      return GestureDetector(
                        onTap: () => _showLimitDetail(item),
                        child: MonthlyLimitCard(item: item),
                      );
                    },
                  ),

                const SizedBox(height: 26),

                // 4. Savings Goals & Events Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Savings Goals & Events',
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
                              '${_sinkingFunds.length}',
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
                    if (_sinkingFunds.isNotEmpty)
                      InkWell(
                        onTap: () {
                          CreateEventSheet.show(
                            context,
                            eventRepository: _eventRepo,
                            onEventCreated: _loadData,
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.secondary
                                    .withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 14, color: AppColors.secondary),
                              SizedBox(width: 4),
                              Text(
                                'New Pool',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (widget.onSeeLedgerTap != null)
                      InkWell(
                        onTap: widget.onSeeLedgerTap,
                        child: Text(
                          'VIEW ALL',
                          style: AppTypography.labelSm(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ).copyWith(fontSize: 10),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_sinkingFunds.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.purpleSubtle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.ghostBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.celebration_outlined,
                            color: AppColors.secondary, size: 32),
                        const SizedBox(height: 10),
                        Text(
                          'No active sinking pools',
                          style: AppTypography.headlineSm(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a shared budget pool for Durga Puja, Diwali, or Family Trips.',
                          textAlign: TextAlign.center,
                          style:
                              AppTypography.bodySm(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () {
                            CreateEventSheet.show(
                              context,
                              eventRepository: _eventRepo,
                              onEventCreated: _loadData,
                            );
                          },
                          icon: const Icon(Icons.add,
                              size: 16, color: AppColors.secondary),
                          label: const Text('New Sinking Pool',
                              style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.secondary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _sinkingFunds.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final goal = _sinkingFunds[index];
                      return SinkingFundGoalCard(
                        goal: goal,
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ConjoinedEventDetailScreen(
                                repository: widget.repository,
                                eventRepository: _eventRepo,
                                categoryRepository: _categoryRepo,
                                eventId: goal.id,
                                eventTitle: goal.title,
                                backLabel: 'Targets',
                              ),
                            ),
                          );
                          _loadData();
                        },
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
