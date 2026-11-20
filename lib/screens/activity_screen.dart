import 'package:flutter/material.dart';
import '../models/activity_summary.dart';
import '../models/family_member.dart';
import '../models/ledger_transaction.dart';
import '../models/transaction_item.dart';
import '../services/category_repository.dart';
import '../services/dashboard_repository.dart';
import '../services/family_repository.dart';
import '../services/home_repository.dart';
import '../services/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/activity_telemetry_strip.dart';
import '../widgets/activity_transaction_card.dart';
import '../widgets/finimo_app_bar.dart';
import 'add_expense_income_screen.dart';
import 'conjoined_event_detail_screen.dart';
import 'user_profile_screen.dart';

class ActivityScreen extends StatefulWidget {
  final HomeRepository repository;
  final TransactionRepository? transactionRepository;
  final FamilyRepository? familyRepository;
  final CategoryRepository? categoryRepository;
  final DashboardRepository? dashboardRepository;
  final bool isActive;

  const ActivityScreen({
    super.key,
    required this.repository,
    this.transactionRepository,
    this.familyRepository,
    this.categoryRepository,
    this.dashboardRepository,
    this.isActive = true,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final TransactionRepository _transactionRepo;
  late final FamilyRepository _familyRepo;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  int? _selectedMonth;
  int? _selectedYear;
  String? _selectedMemberId;

  bool _isSearchOpen = false;
  String _searchQuery = '';

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _nextCursor;

  final List<LedgerTransaction> _transactions = [];
  List<FamilyMember> _familyMembers = [];
  ActivitySummary _summary = const ActivitySummary(
    totalCount: 0,
    netAmount: 0,
    outflowAmount: 0,
    inflowAmount: 0,
  );

  static const List<String> _filters = [
    'All',
    'Expenses',
    'Income',
    'Events & Goals',
  ];

  @override
  void initState() {
    super.initState();
    _transactionRepo =
        widget.transactionRepository ?? HttpTransactionRepository();
    _familyRepo = widget.familyRepository ?? HttpFamilyRepository();

    // Default to current month and year
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void didUpdateWidget(covariant ActivityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _fetchTransactions(reset: true, silent: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_nextCursor != null && !_isLoadingMore && !_isLoading) {
        _loadMoreTransactions();
      }
    }
  }

  Future<void> _loadInitialData() async {
    try {
      final members = await _familyRepo.getFamilyMembers();
      if (mounted) {
        setState(() {
          _familyMembers = members;
        });
      }
    } catch (_) {
      // Non-fatal if family members fail
    }

    await _fetchTransactions(reset: true);
  }

  Future<void> _fetchTransactions({bool reset = false, bool silent = false}) async {
    if (reset) {
      if (!silent) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
          _nextCursor = null;
          _transactions.clear();
        });
      } else {
        _nextCursor = null;
      }
    }

    String? typeParam;
    if (_selectedFilter == 'Expenses') {
      typeParam = 'EXPENSE';
    } else if (_selectedFilter == 'Income') {
      typeParam = 'INCOME';
    }

    try {
      final data = await _transactionRepo.getTransactionsCursor(
        limit: 50,
        cursor: reset ? null : _nextCursor,
        month: _selectedMonth,
        year: _selectedYear,
        memberId: _selectedMemberId,
        type: typeParam,
      );

      final rawItems = data['items'] as List? ?? [];
      final newItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => LedgerTransaction.fromApiResponse(e))
          .toList();

      if (mounted) {
        setState(() {
          if (reset && silent) {
            _transactions.clear();
          }
          _transactions.addAll(newItems);
          _nextCursor = data['next_cursor']?.toString();
          _recalculateSummary();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_transactions.isEmpty) {
            _errorMessage = e.toString();
          }
          _isLoading = false;
        });

        if (_transactions.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: AppColors.dangerCoral, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connection issue. Showing cached transactions.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.surface02,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _loadMoreTransactions() async {
    if (_nextCursor == null || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    String? typeParam;
    if (_selectedFilter == 'Expenses') {
      typeParam = 'EXPENSE';
    } else if (_selectedFilter == 'Income') {
      typeParam = 'INCOME';
    }

    try {
      final data = await _transactionRepo.getTransactionsCursor(
        limit: 50,
        cursor: _nextCursor,
        month: _selectedMonth,
        year: _selectedYear,
        memberId: _selectedMemberId,
        type: typeParam,
      );

      final rawItems = data['items'] as List? ?? [];
      final newItems = rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => LedgerTransaction.fromApiResponse(e))
          .toList();

      if (mounted) {
        setState(() {
          _transactions.addAll(newItems);
          _nextCursor = data['next_cursor']?.toString();
          _recalculateSummary();
          _isLoadingMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _recalculateSummary() {
    final count = _transactions.length;
    double outflow = 0.0;
    double inflow = 0.0;

    for (final t in _transactions) {
      if (t.isExpense) {
        outflow += t.amount;
      } else {
        inflow += t.amount;
      }
    }

    _summary = ActivitySummary(
      totalCount: count,
      outflowAmount: outflow,
      inflowAmount: inflow,
      netAmount: inflow - outflow,
    );
  }

  List<LedgerTransaction> get _displayedTransactions {
    var list = _transactions;

    // Filter by Events & Goals if chip active
    if (_selectedFilter == 'Events & Goals') {
      list = list.where((t) {
        return t.eventId != null ||
            (t.badgeText?.toLowerCase().contains('pujo') ?? false) ||
            (t.badgeText?.toLowerCase().contains('event') ?? false) ||
            t.categoryName.toLowerCase().contains('festival');
      }).toList();
    }

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((t) {
        final titleMatch = t.title.toLowerCase().contains(q);
        final catMatch = t.categoryName.toLowerCase().contains(q);
        final payerMatch = t.payerName.toLowerCase().contains(q);
        final benMatch = t.beneficiaryName.toLowerCase().contains(q);
        final notesMatch = t.notes?.toLowerCase().contains(q) ?? false;
        return titleMatch || catMatch || payerMatch || benMatch || notesMatch;
      }).toList();
    }

    return list;
  }

  Future<void> _confirmDeleteTransaction(LedgerTransaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface02,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline_rounded, color: AppColors.dangerCoral),
            SizedBox(width: 8),
            Text(
              'Delete Transaction',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${tx.title}" of ₹${tx.amount.toStringAsFixed(0)}? This will permanently remove it from the ledger.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerCoral,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _transactionRepo.deleteTransaction(tx.id);
        if (!mounted) return;
        setState(() {
          _transactions.removeWhere((t) => t.id == tx.id);
          _recalculateSummary();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${tx.title}"'),
            backgroundColor: AppColors.surface03,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting transaction: $e'),
            backgroundColor: AppColors.dangerCoral,
          ),
        );
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
    final options = <Map<String, dynamic>>[
      {'label': 'All Time', 'month': null, 'year': null},
    ];

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
                  'Select Period',
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
                            _selectedMonth = opt['month'] as int?;
                            _selectedYear = opt['year'] as int?;
                          });
                          _fetchTransactions(reset: true);
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
    if (_selectedMonth == null || _selectedYear == null) {
      return 'All Time';
    }
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
    return '${monthNames[_selectedMonth! - 1]} $_selectedYear';
  }

  @override
  Widget build(BuildContext context) {
    final displayed = _displayedTransactions;

    // Group displayed transactions by dateSection
    final Map<String, List<LedgerTransaction>> groupedSections = {};
    for (final tx in displayed) {
      groupedSections.putIfAbsent(tx.dateSection, () => []).add(tx);
    }

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
        onRefresh: () => _fetchTransactions(reset: true),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Audit & Velocity Header + Period Selector Pill + Search Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TRANSACTION HISTORY',
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

                  // Actions: Search Icon + Month Selector Pill
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearchOpen = !_isSearchOpen;
                            if (!_isSearchOpen) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                        icon: Icon(
                          _isSearchOpen
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          color: _isSearchOpen
                              ? AppColors.primaryFixed
                              : AppColors.textMuted,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showMonthPicker(context),
                        borderRadius: BorderRadius.circular(9999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface02,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(
                                color: AppColors.ghostBorder, width: 1),
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
                ],
              ),

              // Animated Search Bar
              if (_isSearchOpen) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface01,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.primaryFixed, width: 0.8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search title, category, notes, member...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      icon: const Icon(Icons.search,
                          color: AppColors.primaryFixed, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  color: AppColors.textMuted, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() => _searchQuery = val.trim());
                    },
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 2. Filter Chips Carousel (All, Expenses, Income, Events & Goals)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          if (_selectedFilter != filter) {
                            setState(() => _selectedFilter = filter);
                            _fetchTransactions(reset: true);
                          }
                        },
                        borderRadius: BorderRadius.circular(9999),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryFixed
                                : AppColors.surface01,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryFixed
                                          .withValues(alpha: 0.25),
                                      blurRadius: 12,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (filter == 'Events & Goals') ...[
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

              // 2.5 Member Filter Chips (if family members exist)
              if (_familyMembers.length > 1) ...[
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      // All Members Chip
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: const Text('All Members'),
                          selected: _selectedMemberId == null,
                          selectedColor:
                              AppColors.surface03,
                          backgroundColor: AppColors.surface01,
                          labelStyle: TextStyle(
                            color: _selectedMemberId == null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          onSelected: (_) {
                            setState(() => _selectedMemberId = null);
                            _fetchTransactions(reset: true);
                          },
                        ),
                      ),
                      ..._familyMembers.map((m) {
                        final isSel = _selectedMemberId == m.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(m.name),
                            selected: isSel,
                            selectedColor: AppColors.surface03,
                            backgroundColor: AppColors.surface01,
                            labelStyle: TextStyle(
                              color: isSel
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (_) {
                              setState(() => _selectedMemberId = m.id);
                              _fetchTransactions(reset: true);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // 3. Telemetry Strip (Dynamic Total Activity, Outflow, Inflow, Dual Gradient Bar)
              ActivityTelemetryStrip(summary: _summary),

              const SizedBox(height: 24),

              // 4. Content Area
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
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.dangerCoral, size: 36),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading activity:\n$_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.dangerCoral),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _fetchTransactions(reset: true),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (displayed.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.surface02,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            color: AppColors.textMuted,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Transactions Found',
                          style: AppTypography.headlineSm(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No results matching "$_searchQuery".'
                              : 'No activity recorded for this period.',
                          style: AppTypography.bodySm(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => AddExpenseIncomeScreen(
                                  repository: widget.repository,
                                  initialType: TransactionType.expense,
                                  transactionRepository: _transactionRepo,
                                  familyRepository: _familyRepo,
                                ),
                              ),
                            );
                            _fetchTransactions(reset: true);
                          },
                          icon: const Icon(Icons.add,
                              color: AppColors.primaryFixed, size: 18),
                          label: const Text(
                            'Log a Transaction',
                            style: TextStyle(
                              color: AppColors.primaryFixed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppColors.primaryFixed, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Render Grouped Sections (Today, Yesterday, 12 Nov 2026, etc.)
                ...groupedSections.entries.map((entry) {
                  final sectionName = entry.key;
                  final items = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sectionName,
                            style: AppTypography.headlineSm(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${items.length} ${items.length == 1 ? "TRANSACTION" : "TRANSACTIONS"}',
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
                        itemCount: items.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ActivityTransactionCard(
                            transaction: item,
                            onDelete: () => _confirmDeleteTransaction(item),
                            onTap: () {
                              if (item.badgeText?.contains('Pujo') == true ||
                                  item.categoryName.contains('Festivals')) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        ConjoinedEventDetailScreen(
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
                  );
                }),

                // Pagination Loading Indicator
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryFixed,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
