import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/navigation/progress_reload_notifier.dart';
import 'package:forge/core/navigation/stats_reload_notifier.dart';
import 'package:forge/core/navigation/workout_history_reload_notifier.dart';

/// Tells every screen built from stored workouts to reload.
///
/// Call [refresh] after any change to logged workouts (a workout saved,
/// edited or deleted) so History, Progress and Stats are current no matter
/// which route the user takes to reach them.
class WorkoutDataRefresher {
  const WorkoutDataRefresher({
    required this.stats,
    required this.progress,
    required this.history,
    required this.home,
  });

  final StatsReloadNotifier stats;
  final ProgressReloadNotifier progress;
  final WorkoutHistoryReloadNotifier history;
  final HomeReloadNotifier home;

  void refresh() {
    stats.notify();
    progress.notify();
    history.notify();
    home.notify();
  }
}
