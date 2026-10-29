import 'package:flutter/material.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/navigation/progress_reload_notifier.dart';
import 'package:forge/core/navigation/schedule_reload_notifier.dart';
import 'package:forge/core/navigation/stats_reload_notifier.dart';
import 'package:forge/core/navigation/workout_history_reload_notifier.dart';
import 'package:forge/core/navigation/workout_plans_reload_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const int _homeTabIndex = 0;
  static const int _plansTabIndex = 1;
  static const int _scheduleTabIndex = 2;
  static const int _historyTabIndex = 3;
  static const int _progressTabIndex = 4;
  static const int _statsTabIndex = 5;

  void _onDestinationSelected(int index) {
    if (index == _homeTabIndex) {
      getIt<HomeReloadNotifier>().notify();
    }
    if (index == _plansTabIndex) {
      getIt<WorkoutPlansReloadNotifier>().notify();
    }
    if (index == _scheduleTabIndex) {
      getIt<ScheduleReloadNotifier>().notify();
    }
    if (index == _historyTabIndex) {
      getIt<WorkoutHistoryReloadNotifier>().notify();
    }
    if (index == _progressTabIndex) {
      getIt<ProgressReloadNotifier>().notify();
    }
    if (index == _statsTabIndex) {
      getIt<StatsReloadNotifier>().notify();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.15),
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: colorScheme.primary),
            label: context.l10n.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(
              Icons.fitness_center,
              color: colorScheme.primary,
            ),
            label: context.l10n.navPlans,
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(
              Icons.calendar_today,
              color: colorScheme.primary,
            ),
            label: context.l10n.navSchedule,
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: colorScheme.primary),
            label: context.l10n.navHistory,
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_outlined),
            selectedIcon: Icon(Icons.trending_up, color: colorScheme.primary),
            label: context.l10n.navProgress,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: colorScheme.primary),
            label: context.l10n.navStats,
          ),
        ],
      ),
    );
  }
}
