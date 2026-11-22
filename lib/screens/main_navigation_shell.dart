import 'package:flutter/material.dart';
import 'activity_screen.dart';
import 'deep_dive_screen.dart';
import 'home_screen.dart';
import 'targets_screen.dart';
import '../services/category_repository.dart';
import '../services/dashboard_repository.dart';
import '../services/event_repository.dart';
import '../services/family_repository.dart';
import '../services/home_repository.dart';
import '../services/insight_repository.dart';
import '../services/target_repository.dart';
import '../services/transaction_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/finimo_bottom_nav_bar.dart';

class MainNavigationShell extends StatefulWidget {
  final HomeRepository homeRepository;
  final TransactionRepository? transactionRepository;
  final FamilyRepository? familyRepository;
  final CategoryRepository? categoryRepository;
  final DashboardRepository? dashboardRepository;
  final TargetRepository? targetRepository;
  final EventRepository? eventRepository;
  final InsightRepository? insightRepository;

  const MainNavigationShell({
    super.key,
    required this.homeRepository,
    this.transactionRepository,
    this.familyRepository,
    this.categoryRepository,
    this.dashboardRepository,
    this.targetRepository,
    this.eventRepository,
    this.insightRepository,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvasBase,
      body: Stack(
        children: [
          // Screen View based on current index
          IndexedStack(
            index: _currentIndex,
            children: [
              // Tab 0: Status (Home)
              HomeScreen(
                repository: widget.homeRepository,
                dashboardRepository: widget.dashboardRepository,
                familyRepository: widget.familyRepository,
                transactionRepository: widget.transactionRepository,
                categoryRepository: widget.categoryRepository,
                eventRepository: widget.eventRepository,
                isActive: _currentIndex == 0,
                onSeeLedgerTap: () {
                  setState(() => _currentIndex = 1);
                },
              ),
              // Tab 1: Activity
              ActivityScreen(
                repository: widget.homeRepository,
                transactionRepository: widget.transactionRepository,
                familyRepository: widget.familyRepository,
                categoryRepository: widget.categoryRepository,
                dashboardRepository: widget.dashboardRepository,
                isActive: _currentIndex == 1,
              ),
              // Tab 2: Targets
              TargetsScreen(
                repository: widget.homeRepository,
                targetRepository: widget.targetRepository,
                eventRepository: widget.eventRepository,
                categoryRepository: widget.categoryRepository,
                dashboardRepository: widget.dashboardRepository,
                transactionRepository: widget.transactionRepository,
                isActive: _currentIndex == 2,
                onSeeLedgerTap: () {
                  setState(() => _currentIndex = 1);
                },
              ),
              // Tab 3: Deep Dive
              DeepDiveScreen(
                repository: widget.homeRepository,
                insightRepository: widget.insightRepository,
                familyRepository: widget.familyRepository,
                isActive: _currentIndex == 3,
              ),
            ],
          ),

          // Floating Glassmorphic Bottom Navigation Dock
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FinimoBottomNavBar(
              currentIndex: _currentIndex,
              onTabSelected: (index) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
