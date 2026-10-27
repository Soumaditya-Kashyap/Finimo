import 'package:flutter/material.dart';
import 'activity_screen.dart';
import 'deep_dive_screen.dart';
import 'home_screen.dart';
import 'targets_screen.dart';
import '../services/home_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/finimo_bottom_nav_bar.dart';

class MainNavigationShell extends StatefulWidget {
  final HomeRepository homeRepository;

  const MainNavigationShell({
    super.key,
    required this.homeRepository,
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
                onSeeLedgerTap: () {
                  setState(() => _currentIndex = 1);
                },
              ),
              // Tab 1: Activity
              ActivityScreen(repository: widget.homeRepository),
              // Tab 2: Targets
              TargetsScreen(
                repository: widget.homeRepository,
                isActive: _currentIndex == 2,
                onSeeLedgerTap: () {
                  setState(() => _currentIndex = 1);
                },
              ),
              // Tab 3: Deep Dive
              DeepDiveScreen(
                repository: widget.homeRepository,
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
