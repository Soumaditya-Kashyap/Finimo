import 'package:flutter/material.dart';
import '../models/conjoined_event_summary.dart';
import '../models/family_member.dart';
import '../models/home_dashboard_data.dart';
import '../models/transaction_item.dart';
import '../services/category_repository.dart';
import '../services/dashboard_repository.dart';
import '../services/event_repository.dart';
import '../services/family_repository.dart';
import '../services/home_repository.dart';
import '../services/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/active_event_snapshot_card.dart';
import '../widgets/family_orbit_selector.dart';
import '../widgets/finimo_app_bar.dart';
import '../widgets/liquidity_hero_card.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/recent_flows_section.dart';
import 'add_expense_income_screen.dart';
import 'conjoined_event_detail_screen.dart';
import 'insurance_vault_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final HomeRepository repository;
  final DashboardRepository? dashboardRepository;
  final FamilyRepository? familyRepository;
  final TransactionRepository? transactionRepository;
  final CategoryRepository? categoryRepository;
  final EventRepository? eventRepository;
  final VoidCallback? onSeeLedgerTap;
  final bool isActive;

  const HomeScreen({
    super.key,
    required this.repository,
    this.dashboardRepository,
    this.familyRepository,
    this.transactionRepository,
    this.categoryRepository,
    this.eventRepository,
    this.onSeeLedgerTap,
    this.isActive = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DashboardRepository _dashboardRepo;
  late final FamilyRepository _familyRepo;
  late final TransactionRepository _transactionRepo;
  late final CategoryRepository _categoryRepo;
  late final EventRepository _eventRepo;

  late Future<_HomeScreenData> _futureData;
  _HomeScreenData? _lastLoadedData;
  String _selectedFamilyScope = 'Family (All)';
  String? _selectedMemberId;

  @override
  void initState() {
    super.initState();
    _dashboardRepo =
        widget.dashboardRepository ?? HttpDashboardRepository();
    _familyRepo = widget.familyRepository ?? HttpFamilyRepository();
    _transactionRepo =
        widget.transactionRepository ?? HttpTransactionRepository();
    _categoryRepo =
        widget.categoryRepository ?? HttpCategoryRepository();
    _eventRepo =
        widget.eventRepository ?? HttpEventRepository();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _loadData(selectedMemberId: _selectedMemberId);
    }
  }

  void _loadData({String? selectedMemberId}) {
    setState(() {
      _futureData = Future.wait([
        _familyRepo.getFamilyMembers().catchError((_) async {
          if (_lastLoadedData != null && _lastLoadedData!.members.isNotEmpty) {
            return _lastLoadedData!.members;
          }
          return widget.repository.getFamilyMembers();
        }),
        _dashboardRepo
            .getDashboardMetrics(memberId: selectedMemberId)
            .catchError((_) async {
          if (_lastLoadedData != null) {
            return _lastLoadedData!.dashboard;
          }
          return widget.repository.getDashboardMetrics();
        }),
        _dashboardRepo.getActiveConjoinedEvent().catchError((_) async {
          if (_lastLoadedData != null) {
            return _lastLoadedData!.activeEvent;
          }
          return widget.repository.getActiveConjoinedEvent();
        }),
        _transactionRepo
            .getRecentTransactions(limit: 5, memberId: selectedMemberId)
            .catchError((_) async {
          if (_lastLoadedData != null) {
            return _lastLoadedData!.recentFlows;
          }
          return widget.repository.getRecentFlows();
        }),
      ]).then((results) {
        final data = _HomeScreenData(
          members: results[0] as List<FamilyMember>,
          dashboard: results[1] as HomeDashboardData,
          activeEvent: results[2] as ConjoinedEventSummary?,
          recentFlows: results[3] as List<TransactionItem>,
        );
        _lastLoadedData = data;
        return data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: FinimoAppBar(
        onNotificationTap: () {
          // Future notification tray
        },
        onProfileTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) =>
                  UserProfileScreen(repository: widget.repository),
            ),
          );
          if (mounted) _loadData(selectedMemberId: _selectedMemberId);
        },
      ),
      body: FutureBuilder<_HomeScreenData>(
        future: _futureData,
        initialData: _lastLoadedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryFixed,
              ),
            );
          }

          if (snapshot.hasError && snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error loading dashboard: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.dangerCoral),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () =>
                        _loadData(selectedMemberId: _selectedMemberId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryFixed,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            color: AppColors.primaryFixed,
            backgroundColor: AppColors.surface01,
            onRefresh: () async {
              _loadData(selectedMemberId: _selectedMemberId);
              await _futureData;
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Operating Orbit & Family Vault Selector
                  FamilyOrbitSelector(
                    members: data.members,
                    selectedLabel: _selectedFamilyScope,
                    onTap: () => _showFamilySelectorSheet(data.members),
                  ),

                  const SizedBox(height: 18),

                  // 2. Consolidated Liquid Cash Hero Card
                  LiquidityHeroCard(
                    data: data.dashboard,
                  ),

                  const SizedBox(height: 18),

                  // 3. Quick Action Grid (Expense, Income, Event Bill, Policy)
                  QuickActionGrid(
                    onExpenseTap: () async {
                      final result = await AddExpenseIncomeScreen.show(
                        context,
                        repository: widget.repository,
                        familyRepository: _familyRepo,
                        categoryRepository: _categoryRepo,
                        transactionRepository: _transactionRepo,
                        dashboardRepository: _dashboardRepo,
                        eventRepository: _eventRepo,
                        initialType: TransactionType.expense,
                      );
                      if (result == true && mounted) {
                        _loadData(selectedMemberId: _selectedMemberId);
                      }
                    },
                    onIncomeTap: () async {
                      final result = await AddExpenseIncomeScreen.show(
                        context,
                        repository: widget.repository,
                        familyRepository: _familyRepo,
                        categoryRepository: _categoryRepo,
                        transactionRepository: _transactionRepo,
                        dashboardRepository: _dashboardRepo,
                        eventRepository: _eventRepo,
                        initialType: TransactionType.income,
                      );
                      if (result == true && mounted) {
                        _loadData(selectedMemberId: _selectedMemberId);
                      }
                    },
                    onEventBillTap: () async {
                      final result = await AddExpenseIncomeScreen.show(
                        context,
                        repository: widget.repository,
                        familyRepository: _familyRepo,
                        categoryRepository: _categoryRepo,
                        transactionRepository: _transactionRepo,
                        dashboardRepository: _dashboardRepo,
                        eventRepository: _eventRepo,
                        initialType: TransactionType.expense,
                        isEventExpenseOnly: true,
                      );
                      if (result == true && mounted) {
                        _loadData(selectedMemberId: _selectedMemberId);
                      }
                    },
                    onPolicyTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => InsuranceVaultScreen(
                            repository: widget.repository,
                            familyRepository: _familyRepo,
                          ),
                        ),
                      );
                      if (mounted) {
                        _loadData(selectedMemberId: _selectedMemberId);
                      }
                    },
                  ),

                  const SizedBox(height: 18),

                  // 4. Conjoined Sinking Fund Card
                  ActiveEventSnapshotCard(
                    event: data.activeEvent,
                    onBreakdownTap: data.activeEvent != null
                        ? () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => ConjoinedEventDetailScreen(
                                  repository: widget.repository,
                                  eventId: data.activeEvent!.id,
                                  eventTitle: data.activeEvent!.title,
                                  backLabel: 'Home',
                                ),
                              ),
                            );
                            if (result == true && mounted) {
                              _loadData(selectedMemberId: _selectedMemberId);
                            }
                          }
                        : null,
                  ),

                  const SizedBox(height: 22),

                  // 5. Recent Flows Ledger Feed
                  RecentFlowsSection(
                    items: data.recentFlows,
                    onSeeLedgerTap: widget.onSeeLedgerTap,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFamilySelectorSheet(List<FamilyMember> members) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface01,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final systemBottom = MediaQuery.viewPaddingOf(ctx).bottom > 0
            ? MediaQuery.viewPaddingOf(ctx).bottom
            : MediaQuery.paddingOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + systemBottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Whose View?',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surface03,
                    child: Icon(Icons.group, color: AppColors.primaryFixed),
                  ),
                  title: const Text(
                    'Family (All)',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: _selectedFamilyScope == 'Family (All)'
                      ? const Icon(Icons.check, color: AppColors.primaryFixed)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedFamilyScope = 'Family (All)';
                      _selectedMemberId = null;
                    });
                    Navigator.pop(ctx);
                    _loadData(selectedMemberId: null);
                  },
                ),
                ...members.map(
                  (m) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surface02,
                      child: Text(
                        m.initial,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      m.name,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      m.relationType.name.toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                    trailing: _selectedFamilyScope == m.name
                        ? const Icon(Icons.check, color: AppColors.primaryFixed)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedFamilyScope = m.name;
                        _selectedMemberId = m.id;
                      });
                      Navigator.pop(ctx);
                      _loadData(selectedMemberId: m.id);
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
}

class _HomeScreenData {
  final List<FamilyMember> members;
  final HomeDashboardData dashboard;
  final ConjoinedEventSummary? activeEvent;
  final List<TransactionItem> recentFlows;

  _HomeScreenData({
    required this.members,
    required this.dashboard,
    this.activeEvent,
    required this.recentFlows,
  });
}
