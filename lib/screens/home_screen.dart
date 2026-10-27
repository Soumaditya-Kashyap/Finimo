import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../models/home_dashboard_data.dart';
import '../models/conjoined_event_summary.dart';
import '../models/transaction_item.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/finimo_app_bar.dart';
import '../widgets/family_orbit_selector.dart';
import '../widgets/liquidity_hero_card.dart';
import '../widgets/quick_action_grid.dart';
import '../widgets/active_event_snapshot_card.dart';
import '../widgets/recent_flows_section.dart';
import 'add_expense_income_screen.dart';
import 'conjoined_event_detail_screen.dart';
import 'insurance_vault_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final HomeRepository repository;
  final VoidCallback? onSeeLedgerTap;

  const HomeScreen({
    super.key,
    required this.repository,
    this.onSeeLedgerTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<_HomeScreenData> _futureData;
  String _selectedFamilyScope = 'Family (All)';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureData = Future.wait([
      widget.repository.getFamilyMembers(),
      widget.repository.getDashboardMetrics(),
      widget.repository.getActiveConjoinedEvent(),
      widget.repository.getRecentFlows(),
    ]).then((results) => _HomeScreenData(
          members: results[0] as List<FamilyMember>,
          dashboard: results[1] as HomeDashboardData,
          activeEvent: results[2] as ConjoinedEventSummary,
          recentFlows: results[3] as List<TransactionItem>,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      appBar: FinimoAppBar(
        onNotificationTap: () {
          // Future notification tray
        },
        onProfileTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => UserProfileScreen(repository: widget.repository),
            ),
          );
        },
      ),
      body: FutureBuilder<_HomeScreenData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryFixed,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading dashboard: ${snapshot.error}',
                style: const TextStyle(color: AppColors.dangerCoral),
              ),
            );
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                  onExpenseTap: () {
                    AddExpenseIncomeScreen.show(
                      context,
                      repository: widget.repository,
                      initialType: TransactionType.expense,
                    );
                  },
                  onIncomeTap: () {
                    AddExpenseIncomeScreen.show(
                      context,
                      repository: widget.repository,
                      initialType: TransactionType.income,
                    );
                  },
                  onEventBillTap: () {
                    AddExpenseIncomeScreen.show(
                      context,
                      repository: widget.repository,
                      initialType: TransactionType.expense,
                    );
                  },
                  onPolicyTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => InsuranceVaultScreen(
                          repository: widget.repository,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                // 4. Conjoined Sinking Fund (Durga Puja 2026) Card
                ActiveEventSnapshotCard(
                  event: data.activeEvent,
                  onBreakdownTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => ConjoinedEventDetailScreen(
                          repository: widget.repository,
                          eventId: data.activeEvent.id,
                          eventTitle: data.activeEvent.title,
                          backLabel: 'Status',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 22),

                // 5. Recent Flows Ledger Feed
                RecentFlowsSection(
                  items: data.recentFlows,
                  onSeeLedgerTap: widget.onSeeLedgerTap,
                ),
              ],
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Operating Orbit',
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
                  setState(() => _selectedFamilyScope = 'Family (All)');
                  Navigator.pop(ctx);
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
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                  trailing: _selectedFamilyScope == m.name
                      ? const Icon(Icons.check, color: AppColors.primaryFixed)
                      : null,
                  onTap: () {
                    setState(() => _selectedFamilyScope = m.name);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeScreenData {
  final List<FamilyMember> members;
  final HomeDashboardData dashboard;
  final ConjoinedEventSummary activeEvent;
  final List<TransactionItem> recentFlows;

  _HomeScreenData({
    required this.members,
    required this.dashboard,
    required this.activeEvent,
    required this.recentFlows,
  });
}
